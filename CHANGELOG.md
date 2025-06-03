## 0.14.2

- Adds a maybeThrow into `verifyPhoneNumber` and `User.verifyBeforeUpdateEmail`. [PR-113](https://github.com/atn832/firebase_auth_mocks/pull/113), [PR-116](https://github.com/atn832/firebase_auth_mocks/pull/116). Thank you [Tpow99](https://github.com/Tpow99)!

## 0.14.1

- Allow setting `mockUser` to null. [PR-112](https://github.com/atn832/firebase_auth_mocks/pull/112).
- Support throwing mock exceptions from `signOut`. [PR-111](https://github.com/atn832/firebase_auth_mocks/pull/111).

Thank you [michaelowolf](https://github.com/michaelowolf)!

## 0.14.0

Upgraded firebase_auth dependency to ^5.0.0. [PR-108](https://github.com/atn832/firebase_auth_mocks/pull/108)

## 0.13.0

Upgraded uuid to ^4.1.0 and firebase_auth_platform_interface to ^7.0.0. Thank you [Rexios80](https://github.com/atn832/firebase_auth_mocks/pull/103) and [https://github.com/kody-liou](https://github.com/atn832/firebase_auth_mocks/pull/102)!

## 0.12.0

- Fixed compilation issues due to breaking changes in [firebase_auth_platform_interface](https://pub.dev/packages/firebase_auth_platform_interface/changelog#6160) ([PR-99](https://github.com/atn832/firebase_auth_mocks/pull/99)). Thank you [gnurik](https://github.com/gnurik)!

## 0.11.0

- BREAKING CHANGE: Replaced the `MockUser.exception` pattern by `whenCalling(...).on(...).thenThrow(...)` ([PR-95](https://github.com/atn832/firebase_auth_mocks/pull/95)).
- `FirebaseAuth.createUserWithEmailAndPassword` returns `ProviderData`. Thank you [robyf](https://github.com/atn832/firebase_auth_mocks/pull/90)!
- Implemented `User.updatePhotoURL`. Thank you [bifrostyyy](https://github.com/atn832/firebase_auth_mocks/pull/91)!
- Implemented `User.linkWithProvider`, and `User.unlink`. Thank you [bifrostyyy](https://github.com/atn832/firebase_auth_mocks/pull/91)!
- Make `User.reload` throw exceptions on demand ([9ad29f0](https://github.com/atn832/firebase_auth_mocks/commit/9ad29f057660c3e1869a55d57c9972c0137626bf)).

## 0.10.3

Fixed a bug where `MockUserCredential.user` would create a new MockUser at every call, in the anonymous case.

## 0.10.2+1

Make `authForFakeFirestore` send an event at the same time as the other two streams to fix race condition when Fake Cloud Firestore gets the latest user to check security rules.

## 0.10.2

Implemented `authForFakeFirestore` for Fake Cloud Firestore's security rules.

## 0.10.1

`User.getIdTokenResult` will return `customClaims` if `idTokenResult` is not explicitly set.

## 0.10.0

BREAKING CHANGE. Use the `whenCalling(...).on(...).thenThrow(...)` pattern instead of `AuthExceptions` ([PR-87](https://github.com/atn832/firebase_auth_mocks/pull/87)).

Instead of setting up your exception like this:

```dart
final auth = MockFirebaseAuth(
  authExceptions: AuthExceptions(
    signInWithCredential: FirebaseAuthException(code: 'something'),
  ),
);
```

Use:

```dart
whenCalling(Invocation.method(#signInWithCredential, null))
  .on(auth)
  .thenThrow(FirebaseAuthException(code: 'bla'));
```

You can also be more specific on when to throw the exception. See the README and <https://pub.dev/packages/mock_exceptions>.

## 0.9.3

- Implemented `FirebaseAuth.signInWithPopup` and `FirebaseAuth.signInWithProvider`. Thanks [ga-bri-el](https://github.com/atn832/firebase_auth_mocks/pull/85)!

## 0.9.2

- Fixed a crash when testing in signed in mode for an anonymous user. Thanks [BenVercammen](https://github.com/BenVercammen)!
- Fixed `User.displayName` so that it returns `null` by default. Thanks [BenVercammen](https://github.com/BenVercammen)!

## 0.9.1

- Implemented `FirebaseAuth.fetchSignInMethodsForEmail`. Thanks [BenVercammen](https://github.com/BenVercammen)!
- Implemented `User.linkWithCredential`. Thanks [BenVercammen](https://github.com/BenVercammen)!
- Support setting a `customClaim` for `User.getIdToken`. Thanks [kody-liou](https://github.com/kody-liou)!

## 0.9.0

- Updated dependency to firebase_auth ^4.0.0.

## 0.8.7

- Implemented proper generation of the `auth_time`, `exp` and `iat` values in `User.getIdToken`. Thanks [kody-liou](https://github.com/kody-liou)!
- Implemented `User.getIdTokenResult`. Thank you [BenGMiles](https://github.com/BenGMiles)!
- Fixed `User.email` so that it returns `null` by default. Thank you [defuncart](https://github.com/defuncart)!

## 0.8.6

- Implemented generation of proper JWT token in `User.getIdToken`. Thanks [kody-liou](https://github.com/kody-liou)!
- Implemented `sendSignInLinkToEmail`, `confirmPasswordReset` and `verifyPasswordResetCode` in `FirebaseAuth`. Thanks [Zohenn](https://github.com/Zohenn)!

## 0.8.5+1

- Added missing changelogs.

## 0.8.5

- Changed `FirebaseAuth.verifyPhoneNumber`'s signature to include firebase_auth 3.5.0's new multi factor params. Thanks [cedvdb](https://github.com/cedvdb) and [cselti](https://github.com/cselti)!
- Implemented `FirebaseAuth.sendPasswordResetEmail`. Thanks [Zohenn](https://github.com/Zohenn)!
- Implemented `User.sendEmailVerification`. Thanks [dipeshdulal](https://github.com/dipeshdulal)!

## 0.8.4

- Support throwing exceptions in FirebaseAuth's `signInWithCredential`, `signInWithEmailAndPassword`, `createUserWithEmailAndPassword`, `signInWithCustomToken`, `signInAnonymously`, and `fetchSignInMethodsForEmail`. Thanks [defuncart](https://github.com/defuncart)!
- Implemented `FirebaseAuth.verifyPhoneNumber` so that it resolves `codeSent`. Thanks [cedvdb](https://github.com/cedvdb)!

## 0.8.3

- Implemented `User` methods `reauthenticateWithCredential`, `updatePassword` and `delete` with the ability to throw exceptions. Thanks [defuncart](https://github.com/defuncart)!
- Implemented `createUserWithEmailAndPassword`. Thanks [f-hoedl](https://github.com/f-hoedl)!

## 0.8.2

- Made `userChanges` and `authStateChanges` fire `null` on startup when signed out.
- Turned `userChanges` and `authStateChanges` into broadcast streams so they can be listened to more than once.
- Added `providerData` in MockUser. Thanks [kornperkus](https://github.com/kornperkus)!

## 0.8.1
- Implemented `FirebaseAuth.userChanges`. Thanks [mazzonem](https://github.com/mazzonem)!
- Implemented `User.updateDisplayName`. Thanks [oudehomar](https://github.com/oudehomar)!
- Implemented `FirebaseAuth.fetchSignInMethodsForEmail`. Thanks [ketanchoyal](https://github.com/ketanchoyal)!

## 0.8.0

- Updated dependency to firebase_auth ^3.0.0.
- Implemented `User.reload()`.

## 0.7.1

- Implement User.metadata. Thanks [mazzonem](https://github.com/mazzonem)!

## 0.7.0

- Removed dependency to Mockito.
- Updated dependency to firebase_auth ^1.3.0.

## 0.6.0

- Migrated to null safety. Thanks [YusufAbdelaziz](https://github.com/YusufAbdelaziz)!
- Updated dependency to firebase_auth ^1.0.1. Thanks [zariweyo](https://github.com/zariweyo)!

## 0.5.2

- Typed the arguments of `MockUser`'s constructor. Thanks [YusufAbdelaziz](https://github.com/YusufAbdelaziz)!

## 0.5.1

- Support for `signInWithPhoneNumber`.

## 0.5.0

Breaking change:

- Require supplying a `MockUser` instead of returning 'Bob'. Thanks [PieterHartzer](https://github.com/PieterHartzer)!

Refer to README.md on how to use it.

## 0.4.0

- Updated dependency to firebase_auth ^0.20.0+1. Thanks [Aanu1995](https://github.com/Aanu1995)!

## 0.3.2

- Support the newer `authStateChanges()` on top of the deprecated `get onAuthStateChanged`. Thanks [gallrein](https://github.com/gallrein)!

## 0.3.1

- Support `User.isAnonymous`.
- Support `User.email`.

## 0.3.0

- Support the breaking changes of firebase_auth 0.18.0+1.
- Removed `signInWithEmailAndLink` since it's not part of the API anymore.

## 0.2.1

- Added support for `signInAnonymously` and `signOut`. Thanks [shepeliev](https://github.com/shepeliev)!

## 0.2.0

- Upgraded firebase_auth dependency to ^0.16.0.

## 0.1.3

- Added support for `signInWithEmailAndPassword`, `signInWithEmailAndLink` and `signInWithCustomToken`.
- Documented supported features

## 0.1.2

- Implemented `MockFirebaseUser.getIdToken()`. Thanks [dfdgsdfg](https://github.com/atn832/firebase_auth_mocks/pull/2)!

## 0.1.1

- Upgraded firebase_auth dependency to ^0.15.2.

## 0.1.0

- Initial version.
