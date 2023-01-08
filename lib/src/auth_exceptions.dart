import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A class containing optional [FirebaseAuthException]s for methods in [FirebaseAuth]
class AuthExceptions extends Equatable {
  const AuthExceptions({
    this.signInWithEmailAndPassword,
    this.createUserWithEmailAndPassword,
    this.signInWithCustomToken,
    this.signInAnonymously,
    this.fetchSignInMethodsForEmail,
    this.sendPasswordResetEmail,
    this.sendSignInLinkToEmail,
    this.confirmPasswordReset,
    this.verifyPasswordResetCode,
    this.signInWithProvider,
    this.signInWithPopup,
  });

  final FirebaseAuthException? signInWithEmailAndPassword;
  final FirebaseAuthException? createUserWithEmailAndPassword;
  final FirebaseAuthException? signInWithCustomToken;
  final FirebaseAuthException? signInAnonymously;
  final FirebaseAuthException? fetchSignInMethodsForEmail;
  final FirebaseAuthException? sendPasswordResetEmail;
  final FirebaseAuthException? sendSignInLinkToEmail;
  final FirebaseAuthException? confirmPasswordReset;
  final FirebaseAuthException? verifyPasswordResetCode;
  final FirebaseAuthException? signInWithProvider;
  final FirebaseAuthException? signInWithPopup;

  @override
  List<Object?> get props => [
        signInWithEmailAndPassword,
        createUserWithEmailAndPassword,
        signInWithCustomToken,
        signInAnonymously,
        fetchSignInMethodsForEmail,
        sendPasswordResetEmail,
        sendSignInLinkToEmail,
        confirmPasswordReset,
        verifyPasswordResetCode,
        signInWithProvider,
        signInWithPopup,
      ];
}
