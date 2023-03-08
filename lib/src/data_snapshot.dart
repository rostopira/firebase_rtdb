import 'consts.dart';
import 'database_reference.dart';

class DataSnapshot {
  /// The Reference for the location that generated this DataSnapshot.
  final DatabaseReference ref;

  /// Returns the contents of this data snapshot as native types.
  final Object? value;

  /// Gets the priority value of the data in this [DataSnapshot] or null if no
  /// priority set.
  final Object? priority = null; // TODO(rostopira): extract from value

  DataSnapshot(this.ref, this.value);

  /// The key of the location that generated this DataSnapshot or null if at
  /// database root.
  String? get key => ref.key;

  /// Ascertains whether the value exists at the Firebase Database location.
  bool get exists => value != null;

  /// Returns true if the specified child path has (non-null) data.
  bool hasChild(String path) {
    final maybeMap = value;
    if (maybeMap is MSD) {
      return maybeMap.containsKey(path);
    }
    return false;
  }

  /// Gets another [DataSnapshot] for the location at the specified relative path.
  /// The relative path can either be a simple child name (for example, "ada")
  /// or a deeper, slash-separated path (for example, "ada/name/first").
  /// If the child location has no data, an empty DataSnapshot (that is, a
  /// DataSnapshot whose [value] is null) is returned.
  DataSnapshot child(String path) {
    // TODO(rostopira): implement after priority implementation
    throw UnimplementedError();
  }

  /// An iterator for snapshots of the child nodes in this snapshot.
  Iterable<DataSnapshot> get children {
    // TODO(rostopira): implement after priority implementation
    throw UnimplementedError();
  }
}