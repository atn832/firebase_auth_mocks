import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockIdTokenResult extends Mock implements IdTokenResult {
  @override
  String get token => 'fake_token';
}
