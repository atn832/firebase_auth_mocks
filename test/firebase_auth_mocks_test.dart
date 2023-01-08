import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
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
    test('with popup', () async {
      final auth = MockFirebaseAuth(mockUser: tUser);
      final result = await auth.signInWithPopup(AppleAuthProvider());
      final user = result.user!;
      expect(user, tUser);
      expect(auth.authStateChanges(), emitsInOrder([null, isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([null, isA<User>()]));
      expect(user.isAnonymous, false);
    });

    test('with Provider', () async {
      final auth = MockFirebaseAuth(mockUser: tUser);
      final result = await auth.signInWithProvider(AppleAuthProvider());
      final user = result.user!;
      expect(user, tUser);
      expect(auth.authStateChanges(), emitsInOrder([null, isA<User>()]));
      expect(auth.userChanges(), emitsInOrder([null, isA<User>()]));
      expect(user.isAnonymous, false);
    });

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

  test('Returns a mocked anonymous user if already signed in', () {
    var anonymousUser = MockUser(isAnonymous: true, uid: 'T3STU1D');
    final auth = MockFirebaseAuth(signedIn: true, mockUser: anonymousUser);
    final user = auth.currentUser;
    expect(user, anonymousUser);
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
    // Using IdTokenResult's implementation of toString
    // https://github.com/firebase/flutterfire/blob/982bdfb5fbfae4a68e1af6ab62a9bd762891b217/packages/firebase_auth/firebase_auth_platform_interface/lib/src/id_token_result.dart#L53
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
      () => auth.sendPasswordResetEmail(email: ''),
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
      () => auth.sendSignInLinkToEmail(
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
        () => auth.sendSignInLinkToEmail(
          email: 'test@example.com',
          actionCodeSettings: ActionCodeSettings(
            url: 'https://example.com',
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => auth.sendSignInLinkToEmail(
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
      () => auth.confirmPasswordReset(
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

  test('should link credentials', () {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;
    final credential =
        AuthCredential(providerId: 'providerId', signInMethod: 'signInMethod');
    expect(user?.linkWithCredential(credential), completes);
  });

  group('exceptions', () {
    test('signInWithPopup', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInWithPopup, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'red'));
      expect(
        () => auth.signInWithPopup(AppleAuthProvider()),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signInWithProvider', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInWithProvider, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'veronica'));
      expect(
        () => auth.signInWithProvider(AppleAuthProvider()),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signInWithCredential', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInWithCredential, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'bla'));
      expect(
        () => auth.signInWithCredential(FakeAuthCredential()),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signInWithEmailAndPassword', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'veronica'));
      expect(
        () => auth.signInWithEmailAndPassword(email: '', password: ''),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('createUserWithEmailAndPassword', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'bla'));
      expect(
        () => auth.createUserWithEmailAndPassword(email: '', password: ''),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signInWithCustomToken', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInWithCustomToken, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'bla'));
      expect(
        () => auth.signInWithCustomToken(''),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('signInAnonymously', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInAnonymously, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'bla'));
      expect(
        () => auth.signInAnonymously(),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('fetchSignInMethodsForEmail', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(
              #fetchSignInMethodsForEmail, ['someone@somewhere.com']))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'bla'));
      expect(() => auth.fetchSignInMethodsForEmail('someone@somewhere.com'),
          throwsA(isA<FirebaseAuthException>()));
      expect(
          () =>
              auth.fetchSignInMethodsForEmail('someoneelse@somewhereelse.com'),
          returnsNormally);
    });

    test('sendPasswordResetEmail', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#sendPasswordResetEmail, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'invalid-email'));

      expect(
        () => auth.sendPasswordResetEmail(email: ''),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    test('sendSignInLinkToEmail', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#sendSignInLinkToEmail, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'invalid-email'));

      expect(
        () => auth.sendSignInLinkToEmail(
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
      final auth = MockFirebaseAuth();

      whenCalling(Invocation.method(
              #confirmPasswordReset, null, {#code: contains('code')}))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'invalid-action-code'));
      expect(
        () => auth.confirmPasswordReset(
          code: 'code',
          newPassword: 'password',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(
          () => auth.confirmPasswordReset(
                code: '10293',
                newPassword: 'password',
              ),
          returnsNormally);
    });

    test('verifyPasswordResetCode', () async {
      final auth = MockFirebaseAuth();
      whenCalling(Invocation.method(#verifyPasswordResetCode, null))
          .on(auth)
          .thenThrow(FirebaseAuthException(code: 'invalid-action-code'));

      expect(
        () => auth.verifyPasswordResetCode('code'),
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
      () => user!.reauthenticateWithCredential(
          AuthCredential(signInMethod: '', providerId: '')),
      returnsNormally,
    );
  });

  test('User.reauthenticateWithCredential can throw exception', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    tUser.exception = FirebaseAuthException(code: 'wrong-password');
    final user = auth.currentUser;
    expect(
      () => user!.reauthenticateWithCredential(
          AuthCredential(signInMethod: '', providerId: '')),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('User.updatePassword works', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;
    expect(
      () => user!.updatePassword('newPassword'),
      returnsNormally,
    );
  });

  test('User.updatePassword can throw exception', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    tUser.exception = FirebaseAuthException(code: 'weak-password');
    final user = auth.currentUser;
    expect(
      () => user!.updatePassword('newPassword'),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('User.delete works', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;
    expect(
      () => user!.delete(),
      returnsNormally,
    );
  });

  test('User.delete can throw exception', () async {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    tUser.exception = FirebaseAuthException(code: 'wrong-password');
    final user = auth.currentUser;
    expect(
      () => user!.delete(),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('User.sendEmailVerification can throw exception', () async {
    final auth = MockFirebaseAuth(mockUser: tUser, signedIn: true);
    tUser.exception = FirebaseAuthException(code: 'verification-failure');
    final user = auth.currentUser;
    expect(
      () => user?.sendEmailVerification(),
      throwsA(isA<FirebaseAuthException>()),
    );
  });

  test('User.linkWithCredential can throw exception', () {
    final auth = MockFirebaseAuth(signedIn: true, mockUser: tUser);
    final user = auth.currentUser;
    final credential =
        AuthCredential(providerId: 'providerId', signInMethod: 'signInMethod');
    tUser.exception = FirebaseAuthException(code: 'verification-failure');
    expect(
      () => user?.linkWithCredential(credential),
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

  test('Each decoded token\'s user_id should not change', () async {
    final user = MockUser();
    final idToken1 = await user.getIdToken();
    final decodedToken1 = JwtDecoder.decode(idToken1);
    final idToken2 = await user.getIdToken();
    final decodedToken2 = JwtDecoder.decode(idToken2);
    expect(decodedToken1['user_id'], decodedToken2['user_id']);
  });

  test('Each decoded token\'s user_id should unique', () async {
    final user1 = MockUser();
    final user2 = MockUser();
    final idToken1 = await user1.getIdToken();
    final decodedToken1 = JwtDecoder.decode(idToken1);
    final idToken2 = await user2.getIdToken();
    final decodedToken2 = JwtDecoder.decode(idToken2);
    expect(decodedToken1['user_id'], isA<String>());
    expect(decodedToken2['user_id'], isA<String>());
    expect(decodedToken1['user_id'], isNot(decodedToken2['user_id']));
  });

  test(
      'Each decoded token\'s auth_time and exp should be the time in seconds since unix epoch',
      () async {
    final idToken = await tUser.getIdToken();
    final decodedToken = JwtDecoder.decode(idToken);
    final isTimeInSecondsSinceUnixEpoch = predicate(
      (dynamic number) => number is int && number.toString().length == 10,
      'is time in seconds since unix epoch',
    );
    expect(decodedToken['auth_time'], isTimeInSecondsSinceUnixEpoch);
    expect(decodedToken['exp'], isTimeInSecondsSinceUnixEpoch);
  });

  test(
      'The decodedToken\'s auth_time and exp should as same as user.idTokenAuthTime after modify MockUser',
      () async {
    final customAuthTime = DateTime.parse('2020-01-01');
    final customExp = DateTime.parse('2020-01-02');
    final user = MockUser(
      idTokenAuthTime: customAuthTime,
      idTokenExp: customExp,
    );
    final idToken = await user.getIdToken();
    final decodedToken = JwtDecoder.decode(idToken);
    expect(decodedToken['auth_time'],
        customAuthTime.millisecondsSinceEpoch ~/ 1000);
    expect(decodedToken['exp'], customExp.millisecondsSinceEpoch ~/ 1000);
  });

  test('Set up fetchSignInMethodsForEmail results', () async {
    final auth = MockFirebaseAuth(
      signInMethodsForEmail: {
        'test@example.com': ['password']
      },
    );
    expect(await auth.fetchSignInMethodsForEmail('test@example.com'),
        equals(['password']));
  });

  test('Add customClaim into id token', () async {
    final user = MockUser(customClaim: {'role': 'admin', 'bodyHeight': 169});
    final idToken = await user.getIdToken();
    final decodedToken = JwtDecoder.decode(idToken);
    expect(decodedToken['role'], 'admin');
    expect(decodedToken['bodyHeight'], 169);
  });

  test('The customClain should exist after sign-out and sign-in', () async {
    final auth = MockFirebaseAuth(
      mockUser: MockUser(customClaim: {'role': 'admin', 'bodyHeight': 169}),
      signedIn: true,
    );
    final decodedToken =
        JwtDecoder.decode(await auth.currentUser!.getIdToken());
    expect(decodedToken['role'], 'admin');
    expect(decodedToken['bodyHeight'], 169);
    await auth.signOut();
    await auth.signInWithEmailAndPassword(email: '', password: '');
    final decodedToken2 =
        JwtDecoder.decode(await auth.currentUser!.getIdToken());
    expect(decodedToken2['role'], 'admin');
    expect(decodedToken2['bodyHeight'], 169);
  });

  test('update firebaseAuth user customClaim by copyWith', () async {
    final auth = MockFirebaseAuth(
      signedIn: true,
    );
    final decodedToken =
        JwtDecoder.decode(await auth.currentUser!.getIdToken());
    expect(decodedToken['role'], null);
    expect(decodedToken['bodyHeight'], null);

    auth.mockUser = (auth.currentUser as MockUser)
        .copyWith(customClaim: {'role': 'admin', 'bodyHeight': 169});

    final decodedToken2 =
        JwtDecoder.decode(await auth.currentUser!.getIdToken());
    expect(decodedToken2['role'], 'admin');
    expect(decodedToken2['bodyHeight'], 169);
  });

  group('MockUser', () {
    test('when default constructor, expect defaults', () {
      final user = MockUser();
      expect(user.isAnonymous, isFalse);
      expect(user.emailVerified, isTrue);
      expect(user.uid, isNotNull);
      expect(user.email, isNull);
    });
  });

  test('app', () {
    expect(MockFirebaseAuth().app, isNotNull);
  });
}

class FakeAuthCredential implements AuthCredential {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
