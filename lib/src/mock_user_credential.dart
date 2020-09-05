import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

import 'mock_user.dart';

class MockUserCredential extends Mock implements UserCredential {
  final bool _isAnonymous;

  MockUserCredential({bool isAnonymous}) : _isAnonymous = isAnonymous;

  @override
  User get user => MockUser(isAnonymous: _isAnonymous);
}
