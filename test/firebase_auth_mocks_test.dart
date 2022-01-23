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

  group('Emits an initial User? on startup.', () {
    test('null if signed out', () async {
      final auth = MockFirebaseAuth();
      expect(auth.authStateChanges(), emits(null));
      // expect(auth.userChanges(), emitsInOrder([isA<User>()]));
    });
    test('a user if signed in', () async {
      final auth = MockFirebaseAuth(signedIn: true);
      expect(auth.authStateChanges(), emitsInOrder([isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([isA<User>()]));
    });
  });

  group('Returns a mocked user user after sign in', () {
    test('with Credential', () async {
      final auth = MockFirebaseAuth(mockUser: tUser);
      // Credentials would typically come from GoogleSignIn.
      final credential = FakeAuthCredential();
      final result = await auth.signInWithCredential(credential);
      final user = result.user!;
      expect(user, tUser);
      expect(auth.authStateChanges(), emitsInOrder([null, isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([null, isA<User>()]));
      expect(user.isAnonymous, isFalse);
    });

    test('with email and password', () async {
      final auth = MockFirebaseAuth(mockUser: tUser);
      final result = await auth.signInWithEmailAndPassword(
          email: 'some email', password: 'some password');
      final user = result.user;
      expect(user, tUser);
      expect(auth.authStateChanges(), emitsInOrder([null, isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([null, isA<User>()]));
    });

    test('with token', () async {
      final auth = MockFirebaseAuth(mockUser: tUser);
      final result = await auth.signInWithCustomToken('some token');
      final user = result.user;
      expect(user, tUser);
      expect(auth.authStateChanges(), emitsInOrder([null, isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([null, isA<User>()]));
    });

    test('with phone number', () async {
      final auth = MockFirebaseAuth(mockUser: tUser);
      final confirmationResult =
          await auth.signInWithPhoneNumber('832 234 5678');
      final credentials = await confirmationResult.confirm('12345');
      final user = credentials.user;
      expect(user, tUser);
      expect(auth.authStateChanges(), emitsInOrder([null, isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([null, isA<User>()]));
    });

    test('anonymously', () async {
      final auth = MockFirebaseAuth();
      final result = await auth.signInAnonymously();
      final user = result.user!;
      expect(user.uid, isNotEmpty);
      expect(auth.authStateChanges(), emitsInOrder([null, isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([null, isA<User>()]));
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

  test('User.reload returns', () async {
    final auth = MockFirebaseAuth(signedIn: true);
    final user = auth.currentUser;
    expect(user, isNotNull);
    // Does not throw an exception.
    await user!.reload();
  });

  test('User.updateDisplayName changes displayName', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;
    await user!.updateDisplayName("New Bob");
    expect(user.displayName, "New Bob");
  });

  test('User.reauthenticateWithCredential works', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;
    expect(
      () async => await user!.reauthenticateWithCredential(
          AuthCredential(signInMethod: '', providerId: '')),
      returnsNormally,
    );
  });

  test('User.reauthenticateWithCredential can throw exception', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    tUser.exception = FirebaseAuthException(code: 'wrong-password');
    final user = auth.currentUser;
    expect(
      () async => await user!.reauthenticateWithCredential(
          AuthCredential(signInMethod: '', providerId: '')),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('User.updatePassword works', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;
    expect(
      () async => await user!.updatePassword('newPassword'),
      returnsNormally,
    );
  });

  test('User.updatePassword can throw exception', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    tUser.exception = FirebaseAuthException(code: 'weak-password');
    final user = auth.currentUser;
    expect(
      () async => await user!.updatePassword('newPassword'),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('User.delete works', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;
    expect(
      () async => await user!.delete(),
      returnsNormally,
    );
  });

  test('User.delete can throw exception', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    tUser.exception = FirebaseAuthException(code: 'wrong-password');
    final user = auth.currentUser;
    expect(
      () async => await user!.delete(),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('Listening twice works', () async {
    final auth = MockFirebaseAuth();
    expect(await auth.userChanges().first, isNull);
    expect(await auth.userChanges().first, isNull);
  });
}

class FakeAuthCredential implements AuthCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
