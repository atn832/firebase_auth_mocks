import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:test/test.dart';

final userIdTokenResult = IdTokenResult({
  'authTimestamp': DateTime.now().millisecondsSinceEpoch,
  'claims': {'role': 'admin'},
  'token': 'some_long_token',
  'expirationTime':
      DateTime.now().add(Duration(days: 1)).millisecondsSinceEpoch,
  'issuedAtTimestamp':
      DateTime.now().subtract(Duration(days: 1)).millisecondsSinceEpoch,
  'signInProvider': 'phone',
});

final tUser = MockUser(
  isAnonymous: false,
  uid: 'T3STU1D',
  email: 'bob@thebuilder.com',
  displayName: 'Bob Builder',
  phoneNumber: '0800 I CAN FIX IT',
  photoURL: 'http://photos.url/bobbie.jpg',
  refreshToken: 'some_long_token',
  idTokenResult: userIdTokenResult,
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

  group('Returns a mocked user user after sign up', () {
    test('with email and password', () async {
      final email = 'some@email.com';
      final password = 'some!password';
      final auth = MockFirebaseAuth();
      final result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = result.user!;
      expect(user.email, email);
      expect(auth.authStateChanges(), emitsInOrder([null, isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([null, isA<User>()]));
      expect(user.isAnonymous, isFalse);
    });
  });

  group('Returns a mocked user after sign in', () {
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

    test('should send sms code to user', () async {
      final auth = MockFirebaseAuth();
      final codeSent = Completer<bool>();
      // currently does not auto retrieve the sms code like it does on Android
      // it is left to the user to use the code to sign in, so we encompass
      // every platform
      await auth.verifyPhoneNumber(
        phoneNumber: '+1 832 234 5678',
        verificationCompleted: (_) {},
        verificationFailed: (_) {},
        codeSent: (_, __) => codeSent.complete(true),
        codeAutoRetrievalTimeout: (_) {},
      );
      final wasCodeSent = await codeSent.future;
      expect(wasCodeSent, isTrue);
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

  test('Returns a hardcoded user token result', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser!;
    final idTokenResult = await user.getIdTokenResult();
    expect(idTokenResult, isNotNull);
    expect(
      idTokenResult.toString(),
      equals(userIdTokenResult.toString()),
    );
  });

  test('Returns null after sign out', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;

    await auth.signOut();

    expect(auth.currentUser, isNull);
    expect(auth.authStateChanges(), emitsInOrder([user, null]));
    expect(auth.userChanges(), emitsInOrder([user, null]));
  });

  test('sendPasswordResetEmail works', () async {
    final auth = MockFirebaseAuth();

    expect(
      () async => await auth.sendPasswordResetEmail(email: ''),
      returnsNormally,
    );
  });

  test('should send verification email', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;
    expect(user?.sendEmailVerification(), completes);
  });

  test('sendSignInLinkToEmail works', () async {
    final auth = MockFirebaseAuth();

    expect(
      () async => await auth.sendSignInLinkToEmail(
        email: 'test@example.com',
        actionCodeSettings: ActionCodeSettings(
          url: 'https://example.com',
          handleCodeInApp: true,
        ),
      ),
      returnsNormally,
    );
  });

  test(
    'sendSignInLinkToEmail throws ArgumentError if ActionCodeSettings.handleCodeInApp is not true',
    () async {
      final auth = MockFirebaseAuth();

      expect(
        () async => await auth.sendSignInLinkToEmail(
          email: 'test@example.com',
          actionCodeSettings: ActionCodeSettings(
            url: 'https://example.com',
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () async => await auth.sendSignInLinkToEmail(
          email: 'test@example.com',
          actionCodeSettings: ActionCodeSettings(
            url: 'https://example.com',
            handleCodeInApp: false,
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    },
  );

  test('confirmPasswordReset works', () async {
    final auth = MockFirebaseAuth();

    expect(
      () async => await auth.confirmPasswordReset(
        code: 'code',
        newPassword: 'password',
      ),
      returnsNormally,
    );
  });

  test('verifyPasswordResetCode returns MockUser.email', () async {
    final mockUser = MockUser(email: 'email@gmail.com');
    final auth = MockFirebaseAuth(mockUser: mockUser);

    expect(
      await auth.verifyPasswordResetCode('code'),
      equals(mockUser.email),
    );
  });

  test(
    'verifyPasswordResetCode returns hardcoded email without mockUser',
    () async {
      final mockUser = MockUser(email: 'email@gmail.com');
      final auth = MockFirebaseAuth(mockUser: mockUser);

      expect(
        await auth.verifyPasswordResetCode('code'),
        isNotEmpty,
      );
    },
  );

  group('exceptions', () {
    test('signInWithCredential', () async {
      final auth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInWithCredential: FirebaseAuthException(code: 'bla'),
        ),
      );
      expect(
        () async => await auth.signInWithCredential(FakeAuthCredential()),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signInWithEmailAndPassword', () async {
      final auth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInWithEmailAndPassword: FirebaseAuthException(code: 'bla'),
        ),
      );
      expect(
        () async =>
            await auth.signInWithEmailAndPassword(email: '', password: ''),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('createUserWithEmailAndPassword', () async {
      final auth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          createUserWithEmailAndPassword: FirebaseAuthException(code: 'bla'),
        ),
      );
      expect(
        () async =>
            await auth.createUserWithEmailAndPassword(email: '', password: ''),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signInWithCustomToken', () async {
      final auth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInWithCustomToken: FirebaseAuthException(code: 'bla'),
        ),
      );
      expect(
        () async => await auth.signInWithCustomToken(''),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signInAnonymously', () async {
      final auth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInAnonymously: FirebaseAuthException(code: 'bla'),
        ),
      );
      expect(
        () async => await auth.signInAnonymously(),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('fetchSignInMethodsForEmail', () async {
      final auth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
            fetchSignInMethodsForEmail: FirebaseAuthException(code: 'bla')),
      );
      expect(
        () async => await auth.fetchSignInMethodsForEmail(''),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('sendPasswordResetEmail', () async {
      final auth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          sendPasswordResetEmail: FirebaseAuthException(code: 'invalid-email'),
        ),
      );

      expect(
        () async => await auth.sendPasswordResetEmail(email: ''),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('sendSignInLinkToEmail', () async {
      final auth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          sendSignInLinkToEmail: FirebaseAuthException(code: 'invalid-email'),
        ),
      );

      expect(
        () async => await auth.sendSignInLinkToEmail(
          email: 'test@example.com',
          actionCodeSettings: ActionCodeSettings(
            url: 'https://example.com',
            handleCodeInApp: true,
          ),
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('confirmPasswordReset', () async {
      final auth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          confirmPasswordReset:
              FirebaseAuthException(code: 'invalid-action-code'),
        ),
      );

      expect(
        () async => await auth.confirmPasswordReset(
          code: 'code',
          newPassword: 'password',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('verifyPasswordResetCode', () async {
      final auth = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          verifyPasswordResetCode:
              FirebaseAuthException(code: 'invalid-action-code'),
        ),
      );

      expect(
        () async => await auth.verifyPasswordResetCode('code'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
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
    await user!.updateDisplayName('New Bob');
    expect(user.displayName, 'New Bob');
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

  test('User.sendEmailVerification can throw exception', () async {
    final auth = MockFirebaseAuth(mockUser: tUser, signedIn: true);
    tUser.exception = FirebaseAuthException(code: 'verification-failure');
    final user = auth.currentUser;
    expect(
      () async => await user?.sendEmailVerification(),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('Listening twice works', () async {
    final auth = MockFirebaseAuth();
    expect(await auth.userChanges().first, isNull);
    // Fire a second event.
    await auth.signOut();
    expect(await auth.userChanges().first, isNull);
  });

  test('$AuthExceptions ensure equality', () {
    final authExceptions1 = AuthExceptions();
    final authExceptions2 = AuthExceptions();
    expect(authExceptions1, authExceptions2);
  });

  test('Id token contains user data', () async {
    final idToken = await tUser.getIdToken();
    final decodedToken = JwtDecoder.decode(idToken);
    expect(decodedToken['name'], tUser.displayName);
    expect(decodedToken['picture'], tUser.photoURL);
    expect(decodedToken['user_id'], tUser.uid);
    expect(decodedToken['sub'], tUser.uid);
    expect(decodedToken['email'], tUser.email);
    expect(decodedToken['email_verified'], tUser.emailVerified);
  });

  test('Id token contains user data when using default value', () async {
    final user = MockUser();
    final idToken = await user.getIdToken();
    final decodedToken = JwtDecoder.decode(idToken);
    expect(decodedToken['name'], user.displayName);
    expect(decodedToken['picture'], user.photoURL);
    expect(decodedToken['user_id'], user.uid);
    expect(decodedToken['sub'], user.uid);
    expect(decodedToken['email'], user.email);
    expect(decodedToken['email_verified'], user.emailVerified);
  });

  test('getIdToken still works when using the default value', () async {
    final idToken = await MockUser().getIdToken();
    final decodedToken = JwtDecoder.decode(idToken);
    expect(decodedToken['name'] != null, true);
    expect(decodedToken['picture'] != null, true);
    expect(decodedToken['user_id'] != null, true);
    expect(decodedToken['sub'] != null, true);
    expect(decodedToken['email'] != null, true);
    expect(decodedToken['email_verified'] != null, true);
  });

  test('Each decoded token\'s user_id should not change', () async {
    final user = MockUser();
    final idToken1 = await user.getIdToken();
    final decodedToken1 = JwtDecoder.decode(idToken1);
    final idToken2 = await user.getIdToken();
    final decodedToken2 = JwtDecoder.decode(idToken2);
    expect(decodedToken1['user_id'], decodedToken2['user_id']);
  });

  test('Each edecoded token\'s user_id should unique', () async {
    final user1 = MockUser();
    final user2 = MockUser();
    final idToken1 = await user1.getIdToken();
    final decodedToken1 = JwtDecoder.decode(idToken1);
    final idToken2 = await user2.getIdToken();
    final decodedToken2 = JwtDecoder.decode(idToken2);
    expect(decodedToken1['user_id'] is String, true);
    expect(decodedToken2['user_id'] is String, true);
    expect(decodedToken1['user_id'] != decodedToken2['user_id'], true);
  });

  test('getIdTokenResult still works when using the default value', () async {
    final idTokenResult = await MockUser().getIdTokenResult();
    expect(idTokenResult.authTime, isNotNull);
    expect(idTokenResult.claims, isNotNull);
    expect(idTokenResult.expirationTime, isNotNull);
    expect(idTokenResult.issuedAtTime, isNotNull);
    expect(idTokenResult.signInProvider, isNotNull);
    expect(idTokenResult.token, isNotNull);
  });
}

class FakeAuthCredential implements AuthCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
