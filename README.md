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
    final auth = MockFirebaseAuth();
    final result = await auth.signInWithCredential(credential);
    final user = await result.user;
    print(user.displayName);
}
```

## Features

- `MockFirebaseAuth` supports:
  - instantiating in a signed-in state or not: `MockFirebaseAuth(signedIn: true/false)`.
  - firing events on sign-in to `onAuthStateChanged`.
  - `signInWithCredential`, `signInWithEmailAndPassword`, `signInWithEmailAndLink` or `signInWithCustomToken` signs in.
  - `currentUser`
- `AuthResult` contains a hard-coded `FirebaseUser`.
- `FirebaseUser` supports `displayName`, `uid` and `getIdToken`.
- `IdTokenResult` supports `token`.

## Features and bugs

Please file feature requests and bugs at the issue tracker.
