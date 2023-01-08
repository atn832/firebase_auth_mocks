import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'mock_confirmation_result.dart';
import 'mock_firebase_app.dart';
import 'mock_user.dart';
import 'mock_user_credential.dart';

class MockFirebaseAuth implements FirebaseAuth {
  final stateChangedStreamController = StreamController<User?>();
  late Stream<User?> stateChangedStream;
  final userChangedStreamController = StreamController<User?>();
  late Stream<User?> userChangedStream;
  MockUser? _mockUser;
  final Map<String, List<String>> _signInMethodsForEmail;
  User? _currentUser;

  /// The [FirebaseApp] for this current Auth instance.
  @override
  FirebaseApp app;

  MockFirebaseAuth({
    bool signedIn = false,
    MockUser? mockUser,
    Map<String, List<String>>? signInMethodsForEmail,
  })  : _mockUser = mockUser,
        _signInMethodsForEmail = signInMethodsForEmail ?? {},
        app = MockFirebaseApp() {
    stateChangedStream =
        stateChangedStreamController.stream.asBroadcastStream();
    userChangedStream = userChangedStreamController.stream.asBroadcastStream();
    if (signedIn) {
      if (mockUser?.isAnonymous ?? false) {
        signInAnonymously();
      } else {
        signInWithCredential(null);
      }
    } else {
      // Notify of null on startup.
      signOut();
    }
  }

  set mockUser(MockUser user) {
    _mockUser = user;
    // Update _currentUser if already sign in
    if (_currentUser != null) {
      _currentUser = user;
    }
  }

  @override
  User? get currentUser {
    return _currentUser;
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential? credential) {
    maybeThrowException(
        this, Invocation.method(#signInWithCredential, [credential]));

    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInWithPopup(AuthProvider provider) {
    maybeThrowException(this, Invocation.method(#signInWithPopup, [provider]));

    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInWithProvider(AuthProvider provider) {
    maybeThrowException(
        this, Invocation.method(#signInWithProvider, [provider]));

    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    maybeThrowException(
        this,
        Invocation.method(#signInWithEmailAndPassword, null,
            {#email: email, #password: password}));

    return _fakeSignIn();
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    maybeThrowException(
        this,
        Invocation.method(#createUserWithEmailAndPassword, null,
            {#email: email, #password: password}));

    _mockUser = MockUser(
      uid: 'mock_uid',
      email: email,
      displayName: 'Mock User',
    );
    return _fakeSignUp();
  }

  @override
  Future<UserCredential> signInWithCustomToken(String token) async {
    maybeThrowException(
        this, Invocation.method(#signInWithCustomToken, [token]));

    return _fakeSignIn();
  }

  @override
  Future<ConfirmationResult> signInWithPhoneNumber(String phoneNumber,
      [RecaptchaVerifier? verifier]) async {
    return MockConfirmationResult(onConfirm: () => _fakeSignIn());
  }

  @override
  Future<UserCredential> signInAnonymously() {
    maybeThrowException(this, Invocation.method(#signInAnonymously, null));

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
    maybeThrowException(
        this, Invocation.method(#fetchSignInMethodsForEmail, [email]));

    return Future.value(_signInMethodsForEmail[email] ?? []);
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
    String? phoneNumber,
    PhoneMultiFactorInfo? multiFactorInfo,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    @visibleForTesting String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    // at this time firebase auth does not export the original class
    // when this is merged, this can be typed
    // https://github.com/firebase/flutterfire/pull/9189
    Object? multiFactorSession,
  }) async {
    codeSent('verification-id', 0);
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) {
    maybeThrowException(
        this,
        Invocation.method(#sendPasswordResetEmail, null,
            {#email: email, #actionCodeSettings: actionCodeSettings}));

    return Future.value();
  }

  @override
  Future<void> sendSignInLinkToEmail({
    required String email,
    required ActionCodeSettings actionCodeSettings,
  }) {
    if (actionCodeSettings.handleCodeInApp != true) {
      throw ArgumentError(
        'The [handleCodeInApp] value of [ActionCodeSettings] must be `true`.',
      );
    }

    maybeThrowException(
        this,
        Invocation.method(#sendSignInLinkToEmail, null,
            {#email: email, #actionCodeSettings: actionCodeSettings}));

    return Future.value();
  }

  @override
  Future<void> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) {
    maybeThrowException(
        this,
        Invocation.method(#confirmPasswordReset, null,
            {#code: code, #newPassword: newPassword}));

    return Future.value();
  }

  @override
  Future<String> verifyPasswordResetCode(String code) {
    maybeThrowException(
        this, Invocation.method(#verifyPasswordResetCode, [code]));

    return Future.value(_mockUser?.email ?? 'email@example.com');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
