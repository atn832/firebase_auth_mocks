import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:uuid/uuid.dart';

class MockUser with EquatableMixin implements User {
  final bool _isAnonymous;
  final bool _isEmailVerified;
  final String _uid;
  String? _email;
  String? _displayName;
  final String? _phoneNumber;
  final String? _photoURL;
  final List<UserInfo> _providerData;
  final String? _refreshToken;
  final UserMetadata? _metadata;
  final IdTokenResult? _idTokenResult;
  late final DateTime _idTokenAuthTime;
  final DateTime? _idTokenExp;
  final Map<String, dynamic> _customClaim;

  MockUser({
    bool isAnonymous = false,
    bool isEmailVerified = true,
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    List<UserInfo>? providerData,
    String? refreshToken,
    UserMetadata? metadata,
    IdTokenResult? idTokenResult,
    DateTime? idTokenAuthTime,
    DateTime? idTokenExp,
    Map<String, dynamic>? customClaim,
  })  : _isAnonymous = isAnonymous,
        _isEmailVerified = isEmailVerified,
        _uid = uid ?? const Uuid().v4(),
        _email = email,
        _displayName = displayName,
        _phoneNumber = phoneNumber,
        _photoURL = photoURL,
        _providerData = providerData ?? [],
        _refreshToken = refreshToken,
        _metadata = metadata,
        _idTokenResult = idTokenResult,
        _idTokenAuthTime = idTokenAuthTime ?? DateTime.now(),
        _idTokenExp = idTokenExp,
        _customClaim = customClaim ?? {};

  FirebaseAuthException? _exception;

  /// Sets a [FirebaseAuthException]
  set exception(FirebaseAuthException value) => _exception = value;

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  bool get emailVerified => _isEmailVerified;

  @override
  String get uid => _uid;

  @override
  String? get email => _email;

  set email(String? value) {
    _email = value;
  }

  @override
  String? get displayName => _displayName;

  set displayName(String? value) {
    _displayName = value;
  }

  @override
  String? get phoneNumber => _phoneNumber;

  @override
  String? get photoURL => _photoURL ?? 'https://i.stack.imgur.com/34AD2.jpg';

  @override
  List<UserInfo> get providerData => _providerData;

  @override
  String? get refreshToken => _refreshToken;

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) {
    return Future.value(getIdTokenResultSync());
  }

  IdTokenResult getIdTokenResultSync() {
    return _idTokenResult ??
        IdTokenResult({
          'authTimestamp': 1655946582,
          'claims': _customClaim,
          'expirationTimestamp': 1656305736,
          'issuedAtTimestamp': 1656302136,
          'token': 'fake_token',
          'signInProvider': 'google.com'
        });
  }

  @override
  Future<String> getIdToken([bool forceRefresh = false]) {
    final payload = {
      'name': displayName,
      'picture': photoURL,
      'iss': 'fake_iss',
      'aud': 'fake_aud',
      'auth_time': _idTokenAuthTime.millisecondsSinceEpoch ~/ 1000,
      'user_id': uid,
      'sub': uid,
      // https://firebase.google.com/docs/reference/admin/node/firebase-admin.auth.decodedidtoken
      'exp': (_idTokenExp ?? DateTime.now().add(Duration(hours: 1)))
              .millisecondsSinceEpoch ~/
          1000,
      'email': email,
      'email_verified': emailVerified,
      'firebase': {
        'identities': {
          'google.com': ['fake_identity'],
          'email': [email]
        },
        'sign_in_provider': 'google.com'
      },
      ..._customClaim,
    };
    // Create a json web token
    final jwt = JWT(
      payload,
      issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
    );

    // Sign it (default with HS256 algorithm)
    // jwt.sign will populate iat
    final token = jwt.sign(SecretKey('secret passphrase'));
    return Future.value(token);
  }

  @override
  UserMetadata get metadata => _metadata ?? UserMetadata(0, 0);

  @override
  List<Object?> get props => [
        _isAnonymous,
        _uid,
        _email,
        _displayName,
        _phoneNumber,
        _photoURL,
        _refreshToken,
        _metadata,
      ];

  @override
  Future<void> reload() {
    // Do nothing.
    return Future.value();
  }

  @override
  Future<void> updateDisplayName(String? value) {
    displayName = value;
    return Future.value();
  }

  @override
  Future<void> updateEmail(String value) {
    _maybeThrowException();

    email = value;

    return Future.value();
  }

  @override
  Future<UserCredential> reauthenticateWithCredential(
      AuthCredential? credential) {
    _maybeThrowException();

    return Future.value(MockUserCredential(false, mockUser: this));
  }

  @override
  Future<void> updatePassword(String newPassword) {
    _maybeThrowException();

    // Do nothing.
    return Future.value();
  }

  @override
  Future<void> delete() {
    _maybeThrowException();

    // Do nothing.
    return Future.value();
  }

  @override
  Future<void> sendEmailVerification([
    ActionCodeSettings? actionCodeSettings,
  ]) {
    _maybeThrowException();

    // Do nothing
    return Future.value();
  }

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    _maybeThrowException();

    return Future.value(MockUserCredential(false, mockUser: this));
  }

  void _maybeThrowException() {
    if (_exception != null) {
      final exceptionCopy = _exception!;
      _exception = null;

      throw (exceptionCopy);
    }
  }

  MockUser copyWith({
    bool? isAnonymous,
    bool? isEmailVerified,
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    List<UserInfo>? providerData,
    String? refreshToken,
    UserMetadata? metadata,
    IdTokenResult? idTokenResult,
    DateTime? idTokenAuthTime,
    DateTime? idTokenExp,
    Map<String, dynamic>? customClaim,
  }) {
    return MockUser(
      isAnonymous: isAnonymous ?? _isAnonymous,
      isEmailVerified: isEmailVerified ?? _isEmailVerified,
      uid: uid ?? _uid,
      email: email ?? _email,
      displayName: displayName ?? _displayName,
      phoneNumber: phoneNumber ?? _phoneNumber,
      photoURL: photoURL ?? _photoURL,
      providerData: providerData ?? _providerData,
      refreshToken: refreshToken ?? _refreshToken,
      metadata: metadata ?? _metadata,
      idTokenResult: idTokenResult ?? _idTokenResult,
      idTokenAuthTime: idTokenAuthTime ?? _idTokenAuthTime,
      idTokenExp: idTokenExp ?? _idTokenExp,
      customClaim: customClaim ?? _customClaim,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
