import 'dart:async';

import 'action_delegate.dart';
import 'auth_provider.dart';
import 'database_reference.dart';
import 'socket_state.dart';
import 'ws_connection_base.dart';

class FirebaseDatabase {
  static late FirebaseDatabase _instance;
  static AuthProvider? authProvider;
  static final _instances = <String, FirebaseDatabase>{};

  /// Initialize library with default database [url] and optional [auth]
  /// provider.
  static void initialize({
    required String databaseURL,
    AuthProvider? auth,
  }) {
    _instance = FirebaseDatabase._(databaseURL);
    authProvider = auth;
  }

  static FirebaseDatabase get instance => _instance;

  static FirebaseDatabase instanceFor(String url) {
    final host = Uri.parse(url).host;
    if (_instance.host == host) {
      return _instance;
    }
    return _instances[host] ??= FirebaseDatabase._(url);
  }

  final String url;
  final String host;
  ActionDelegate? _delegate;
  WsConnectionBase? _connection;

  FirebaseDatabase._(this.url):
        host = Uri.parse(url).host;

  WsConnectionBase get connection {
    final c = _connection ?? WsConnectionBase(host);
    switch(c.state) {
      case SocketState.NEW:
        _connection = c;
        unawaited(c.connect());
        return c;
      case SocketState.CONNECTING:
      case SocketState.CONNECTED:
        return c;
      case SocketState.CLOSING:
      case SocketState.CLOSED:
        final newC = WsConnectionBase(host);
        unawaited(newC.connect());
        _connection = newC;
        return newC;
    }
  }

  ActionDelegate get delegate =>
      _delegate = _delegate ?? ActionDelegate(this);

  /// Changes this instance to point to a FirebaseDatabase emulator running locally.
  ///
  /// Set the [host] of the local emulator, such as "localhost"
  /// Set the [port] of the local emulator, such as "9000" (default is 9000)
  ///
  /// Note: Must be called immediately, prior to accessing FirebaseFirestore methods.
  /// Do not use with production credentials as emulator traffic is not encrypted.
  void useDatabaseEmulator(String host, int port) {
    throw UnimplementedError();
  }

  /// Returns a [DatabaseReference] accessing the root of the database.
  DatabaseReference reference() => ref();

  /// Returns a [DatabaseReference] representing the location in the Database
  /// corresponding to the provided path.
  /// If no path is provided, the Reference will point to the root of the
  /// Database.
  DatabaseReference ref([String? path]) {
    return DatabaseReference.fromPath(this, path);
  }

  /// Returns a [DatabaseReference] representing the location in the Database
  /// corresponding to the provided Firebase URL.
  DatabaseReference refFromURL(String url) {
    if (!url.startsWith('https://')) {
      throw ArgumentError.value(url, 'must be a valid URL', 'url');
    }

    final uri = Uri.parse(url);
    if (uri.origin != this.url) {
      throw ArgumentError.value(
        url,
        'must equal the current FirebaseDatabase instance databaseURL',
        'url',
      );
    }

    if (uri.pathSegments.isNotEmpty) {
      return ref(uri.path);
    }
    return ref();
  }

  void setPersistenceEnabled(bool enabled) {
    if (enabled) {
      throw UnimplementedError();
    }
  }

  void setPersistenceCacheSizeBytes(int cacheSize) {
    if (cacheSize > 0) {
      throw UnimplementedError();
    }
  }

  /// Resumes our connection to the Firebase Database backend after a previous
  /// [goOffline] call.
  Future<void> goOnline() async {
    final c = _connection;
    if (c == null || c.state > SocketState.CONNECTED) {
      final newc = WsConnectionBase(host);
      _connection = newc;
      await newc.connect();
    }
  }

  /// Shuts down our connection to the Firebase Database backend until
  /// [goOnline] is called.
  Future<void> goOffline() async {
    await _connection?.close();
    _connection = null;
  }

  /// The Firebase Database client automatically queues writes and sends them to
  /// the server at the earliest opportunity, depending on network connectivity.
  /// In some cases (e.g. offline usage) there may be a large number of writes
  /// waiting to be sent. Calling this method will purge all outstanding writes
  /// so they are abandoned.
  ///
  /// All writes will be purged, including transactions and onDisconnect writes.
  /// The writes will be rolled back locally, perhaps triggering events for
  /// affected event listeners, and the client will not (re-)send them to the
  /// Firebase Database backend.
  Future<void> purgeOutstandingWrites() async {
    throw UnimplementedError();
  }

}