import 'dart:math';

/// Original source: https://github.com/firebase/firebase-android-sdk/blob/master/firebase-database/src/main/java/com/google/firebase/database/core/utilities/PushIdGenerator.java
abstract class PushIdGenerator {
  static const _PUSH_CHARS = "-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz";
  static final _random = Random();
  static var _lastPushTime = 0;
  static var _lastRandChars = List<int>.filled(12, 0);

  static String generatePushChildName() {
    var now = DateTime.now().millisecondsSinceEpoch;
    final isDuplicateTime = now == _lastPushTime;
    _lastPushTime = now;

    final timestampChars = List<int>.filled(8, 0);
    final result = StringBuffer();
    for (var i = 7; i >= 0; i--) {
      timestampChars[i] = _PUSH_CHARS.codeUnitAt(now % 64);
      now >>= 6; // now ~/= 64;
    }
    assert(now == 0);

    result.write(String.fromCharCodes(timestampChars));

    if (!isDuplicateTime) {
      for (var i = 0; i < 12; i++) {
        _lastRandChars[i] = _random.nextInt(64);
      }
    } else {
      _incrementArray();
    }
    result.write(String.fromCharCodes(_lastRandChars));
    assert(result.length == 20);
    return result.toString();
  }

  static void _incrementArray() {
    for (var i = 11; i >= 0; i--) {
      if (_lastRandChars[i] != 63) {
        _lastRandChars[i] = _lastRandChars[i] + 1;
        return;
      }
      _lastRandChars[i] = 0;
    }
  }
}