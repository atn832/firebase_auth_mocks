## 0.6.1

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
