import 'consts.dart';
import 'data_snapshot.dart';
import 'firebase_database.dart';

class ActionDelegate {
  final FirebaseDatabase database;

  ActionDelegate(this.database);



  Future<void> set(String path, Object? value) =>
    _put(action: WS.REQUEST_ACTION_PUT, path: path, data: value);

  Future<void> _put({
    required String action,
    required String path,
    required Object? data,
    String? hash,
  }) async {
    final c = database.connection;
    final payload = {
      WS.REQUEST_PATH: path,
      WS.REQUEST_DATA_PAYLOAD: data,
      if (hash != null)
        WS.REQUEST_DATA_HASH: hash,
    };
    final res = await c.sendRequest(action: action, payload: payload);
    if (res[WS.REQUEST_STATUS] != "ok") {
      throw res;
    }
  }
}