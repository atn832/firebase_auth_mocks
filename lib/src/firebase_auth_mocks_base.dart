import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

import '../firebase_auth_mocks.dart';
import 'mock_confirmation_result.dart';
import 'mock_user_credential.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final stateChangedStreamController = StreamController<User?>();
  final MockUser? _mockUser;
  User? _currentUser;

  MockFirebaseAuth({signedIn = false, MockUser? mockUser})
      : _mockUser = mockUser {
    if (signedIn) {
      signInWithCredential(null);
    }
  }

  @override
  User? get currentUser {
    return _currentUser;
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential? credential) {
    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInWithCustomToken(String token) async {
    return _fakeSignIn();
  }

  @override
  Future<ConfirmationResult> signInWithPhoneNumber(String phoneNumber,
      [RecaptchaVerifier? verifier]) async {
    return MockConfirmationResult(onConfirm: () => _fakeSignIn());
  }

  @override
  Future<UserCredential> signInAnonymously() {
    return _fakeSignIn(isAnonymous: true);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    stateChangedStreamController.add(null);
  }

  Future<UserCredential> _fakeSignIn({bool isAnonymous = false}) {
    final userCredential =
        MockUserCredential(isAnonymous: isAnonymous, mockUser: _mockUser);
    _currentUser = userCredential.user;
    stateChangedStreamController.add(_currentUser);
    return Future.value(userCredential);
  }

  @override
  Stream<User?> authStateChanges() => stateChangedStreamController.stream;
}
