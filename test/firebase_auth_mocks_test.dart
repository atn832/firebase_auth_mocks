import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  test('Returns no user if not signed in', () async {
    final auth = MockFirebaseAuth();
    final user = auth.currentUser;
    expect(user, isNull);
  });

  group('Returns a hardcoded user after sign in', () {
    test('with Credential', () async {
      final auth = MockFirebaseAuth();
      // Credentials would typically come from GoogleSignIn.
      final credential = FakeAuthCredential();
      final result = await auth.signInWithCredential(credential);
      final user = await result.user;
      expect(user.uid, isNotEmpty);
      expect(user.displayName, isNotEmpty);
      expect(auth.onAuthStateChanged, emitsInOrder([isA<User>()]));
      expect(user.isAnonymous, isFalse);
    });
  return;
    test('with email and password', () async {
      final auth = MockFirebaseAuth();
      final result = await auth.signInWithEmailAndPassword(
          email: 'some email', password: 'some password');
      final user = await result.user;
      expect(user.uid, isNotEmpty);
      expect(user.displayName, isNotEmpty);
      expect(auth.onAuthStateChanged, emitsInOrder([isA<User>()]));
    });

    test('with token', () async {
      final auth = MockFirebaseAuth();
      final result = await auth.signInWithCustomToken('some token');
      final user = await result.user;
      expect(user.uid, isNotEmpty);
      expect(user.displayName, isNotEmpty);
      expect(auth.onAuthStateChanged, emitsInOrder([isA<User>()]));
    });

    test('anonymously', () async {
      final auth = MockFirebaseAuth();
      final result = await auth.signInAnonymously();
      final user = await result.user;
      expect(user.uid, isNotEmpty);
      expect(auth.onAuthStateChanged, emitsInOrder([isA<User>()]));
      expect(user.isAnonymous, isTrue);
    });
  });

  test('Returns a hardcoded user if already signed in', () async {
    final auth = MockFirebaseAuth(signedIn: true);
    final user = auth.currentUser;
    expect(user.uid, isNotEmpty);
    expect(user.displayName, isNotEmpty);
  });

  test('Returns a hardcoded user token', () async {
    final auth = MockFirebaseAuth(signedIn: true);
    final user = auth.currentUser;
    final idToken = await user.getIdToken();
    expect(idToken, isNotEmpty);
  });

  test('Returns null after sign out', () async {
    final auth = MockFirebaseAuth(signedIn: true);
    final user = auth.currentUser;

    await auth.signOut();

    expect(auth.currentUser, isNull);
    expect(auth.onAuthStateChanged, emitsInOrder([user, null]));
  });
}

class FakeAuthCredential extends Mock implements AuthCredential {}
