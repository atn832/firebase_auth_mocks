import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

import 'mock_user.dart';

class MockUserCredential extends Mock implements UserCredential {
  @override
  User user = MockUser();
}
