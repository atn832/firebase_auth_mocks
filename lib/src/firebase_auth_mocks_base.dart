import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import 'auth_exceptions.dart';
import 'mock_confirmation_result.dart';
import 'mock_user.dart';
import 'mock_user_credential.dart';

class MockFirebaseAuth implements FirebaseAuth {
  final stateChangedStreamController = StreamController<User?>();
  late Stream<User?> stateChangedStream;
  final userChangedStreamController = StreamController<User?>();
  late Stream<User?> userChangedStream;
  MockUser? _mockUser;
  User? _currentUser;
  final AuthExceptions? _authExceptions;

  MockFirebaseAuth({
    bool signedIn = false,
    MockUser? mockUser,
    AuthExceptions? authExceptions,
  })  : _mockUser = mockUser,
        _authExceptions = authExceptions {
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
    if (_authExceptions?.signInWithCredential != null) {
      throw (_authExceptions!.signInWithCredential!);
    }

    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    if (_authExceptions?.signInWithEmailAndPassword != null) {
      throw (_authExceptions!.signInWithEmailAndPassword!);
    }

    return _fakeSignIn();
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    if (_authExceptions?.createUserWithEmailAndPassword != null) {
      throw (_authExceptions!.createUserWithEmailAndPassword!);
    }

    _mockUser = MockUser(
      uid: 'mock_uid',
      email: email,
      displayName: 'Mock User',
    );
    return _fakeSignUp();
  }

  @override
  Future<UserCredential> signInWithCustomToken(String token) async {
    if (_authExceptions?.signInWithCustomToken != null) {
      throw (_authExceptions!.signInWithCustomToken!);
    }

    return _fakeSignIn();
  }

  @override
  Future<ConfirmationResult> signInWithPhoneNumber(String phoneNumber,
      [RecaptchaVerifier? verifier]) async {
    return MockConfirmationResult(onConfirm: () => _fakeSignIn());
  }

  @override
  Future<UserCredential> signInAnonymously() {
    if (_authExceptions?.signInAnonymously != null) {
      throw (_authExceptions!.signInAnonymously!);
    }

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
    if (_authExceptions?.fetchSignInMethodsForEmail != null) {
      throw (_authExceptions!.fetchSignInMethodsForEmail!);
    }

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
    return _fakeSignIn(isAnonymous: isAnonymous);
  }

  Stream<User> get onAuthStateChanged =>
      authStateChanges().map((event) => event!);

  @override
  Stream<User?> authStateChanges() => stateChangedStream;

  @override
  Stream<User?> userChanges() => userChangedStream;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    @visibleForTesting String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
  }) async {
    codeSent('verification-id', 0);
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) {
    if (_authExceptions?.sendPasswordResetEmail != null) {
      throw _authExceptions!.sendPasswordResetEmail!;
    }

    return Future.value();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
