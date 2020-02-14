import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final stateChangedStreamController = StreamController<FirebaseUser>();
  FirebaseUser _currentUser;

  MockFirebaseAuth({signedIn = false, MockFirebaseUser mockFirebaseUser}) {
    if (signedIn) {
      signInWithCredential(null);
    }

    if (mockFirebaseUser != null) {
      _currentUser = mockFirebaseUser;
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
  final MockPlatformUserInfo _userData;

  MockFirebaseUser({userData})
    : _userData = userData ?? MockPlatformUserInfo();

  @override
  String get displayName => _userData.displayName;

  @override
  String get photoUrl => _userData.photoUrl;

  @override get email => _userData.email;

  @override
  String get phoneNumber => _userData.phoneNumber;

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

class MockPlatformUserInfo {
  const MockPlatformUserInfo({
    this.displayName = 'Bob',
    this.photoUrl = 'your/photo/url',
    this.email = 'bob@mail.com',
    this.phoneNumber = '+123456',
  });

  final String displayName;
  final String photoUrl;
  final String email;
  final String phoneNumber;
}