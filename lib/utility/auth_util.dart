import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthUtil {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  static Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  static Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await firebaseAuth.signInWithCredential(credential);
    }
    return null;
  }

  static Future<UserCredential?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      return await firebaseAuth.signInWithCredential(credential);
    }
    return null;
  }

  //static String _verificationId = '';

  static Future<void> verifyPhoneNumber(
      String phoneNumber,
      Function(UserCredential? userCredential) onVerificationCompleted,
      Function(String errorCode) onFirebaseError,
      Function(String verificationId, int? resendToken) onCodeSent,
      Function(String verificationId) onCodeAutoRetrievalTimeOut,
      {int? resendToken}) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: resendToken,
        timeout: Duration(minutes: 2),
        verificationCompleted: (PhoneAuthCredential credential) async {
          UserCredential userCredential =
              await firebaseAuth.signInWithCredential(credential);
          onVerificationCompleted(userCredential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onFirebaseError(e.code);
        },
        codeSent: (String verificationId, int? resendToken) {
          // _verificationId = verificationId;
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // _verificationId = verificationId;
          onCodeAutoRetrievalTimeOut(verificationId);
        },
      );
    } catch (e) {
      print('Error verifying phone number: $e');
    }
  }

  static Future<UserCredential?> signInWithPhoneNumber(
      String phoneNumber, String smsCode, String verificationId) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with phone number: $e');
      rethrow;
    }
  }
}
