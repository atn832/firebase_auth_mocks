import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockUser with EquatableMixin implements User {
  final bool? _isAnonymous;
  final String _uid;
  final String? _email;
  final String? _displayName;
  final String? _phoneNumber;
  final String? _photoURL;
  final String? _refreshToken;

  MockUser({
    bool? isAnonymous = false,
    String uid = 'some_random_id',
    String? email,
    String? displayName,
    String? phoneNumber,
    String? photoURL,
    String? refreshToken,
  })  : _isAnonymous = isAnonymous,
        _uid = uid,
        _email = email,
        _displayName = displayName,
        _phoneNumber = phoneNumber,
        _photoURL = photoURL,
        _refreshToken = refreshToken;

  @override
  bool get isAnonymous => _isAnonymous!;

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
  List<Object?> get props => [
        _isAnonymous,
        _uid,
        _email,
        _displayName,
        _phoneNumber,
        _photoURL,
        _refreshToken,
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
