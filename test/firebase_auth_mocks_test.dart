import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:test/test.dart';

final tUser = MockUser(
  isAnonymous: false,
  uid: 'T3STU1D',
  email: 'bob@thebuilder.com',
  displayName: 'Bob Builder',
  phoneNumber: '0800 I CAN FIX IT',
  photoURL: 'http://photos.url/bobbie.jpg',
  refreshToken: 'some_long_token',
);

void main() {
  test('Returns no user if not signed in', () async {
    final auth = MockFirebaseAuth();
    final user = auth.currentUser;
    expect(user, isNull);
  });

  group('Returns a mocked user user after sign in', () {
    test('with Credential', () async {
      final auth = MockFirebaseAuth(mockUser: tUser);
      // Credentials would typically come from GoogleSignIn.
      final credential = FakeAuthCredential();
      final result = await auth.signInWithCredential(credential);
      final user = result.user!;
      expect(user, tUser);
      expect(auth.authStateChanges(), emitsInOrder([isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([isA<User>()]));
      expect(user.isAnonymous, isFalse);
    });

    test('with email and password', () async {
      final auth = MockFirebaseAuth(mockUser: tUser);
      final result = await auth.signInWithEmailAndPassword(email: 'some email', password: 'some password');
      final user = result.user;
      expect(user, tUser);
      expect(auth.authStateChanges(), emitsInOrder([isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([isA<User>()]));
    });

    test('with token', () async {
      final auth = MockFirebaseAuth(mockUser: tUser);
      final result = await auth.signInWithCustomToken('some token');
      final user = result.user;
      expect(user, tUser);
      expect(auth.authStateChanges(), emitsInOrder([isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([isA<User>()]));
    });

    test('with phone number', () async {
      final auth = MockFirebaseAuth(mockUser: tUser);
      final confirmationResult = await auth.signInWithPhoneNumber('832 234 5678');
      final credentials = await confirmationResult.confirm('12345');
      final user = credentials.user;
      expect(user, tUser);
      expect(auth.authStateChanges(), emitsInOrder([isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([isA<User>()]));
    });

    test('anonymously', () async {
      final auth = MockFirebaseAuth();
      final result = await auth.signInAnonymously();
      final user = result.user!;
      expect(user.uid, isNotEmpty);
      expect(auth.authStateChanges(), emitsInOrder([isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([isA<User>()]));
      expect(user.isAnonymous, isTrue);
    });
  });

  test('Returns a mocked user if already signed in', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;
    expect(user, tUser);
  });

  test('Returns a hardcoded user token', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser!;
    final idToken = await user.getIdToken();
    expect(idToken, isNotEmpty);
  });

  test('Returns null after sign out', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;

    await auth.signOut();

    expect(auth.currentUser, isNull);
    expect(auth.authStateChanges(), emitsInOrder([user, null]));
    expect(auth.userChanges(), emitsInOrder([user, null]));
  });
}

class FakeAuthCredential implements AuthCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
