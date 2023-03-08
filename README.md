# Firebase Realtime Database

This package implements connection to Firebase RTDB via WebSocket API in pure Dart.

Will work on all supported by Dart platforms, except Web.

## Usage

Basically, it's just (incomplete) drop-in replacement for official package.

However, currently it doesn't handle auth and database url automatically.

You will have to init it first:
```dart
FirebaseDatabase.initialize(
    databaseURL: "https://example.firebasedatabase.app",
    auth: RtdbAuthAdapter(), // optional
);
```

Sample `RtdbAuthAdapter`:
```dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_rtdb/firebase_rtdb.dart';

class RtdbAuthAdapter implements AuthProvider {

  @override
  String get appId => Firebase.app().options.appId;

  @override
  FutureOr<String?>? getTokenFor(String databaseUrl) =>
    FirebaseAuth.instance.currentUser?.getIdToken();

  @override
  Stream<String?>? getTokensStreamFor(String databaseUrl) =>
    FirebaseAuth.instance
        .idTokenChanges()
        .asyncMap((e) => e?.getIdToken());

  @override
  bool get usesTokensStream => true;

}
```

## Checklist

    - [x] Get
    - [x] Set
    - [x] Listen single value (not object)
    - [x] On disconnect set/remote
    - [ ] Persistence
    - [ ] Queries
    - [ ] Everything else