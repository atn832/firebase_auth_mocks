import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

import 'mock_firebase_user.dart';

class MockAuthResult extends Mock implements AuthResult {
  @override
  FirebaseUser user = MockFirebaseUser();
}
