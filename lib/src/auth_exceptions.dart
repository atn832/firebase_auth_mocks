import 'package:firebase_auth/firebase_auth.dart';

/// A class containing optional [FirebaseAuthException]s for methods in [FirebaseAuth]
class AuthExceptions {
  const AuthExceptions({
    this.signInWithCredential,
    this.signInWithEmailAndPassword,
    this.createUserWithEmailAndPassword,
    this.signInWithCustomToken,
    this.signInAnonymously,
    this.fetchSignInMethodsForEmail,
  });

  final FirebaseAuthException? signInWithCredential;
  final FirebaseAuthException? signInWithEmailAndPassword;
  final FirebaseAuthException? createUserWithEmailAndPassword;
  final FirebaseAuthException? signInWithCustomToken;
  final FirebaseAuthException? signInAnonymously;
  final FirebaseAuthException? fetchSignInMethodsForEmail;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AuthExceptions &&
        other.signInWithCredential == signInWithCredential &&
        other.signInWithEmailAndPassword == signInWithEmailAndPassword &&
        other.createUserWithEmailAndPassword ==
            createUserWithEmailAndPassword &&
        other.signInWithCustomToken == signInWithCustomToken &&
        other.signInAnonymously == signInAnonymously &&
        other.fetchSignInMethodsForEmail == fetchSignInMethodsForEmail;
  }

  @override
  int get hashCode {
    return signInWithCredential.hashCode ^
        signInWithEmailAndPassword.hashCode ^
        createUserWithEmailAndPassword.hashCode ^
        signInWithCustomToken.hashCode ^
        signInAnonymously.hashCode ^
        fetchSignInMethodsForEmail.hashCode;
  }
}
