import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';

import 'data_snapshot.dart';

class DatabaseEvent {

  /// The type of event.
  final DatabaseEventType type;

  /// The [DataSnapshot] for this event.
  final DataSnapshot snapshot;

  /// A string containing the key of the previous sibling child by sort order,
  /// or null if it is the first child.
  final String? previousChildKey;

  DatabaseEvent(this.type, this.snapshot, this.previousChildKey);

}