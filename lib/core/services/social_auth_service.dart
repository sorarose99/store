import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../../core/error/failures.dart';

class SocialAuthResult {
  final UserCredential userCredential;
  final String providerToken;

  SocialAuthResult({
    required this.userCredential,
    required this.providerToken,
  });
}

/// Handles native Google & Apple Sign-In flows and returns
/// a Firebase UserCredential and the raw provider token.
class SocialAuthService {
  // ── Google ─────────────────────────────────────────────────────────

  static Future<Either<Failure, SocialAuthResult>> signInWithGoogle() async {
    try {
      final googleSignIn = google_sign_in.GoogleSignIn(
        serverClientId:
            '564761085746-1uhocilojvgj01n5de2tvjbifq9tgqv9.apps.googleusercontent.com',
        scopes: ['email, profile'],
      );

      // Sign out first to ensure account selection popup shows up if multiple accounts exist
      await googleSignIn.signOut();

      final account = await googleSignIn.signIn();
      if (account == null) {
        return const Left(ServerFailure('google_sign_in_cancelled'));
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if (idToken == null && accessToken == null) {
        return const Left(ServerFailure('google_token_missing'));
      }

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      developer.log('Google Sign-In SUCCESS! User: ${userCredential.user?.uid}',
          name: 'SocialAuth');
      
      return Right(SocialAuthResult(
        userCredential: userCredential,
        providerToken: idToken ?? accessToken ?? '',
      ));
    } catch (e) {
      developer.log('Google Sign-In FAILED: $e', name: 'SocialAuth');
      return Left(ServerFailure('google_sign_in_error: $e'));
    }
  }

  static Future<void> signOutGoogle() async {
    try {
      await google_sign_in.GoogleSignIn().signOut();
    } catch (e) {
      // Ignore errors on sign out
    }
  }

  // ── Apple ──────────────────────────────────────────────────────────
  static Future<Either<Failure, SocialAuthResult>> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // Optionally update display name if it's the first time
      if (credential.givenName != null || credential.familyName != null) {
        final name =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
        if (name.isNotEmpty &&
            userCredential.user != null &&
            userCredential.user!.displayName == null) {
          await userCredential.user!.updateDisplayName(name);
        }
      }

      return Right(SocialAuthResult(
        userCredential: userCredential,
        providerToken: credential.identityToken ?? credential.authorizationCode,
      ));
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Left(ServerFailure('apple_sign_in_cancelled'));
      }
      return Left(ServerFailure('apple_sign_in_error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('apple_sign_in_error: $e'));
    }
  }
}
