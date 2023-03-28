import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'consts.dart';
import 'firebase_database.dart';
import 'socket_state.dart';

class WsConnectionBase {
  static const VERSION = 5;
  static const TAG = "WsConnectionBase: ";

  static final _sessionIds = <String, String>{};
  static final _cachedHosts = <String, String>{};

  static String _sidParam(String host) {
    final cached = _sessionIds[host];
    if (cached != null) {
      return "&${C.LAST_SESSION_ID_PARAM}=$cached";
    }
    return "";
  }

  final String host;
  final String _url;

  WebSocket? _socket;
  final _msgQueue = <Map<String, dynamic>>[];
  var _state = SocketState.NEW;
  var _requestCounter = 0;
  final _callbacks = <int, Completer<MSD>>{};
  final _streams = <String, StreamController<dynamic>>{};
  Completer<MSD>? _firstMessageListener;

  SocketState get state => _state;
  bool get isReady => _state == SocketState.CONNECTED;

  WsConnectionBase(this.host):
    _url = "wss://" +
        (_cachedHosts[host] ?? host) +
        "/.ws?v=$VERSION" +
        _sidParam(host);

  Future<void> connect() async {
    assert(_state == SocketState.NEW);
    _state = SocketState.CONNECTING;
    // Lint ignored, because it's actually closed
    // ignore: close_sinks
    final WebSocket newSocket;
    print("APP ID ${FirebaseDatabase.authProvider?.appId}");
    try {
      newSocket = await WebSocket.connect(
        _url,
        headers: {
          "User-Agent": "pub.dev-firebase_rtdb",
          "X-Firebase-GMPID": FirebaseDatabase.authProvider?.appId,
        },
      );
    } catch(e) {
      print(e);
      await close();
      return;
    }
    newSocket.pingInterval = PING_INTERVAL;
    _socket = newSocket;
    final fml = Completer<MSD>();
    _firstMessageListener = fml;
    print("Created Completer");
    newSocket.listen(_handleWsMsg);
    final helloMsg = await fml.future;
    try {
      _handleHelloMsg(helloMsg);
    } catch(e) {
      print(e);
      await close();
      return;
    }
    _state = SocketState.CONNECTED;
    await sendRequest(
      action: WS.REQUEST_ACTION_STATS,
      payload: {
        WS.REQUEST_COUNTERS: {
          // Persistence not supported yet
          // "persistence.android.enabled": 1,
          "sdk.android.20-1-0": 1, // Mimic SDK version
        },
      }
    );
    final token = await FirebaseDatabase.authProvider?.getTokenFor(_url);
    if (token == null) {
      print("Auth token is null");
      _onConnected();
      return;
    }
    final res = await authorize(token);
    printError("Auth is" + (res ? "successful" : "failed"));
    // if (!res) {
    //   close()
    // }
    _onConnected();
  }

  void _onConnected() {
    while(_msgQueue.isNotEmpty) {
      send(_msgQueue.removeAt(0));
    }
  }

  void _handleHelloMsg(MSD hello) {
    assert(hello[C.SERVER_ENVELOPE_TYPE] == C.SERVER_CONTROL_MESSAGE);
    final payload = hello[C.SERVER_CONTROL_MESSAGE_DATA] as MSD;
    assert(payload[C.SERVER_CONTROL_MESSAGE_TYPE] == C.SERVER_CONTROL_MESSAGE_HELLO);
    final data = payload[C.SERVER_DATA_MESSAGE] as MSD;
    final timestamp = data[C.SERVER_HELLO_TIMESTAMP] as int;
    // TODO: save timestamp
    assert(data["v"] == VERSION.toString());
    final actualHost = data[C.SERVER_HELLO_HOST] as String;
    // TODO: _cachedHosts is invalid, recheck
    // _cachedHosts[host] = actualHost;
    final sessionId = data[C.SERVER_HELLO_SESSION_ID] as String;
    _sessionIds[host] = sessionId;
  }

  void _handleWsMsg(dynamic msgStr) {
    assert(msgStr is String);
    print("WSMSG: " + msgStr.toString());
    try {
      final msg = jsonDecode(msgStr as String) as MSD;
      if (msg[C.REQUEST_TYPE] == C.REQUEST_TYPE_DATA) {
        handleWsMsg(msg[C.REQUEST_PAYLOAD] as MSD);
      } else {
        print("Got first message");
        _firstMessageListener?.complete(msg);
        _firstMessageListener = null;
      }
      handleWsMsg(msg);
    } catch(e) {
      print(e);
    }
  }

