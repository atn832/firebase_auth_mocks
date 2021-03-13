import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockConfirmationResult extends Mock implements ConfirmationResult {
  Function onConfirm;

  MockConfirmationResult({required this.onConfirm});

  @override
  Future<UserCredential> confirm(String verificationCode) {
    return onConfirm();
  }
}
