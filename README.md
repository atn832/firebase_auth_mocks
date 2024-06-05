# Firebase Auth Mocks

[![pub package](https://img.shields.io/pub/v/firebase_auth_mocks.svg)](https://pub.dartlang.org/packages/firebase_auth_mocks)
[![Unit Tests](https://github.com/atn832/firebase_auth_mocks/actions/workflows/unit-tests.yaml/badge.svg)](https://github.com/atn832/firebase_auth_mocks/actions/workflows/unit-tests.yaml)
<a href="https://www.buymeacoffee.com/anhtuann" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="30px" width= "108px"></a>

Mocks for [Firebase Auth](https://pub.dev/packages/firebase_auth). Use this package with [google_sign_in_mocks](https://pub.dev/packages/google_sign_in_mocks) to write unit tests involving Firebase Authentication.

## Usage

A simple usage example. Add firebase_auth_mocks and google_sign_in_mocks to dev dependencies.

```dart
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';

main() {
    // Mock sign in with Google.
    final googleSignIn = MockGoogleSignIn();
    final signinAccount = await googleSignIn.signIn();
    final googleAuth = await signinAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // Sign in.
    final user = MockUser(
      isAnonymous: false,
      uid: 'someuid',
      email: 'bob@somedomain.com',
      displayName: 'Bob',
    );
    final auth = MockFirebaseAuth(mockUser: user);
    final result = await auth.signInWithCredential(credential);
    final user = await result.user;
    print(user.displayName);
}
```

## Features

- `MockFirebaseAuth` supports:
  - instantiating in a signed-in state or not: `MockFirebaseAuth(signedIn: true/false)`.
  - firing events on sign-in to `authStateChanges` and `userChanges`.
  - `signInWithCredential`, `signInWithEmailAndPassword`, `signInWithCustomToken`,
    `signInAnonymously`, `createUserWithEmailAndPassword`, `signInWithPopup` and `signInWithProvider` signs in.
  - `sendSignInLinkToEmail`, `confirmPasswordReset` and `verifyPasswordResetCode`.
  - `verifyPhoneNumber` resolves `codeSent`.
  - `signOut`
  - `sendPasswordResetEmail`
  - `fetchSignInMethodsForEmail`
  - `currentUser`
  - the ability to throw exceptions using `whenCalling(...).on(...).thenThrow(...)`. See details below.
  - pass auth information (uid, custom claims...) to Fake Cloud Firestore for security rules via `authForFakeFirestore`. See the docs at [fake_cloud_firestore](https://pub.dev/packages/fake_cloud_firestore#security-rules) for usage.
- `UserCredential` contains the provided `User` with the information of your choice.
- `User` supports:
  - `updateDisplayName`
  - `reauthenticateWithCredential`
  - `updatePassword`
  - `delete`
  - `sendEmailVerification`
  - `getIdToken` and `getIdTokenResult`
  - the ability to throw exceptions.

## Throwing exceptions

### Regardless of the parameters

```dart
whenCalling(Invocation.method(#signInWithCredential, null))
  .on(auth)
  .thenThrow(FirebaseAuthException(code: 'bla'));
expect(
  () => auth.signInWithCredential(FakeAuthCredential()),
  throwsA(isA<FirebaseAuthException>()),
);
```

### Depending on positional parameters

#### Equality

```dart
final auth = MockFirebaseAuth();
whenCalling(Invocation.method(
        #fetchSignInMethodsForEmail, ['someone@somewhere.com']))
    .on(auth)
    .thenThrow(FirebaseAuthException(code: 'bla'));
expect(() => auth.fetchSignInMethodsForEmail('someone@somewhere.com'),
    throwsA(isA<FirebaseAuthException>()));
expect(() => auth.fetchSignInMethodsForEmail('someoneelse@somewhereelse.com'),
    returnsNormally);
```

#### Using any other matcher

Supports all of the matchers from the [Dart matchers library](https://api.flutter.dev/flutter/package-matcher_matcher/package-matcher_matcher-library.html#functions).

```dart
final auth = MockFirebaseAuth();
whenCalling(Invocation.method(
        #fetchSignInMethodsForEmail, [endsWith('@somewhere.com')]))
    .on(auth)
    .thenThrow(FirebaseAuthException(code: 'bla'));
expect(() => auth.fetchSignInMethodsForEmail('someone@somewhere.com'),
    throwsA(isA<FirebaseAuthException>()));
expect(() => auth.fetchSignInMethodsForEmail('someoneelse@somewhereelse.com'),
    returnsNormally);
```

### Depending on named parameters

You can match some or all named parameters. If you omit a named parameter, the library matches it against `anything`.

In this example, it will throw an exception if the `code` contains the String 'code', no matter the value of `newPassword`.

```dart
whenCalling(Invocation.method(
          #confirmPasswordReset, null, {#code: contains('code')}))
      .on(auth)
      .thenThrow(FirebaseAuthException(code: 'invalid-action-code'));
  expect(
    () async => await auth.confirmPasswordReset(
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
```

## Compatibility table

| firebase_auth | firebase_auth_mocks |
|---------------|---------------------|
| 5.0.0         | 0.14.0              |
| 4.0.0         | 0.9.0               |
| 3.5.0         | 0.8.7               |

## Features and bugs

Please file feature requests and bugs at the issue tracker.
