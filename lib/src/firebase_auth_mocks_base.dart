import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';

import 'mock_auth_result.dart';

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
    return _fakeSignIn();
  }

  @override
  Future<AuthResult> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) {
    return _fakeSignIn();
  }

  @override
  Future<AuthResult> signInWithEmailAndLink({String email, String link}) {
    return _fakeSignIn();
  }

  @override Future<AuthResult> signInWithCustomToken({@required String token}) {
    return _fakeSignIn();
  }

  Future<AuthResult> _fakeSignIn() {
    final authResult = MockAuthResult();
    _currentUser = authResult.user;
    stateChangedStreamController.add(_currentUser);
    return Future.value(authResult);
  }

  @override
  Stream<FirebaseUser> get onAuthStateChanged =>
      stateChangedStreamController.stream;
}
