import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../firebase_auth_mocks.dart';
import 'mock_confirmation_result.dart';
import 'mock_user_credential.dart';

class MockFirebaseAuth implements FirebaseAuth {
  final stateChangedStreamController = StreamController<User?>();
  late Stream<User?> stateChangedStream;
  final userChangedStreamController = StreamController<User?>();
  late Stream<User?> userChangedStream;
  MockUser? _mockUser;
  User? _currentUser;

  MockFirebaseAuth({bool signedIn = false, MockUser? mockUser})
      : _mockUser = mockUser {
    stateChangedStream =
        stateChangedStreamController.stream.asBroadcastStream();
    userChangedStream = userChangedStreamController.stream.asBroadcastStream();
    if (signedIn) {
      signInWithCredential(null);
    } else {
      // Notify of null on startup.
      signOut();
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
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    _mockUser = MockUser(
      uid: 'mock_uid',
      email: email,
      displayName: 'Mock User',
    );
    return _fakeSignUp();
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
    userChangedStreamController.add(null);
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) {
    return Future.value([]);
  }

  Future<UserCredential> _fakeSignIn({bool isAnonymous = false}) {
    final userCredential = MockUserCredential(isAnonymous, mockUser: _mockUser);
    _currentUser = userCredential.user;
    stateChangedStreamController.add(_currentUser);
    userChangedStreamController.add(_currentUser);
    return Future.value(userCredential);
  }

  Future<UserCredential> _fakeSignUp({bool isAnonymous = false}) {
    final userCredential = MockUserCredential(isAnonymous, mockUser: _mockUser);
    _currentUser = userCredential.user;
    stateChangedStreamController.add(_currentUser);
    userChangedStreamController.add(_currentUser);
    return Future.value(userCredential);
  }

  Stream<User> get onAuthStateChanged =>
      authStateChanges().map((event) => event!);

  @override
  Stream<User?> authStateChanges() => stateChangedStream;

  @override
  Stream<User?> userChanges() => userChangedStream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
