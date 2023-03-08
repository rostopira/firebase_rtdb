import 'dart:math';

extension Chunked<T> on List<T> {
  List<List<T>> intoChunks(int chunkSize) {
    assert(chunkSize > 0);
    if (isEmpty) {
      return [];
    }
    if (length <= chunkSize) {
      return [this];
    }
    final result = <List<T>>[];
    for (var i = 0; i < length; i += chunkSize) {
      final end = min(i + chunkSize, length);
      result.add(getRange(i, end).toList(growable: false));
    }
    return result;
  }
}

extension LastAndFirst on String {
  String get last => this[length-1];
  String get first => this[0];
}