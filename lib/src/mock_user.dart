import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockUser extends Mock implements User {
  final bool _isAnonymous;
  final String _uid;
  final String _email;
  final String _displayName;
  final String _phoneNumber;
  final String _photoURL;
  final String _refreshToken;

  MockUser({
    isAnonymous = false,
    uid = 'some_random_id',
    email,
    displayName,
    phoneNumber,
    photoURL,
    refreshToken,
  })  : _isAnonymous = isAnonymous,
        _uid = uid,
        _email = email,
        _displayName = displayName,
        _phoneNumber = phoneNumber,
        _photoURL = photoURL,
        _refreshToken = refreshToken;

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  String get uid => _uid;

  @override
  String get email => _email;

  @override
  String get displayName => _displayName;

  @override
  String get phoneNumber => _phoneNumber;

  @override
  String get photoURL => _photoURL;

  @override
  String get refreshToken => _refreshToken;

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    return Future.value('fake_token');
  }

  @override
  bool operator ==(o) =>
      o is User &&
      _isAnonymous == o.isAnonymous &&
      _uid == o.uid &&
      _email == o.email &&
      _displayName == o.displayName &&
      _phoneNumber == o.phoneNumber &&
      _photoURL == o.photoURL &&
      _refreshToken == o.refreshToken;

  @override
  int get hashCode =>
      _isAnonymous.hashCode ^
      _uid.hashCode ^
      _email.hashCode ^
      _displayName.hashCode ^
      _phoneNumber.hashCode ^
      _photoURL.hashCode ^
      _refreshToken.hashCode;
}
