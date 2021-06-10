import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockUser with EquatableMixin implements User {
  final bool _isAnonymous;
  final bool _isEmailVerified;
  final String _uid;
  final String? _email;
  final String? _displayName;
  final String? _phoneNumber;
  final String? _photoURL;
  final String? _refreshToken;
  final UserMetadata? _metadata;

  MockUser({
    bool isAnonymous = false,
    bool isEmailVerified = true,
    String uid = 'some_random_id',
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    String? refreshToken,
    UserMetadata? metadata,
  })  : _isAnonymous = isAnonymous,
        _isEmailVerified = isEmailVerified,
        _uid = uid,
        _email = email,
        _displayName = displayName,
        _phoneNumber = phoneNumber,
        _photoURL = photoURL,
        _refreshToken = refreshToken,
        _metadata = metadata;

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

  @override
  String? get phoneNumber => _phoneNumber;

  @override
  String? get photoURL => _photoURL;

  @override
  String? get refreshToken => _refreshToken;

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    return Future.value('fake_token');
  }

  @override
  UserMetadata get metadata => _metadata!;

  @override
  List<Object?> get props => [
        _isAnonymous,
        _uid,
        _email,
        _displayName,
        _phoneNumber,
        _photoURL,
        _refreshToken,
        metadata,
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