  bool handleWsMsg(MSD msg) {
    final requestId = msg[WS.REQUEST_NUMBER] as int?;
    if (requestId != null) {
      final response = msg[WS.RESPONSE_FOR_REQUEST] as MSD;
      final callback = _callbacks[requestId];
      if (callback != null){
        callback.complete(response);
        _callbacks.remove(requestId);
        return true;
      }
      printError("Failed to handle request $requestId");
      return false;
    }
    final action = msg[WS.SERVER_ASYNC_ACTION] as String?;
    if (action != null) {
      final body = msg[WS.SERVER_ASYNC_PAYLOAD] as MSD;
      _handleAsyncPayload(action, body);
      return true;
    }
    if (msg[WS.REQUEST_ERROR] != null) {
      printError(jsonEncode(msg));
      return true;
    }
    return false;
  }

  void _handleAsyncPayload(String action, MSD payload) {
    if (action == WS.SERVER_ASYNC_DATA_UPDATE || action == WS.SERVER_ASYNC_DATA_MERGE) {
      final isMerge = action == WS.SERVER_ASYNC_DATA_MERGE;
      final pathString = payload[WS.SERVER_DATA_UPDATE_PATH] as String;
      final data = payload[WS.SERVER_DATA_UPDATE_BODY];
      // TODO(rostopira): only partial data may arrive here, have to merge
      // ignore: close_sinks
      final stream = _streams[pathString];
      if (stream != null) {
        stream.add(data);
        return;
      }
      printError("Not found listener for path ${pathString}");
      return;
    }
    throw UnimplementedError("Unrecognized async action " + action);
  }

  Future<bool> authorize(String token) async {
    final res = await sendRequest(
      action: WS.REQUEST_ACTION_AUTH,
      payload: {
        WS.REQUEST_CREDENTIAL: token,
      },
      isSensitive: true,
    );
    if (res[WS.REQUEST_STATUS] != "ok") {
      final reason = res[WS.SERVER_RESPONSE_DATA] as String;
      printError("Auth error " + reason);
      return false;
    }
    return true;
  }

  Future<MSD> sendRequest({
    required String action,
    required MSD payload,
    bool isSensitive = false,
  }) async {
    final completer = Completer<MSD>();
    final reqId = _requestCounter++;
    _callbacks[reqId] = completer;
    final reqBody = {
      C.REQUEST_TYPE: C.REQUEST_TYPE_DATA,
      C.REQUEST_PAYLOAD: {
        WS.REQUEST_NUMBER: reqId,
        WS.REQUEST_ACTION: action,
        WS.REQUEST_PAYLOAD: payload,
      }
    };
    send(reqBody);
    return completer.future;
  }

  void _closeStream(String path) {
    // TODO(rostopira): unlisten implementation
  }

  Stream<dynamic> sendStreamRequest({
    required String action,
    required String path,
    required MSD payload,
  }) {
    final streamController = StreamController<dynamic>(
      onCancel: () => _closeStream(path)
    );
    _streams[path] = streamController;
    final reqBody = {
      C.REQUEST_TYPE: C.REQUEST_TYPE_DATA,
      C.REQUEST_PAYLOAD: {
        WS.REQUEST_ACTION: action,
        WS.REQUEST_PAYLOAD: payload,
      }
    };
    send(reqBody);
    return streamController.stream;
  }

  void send(MSD jsonData) {
    if (!isReady) {
      print("Not ready to send");
      _msgQueue.add(jsonData);
      return;
    }
    final str = jsonEncode(jsonData);
    _socket?.add(str);
    // final bytes = utf8.encode(str);
    // final chunks = bytes.intoChunks(MAX_FRAME_SIZE);
    // for (final chunk in chunks) {
    //   _socket?.add(chunk);
    // }
    print("msg sent: " + str);
  }

  Future<void> close() async {
    assert(_state < SocketState.CLOSING);
    _callbacks.values.forEach((c) => c.completeError("disconnected"));
    _callbacks.clear();
    _state = SocketState.CLOSING;
    await _socket?.close();
    _socket = null;
    _state = SocketState.CLOSED;
    _streams.values.forEach((stream) => stream.addError("disconnected"));
    _streams.clear();
  }

  void printError(String error) {
    print(TAG + error);
  }

}