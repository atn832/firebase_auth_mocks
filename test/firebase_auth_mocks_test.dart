import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';


void main() {
  test('Returns no user if not signed in', () async {
    final auth = MockFirebaseAuth();
    final user = await auth.currentUser();
    expect(user, isNull);
  });

  test('Returns a hardcoded user after sign in', () async {
    final auth = MockFirebaseAuth();
    // Credentials would typically come from GoogleSignIn.
    final credential = FakeAuthCredential();
    final result = await auth.signInWithCredential(credential);
    final user = await result.user;
    expect(user.uid, isNotEmpty);
    expect(user.displayName, isNotEmpty);
  });

  test('Returns a hardcoded user if already signed in', () async {
    final auth = MockFirebaseAuth(signedIn: true);
    final user = await auth.currentUser();
    expect(user.uid, isNotEmpty);
    expect(user.displayName, isNotEmpty);
  });

  // TODO
}

class FakeAuthCredential extends Mock implements AuthCredential {
}