import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A class containing optional [FirebaseAuthException]s for methods in [FirebaseAuth]
class AuthExceptions extends Equatable {
  const AuthExceptions({
    this.signInWithCredential,
    this.signInWithEmailAndPassword,
    this.createUserWithEmailAndPassword,
    this.signInWithCustomToken,
    this.signInAnonymously,
    this.fetchSignInMethodsForEmail,
    this.sendPasswordResetEmail,
    this.sendSignInLinkToEmail,
    this.confirmPasswordReset,
    this.verifyPasswordResetCode,
  });

  final FirebaseAuthException? signInWithCredential;
  final FirebaseAuthException? signInWithEmailAndPassword;
  final FirebaseAuthException? createUserWithEmailAndPassword;
  final FirebaseAuthException? signInWithCustomToken;
  final FirebaseAuthException? signInAnonymously;
  final FirebaseAuthException? fetchSignInMethodsForEmail;
  final FirebaseAuthException? sendPasswordResetEmail;
  final FirebaseAuthException? sendSignInLinkToEmail;
  final FirebaseAuthException? confirmPasswordReset;
  final FirebaseAuthException? verifyPasswordResetCode;

  @override
  List<Object?> get props => [
        signInWithCredential,
        signInWithEmailAndPassword,
        createUserWithEmailAndPassword,
        signInWithCustomToken,
        signInAnonymously,
        fetchSignInMethodsForEmail,
        sendPasswordResetEmail,
        sendSignInLinkToEmail,
        confirmPasswordReset,
        verifyPasswordResetCode,
      ];
}
