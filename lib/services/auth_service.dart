import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

/// Authentication service that handles Firebase Auth operations
/// with comprehensive error handling and logging
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      developer.log(
        'Attempting to sign up user: $email',
        name: 'zeeky_social.auth',
        level: 800,
      );

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      developer.log(
        'User signed up successfully: ${credential.user?.uid}',
        name: 'zeeky_social.auth',
        level: 800,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Failed to sign up user: ${e.code} - ${e.message}',
        name: 'zeeky_social.auth',
        level: 1000,
        error: e,
      );
      
      // Re-throw for UI to handle
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during sign up',
        name: 'zeeky_social.auth',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      developer.log(
        'Attempting to sign in user: $email',
        name: 'zeeky_social.auth',
        level: 800,
      );

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      developer.log(
        'User signed in successfully: ${credential.user?.uid}',
        name: 'zeeky_social.auth',
        level: 800,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Failed to sign in user: ${e.code} - ${e.message}',
        name: 'zeeky_social.auth',
        level: 1000,
        error: e,
      );
      
      // Re-throw for UI to handle
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error during sign in',
        name: 'zeeky_social.auth',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      
      developer.log(
        'Attempting to sign out user: $currentUserId',
        name: 'zeeky_social.auth',
        level: 800,
      );

      await _auth.signOut();

      developer.log(
        'User signed out successfully',
        name: 'zeeky_social.auth',
        level: 800,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to sign out user',
        name: 'zeeky_social.auth',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      developer.log(
        'Sending password reset email to: $email',
        name: 'zeeky_social.auth',
        level: 800,
      );

      await _auth.sendPasswordResetEmail(email: email);

      developer.log(
        'Password reset email sent successfully',
        name: 'zeeky_social.auth',
        level: 800,
      );
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Failed to send password reset email: ${e.code} - ${e.message}',
        name: 'zeeky_social.auth',
        level: 1000,
        error: e,
      );
      
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error sending password reset email',
        name: 'zeeky_social.auth',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      
      rethrow;
    }
  }

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      developer.log(
        'Updating display name for user: ${user.uid}',
        name: 'zeeky_social.auth',
        level: 800,
      );

      await user.updateDisplayName(displayName);
      await user.reload();

      developer.log(
        'Display name updated successfully',
        name: 'zeeky_social.auth',
        level: 800,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update display name',
        name: 'zeeky_social.auth',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      
      rethrow;
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      developer.log(
        'Attempting to delete user account: ${user.uid}',
        name: 'zeeky_social.auth',
        level: 800,
      );

      await user.delete();

      developer.log(
        'User account deleted successfully',
        name: 'zeeky_social.auth',
        level: 800,
      );
    } on FirebaseAuthException catch (e) {
      developer.log(
        'Failed to delete user account: ${e.code} - ${e.message}',
        name: 'zeeky_social.auth',
        level: 1000,
        error: e,
      );
      
      rethrow;
    } catch (e, stackTrace) {
      developer.log(
        'Unexpected error deleting user account',
        name: 'zeeky_social.auth',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      
      rethrow;
    }
  }

  /// Get user friendly error message from FirebaseAuthException
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }
}
