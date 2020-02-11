import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final stateChangedStreamController = StreamController<FirebaseUser>();
  FirebaseUser _currentUser;

  MockFirebaseAuth({signedIn = false}) {
    if (signedIn) {
      signInWithCredential(null);
    }
  }

  Future<FirebaseUser> currentUser() {
    return Future.value(_currentUser);
  }

  @override
  Future<AuthResult> signInWithCredential(AuthCredential credential) {
    final authResult = MockAuthResult();
    _currentUser = authResult.user;
    stateChangedStreamController.add(_currentUser);
    return Future.value(authResult);
  }

  @override
  Stream<FirebaseUser> get onAuthStateChanged =>
      stateChangedStreamController.stream;
}

class MockFirebaseUser extends Mock implements FirebaseUser {
  @override
  String get displayName => 'Bob';

  @override
  String get uid => 'aabbcc';

  @override
  Future<IdTokenResult> getIdToken({bool refresh = false}) async {
    return Future.value(MockIdTokenResult());
  }
}

class MockAuthResult extends Mock implements AuthResult {
  FirebaseUser user = MockFirebaseUser();
}

class MockIdTokenResult extends Mock implements IdTokenResult {
  @override
  String get token => 'fake_token';
}
