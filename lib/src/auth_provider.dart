import 'dart:async';

/// Interface for providing authorization
mixin AuthProvider {

  String get appId;

  /// Return true to use [getTokensStreamFor] and false to use [getTokenFor].
  bool get usesTokensStream;

  /// Accepts [databaseUrl] and returns auth token. Implement this, if you
  /// want to provide single token for whole app lifcycle.
  FutureOr<String?>? getTokenFor(String databaseUrl);

  /// Accepts [databaseUrl] and returns stream of auth changes events.
  Stream<String?>? getTokensStreamFor(String databaseUrl);

}