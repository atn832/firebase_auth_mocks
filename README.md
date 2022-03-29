Mocks for [Firebase Auth](https://pub.dev/packages/firebase_auth). Use this package with [google_sign_in_mocks](https://pub.dev/packages/google_sign_in_mocks) to write unit tests involving Firebase Authentication.

## Usage

A simple usage example:

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
    `signInAnonymously` and `createUserWithEmailAndPassword` signs in.
  - `signOut` method.
  - `currentUser`
- `UserCredential` contains the provided `User` with the information of your choice.
- `User` supports:
  - `updateDisplayName`
  - `reauthenticateWithCredential`
  - `updatePassword`
  - `delete`
  - the ability to throw exceptions.

## Features and bugs

Please file feature requests and bugs at the issue tracker.
