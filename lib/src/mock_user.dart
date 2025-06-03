import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:uuid/uuid.dart';

class MockUser with EquatableMixin implements User {
  final bool _isAnonymous;
  final bool _isEmailVerified;
  final String _uid;
  final String? _email;
  String? _displayName;
  final String? _phoneNumber;
  String? _photoURL;
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

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  bool get emailVerified => _isEmailVerified;

  @override
  String get uid => _uid;

  @override
  String? get email => _email;

  @override
  String? get displayName => _displayName;

  set displayName(String? value) {
    _displayName = value;
  }

  @override
  String? get phoneNumber => _phoneNumber;

  @override
  String? get photoURL => _photoURL ?? 'https://i.stack.imgur.com/34AD2.jpg';

  set photoURL(String? value) {
    _photoURL = value;
  }

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
        IdTokenResult(PigeonIdTokenResult(
            authTimestamp: 1655946582,
            claims: _customClaim,
            expirationTimestamp: 1656305736,
            issuedAtTimestamp: 1656302136,
            token: 'fake_token',
            signInProvider: 'google.com'));
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
        providerData
      ];

  @override
  Future<void> reload() {
    maybeThrowException(this, Invocation.method(#reload, []));
    // Do nothing.
    return Future.value();
  }

  @override
  Future<void> updateDisplayName(String? value) {
    displayName = value;
    return Future.value();
  }

  @override
  Future<void> updatePhotoURL(String? value) {
    photoURL = value;
    return Future.value();
  }

  @override
  Future<UserCredential> reauthenticateWithCredential(
      AuthCredential? credential) {
    maybeThrowException(
        this, Invocation.method(#reauthenticateWithCredential, [credential]));

    return Future.value(MockUserCredential(false, mockUser: this));
  }

  @override
  Future<void> updatePassword(String newPassword) {
    maybeThrowException(
        this, Invocation.method(#updatePassword, [newPassword]));

    // Do nothing.
    return Future.value();
  }

  @override
  Future<void> delete() {
    maybeThrowException(this, Invocation.method(#delete, []));

    // Do nothing.
    return Future.value();
  }

  @override
  Future<void> sendEmailVerification([
    ActionCodeSettings? actionCodeSettings,
  ]) {
    maybeThrowException(
        this, Invocation.method(#sendEmailVerification, [actionCodeSettings]));

    // Do nothing
    return Future.value();
  }

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    maybeThrowException(
        this, Invocation.method(#linkWithCredential, [credential]));

    return Future.value(MockUserCredential(false, mockUser: this));
  }

  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async {
    if (providerData.any((info) => info.providerId == provider.providerId)) {
      throw FirebaseAuthException(
        code: 'provider-already-linked',
        message: 'User has already been linked to the given provider.',
      );
    }
    maybeThrowException(this, Invocation.method(#linkWithProvider, [provider]));
    providerData.add(
      UserInfo.fromPigeon(PigeonUserInfo(
          providerId: provider.providerId,
          isAnonymous: false,
          isEmailVerified: _isEmailVerified,
          uid: _uid)),
    );
    return Future.value(MockUserCredential(false, mockUser: this));
  }

  @override
  Future<User> unlink(String providerId) async {
    if (!providerData.any((info) => info.providerId == providerId)) {
      throw FirebaseAuthException(
        code: 'no-such-provider',
        message: 'User is not linked to the given provider.',
      );
    }
    maybeThrowException(this, Invocation.method(#unlink, [providerId]));
    providerData.removeWhere((info) => info.providerId == providerId);
    return Future.value(this);
  }

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail,
      [ActionCodeSettings? actionCodeSettings]) {
    maybeThrowException(
        this,
        Invocation.method(
            #verifyBeforeUpdateEmail, [newEmail, actionCodeSettings]));
    return Future.value();
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
