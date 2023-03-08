import 'dart:math';

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import 'consts.dart';
import 'data_snapshot.dart';
import 'database_event.dart';
import 'database_reference.dart';
import 'firebase_database.dart';

class Query {
  static final _r = Random();
  final FirebaseDatabase database;
  final List<String> pathSegments;

  Query(this.database, this.pathSegments);

  String get path {
    if (pathSegments.isEmpty) {
      return "/";
    }
    return pathSegments.join("/");
  }

  /// Obtains a [DatabaseReference] corresponding to this query's location.
  DatabaseReference get ref {
    if (this is DatabaseReference) {
      return this as DatabaseReference;
    }
    return DatabaseReference(database, pathSegments);
  }

  Future<DataSnapshot> get() async {
    final c = database.connection;
    final payload = {
      WS.REQUEST_PATH: path,
      WS.REQUEST_QUERIES: <String, dynamic>{},
    };
    final res = await c.sendRequest(
      action: WS.REQUEST_ACTION_GET, 
      payload: payload
    );
    if (res[WS.REQUEST_STATUS] != "ok") {
      throw res;
    }
    final data = res[WS.SERVER_RESPONSE_DATA];
    return DataSnapshot(ref, data);
  }

  Stream<DatabaseEvent> get onValue {
    final c = database.connection;
    final tag = _r.nextInt(UINT32_MAX);
    final payload = {
      WS.REQUEST_PATH: path,
      WS.REQUEST_QUERIES: <String, dynamic>{},
      WS.REQUEST_TAG: tag,
      WS.REQUEST_DATA_HASH: path.hashCode,
    };
    return c.sendStreamRequest(
      action: WS.REQUEST_ACTION_QUERY,
      path: path,
      payload: payload,
    ).map((event) {
      return DatabaseEvent(
        DatabaseEventType.value,
        DataSnapshot(ref, event),
        null,
      );
    });
  }
}

extension PathSegments on String {
  List<String> pathSegments() =>
    this.split("/")
      .where((e) => e.isNotEmpty)
      .toList();
}