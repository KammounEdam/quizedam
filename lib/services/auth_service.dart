import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      await _createUserDocument(result.user!, displayName);

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      // Create user document if new user
      if (result.additionalUserInfo?.isNewUser == true) {
        await _createUserDocument(result.user!, googleUser.displayName ?? 'User');
      }

      return result;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // Sign in anonymously
  Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      
      // Create anonymous user document
      await _createUserDocument(result.user!, 'Guest User');
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Anonymous sign-in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String displayName) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isAnonymous': user.isAnonymous,
        'quizStats': {
          'totalQuizzes': 0,
          'totalCorrectAnswers': 0,
          'totalQuestions': 0,
          'averageScore': 0.0,
          'bestScore': 0.0,
          'favoriteCategory': '',
        },
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  // Update user stats after quiz
  Future<void> updateUserStats({
    required int correctAnswers,
    required int totalQuestions,
    required double score,
    required String category,
  }) async {
    if (!isSignedIn) return;

    try {
      final userDoc = _firestore.collection('users').doc(currentUser!.uid);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        final data = snapshot.data() ?? {};
        final stats = data['quizStats'] ?? {};

        final currentTotalQuizzes = stats['totalQuizzes'] ?? 0;
        final currentTotalCorrect = stats['totalCorrectAnswers'] ?? 0;
        final currentTotalQuestions = stats['totalQuestions'] ?? 0;
        final currentBestScore = stats['bestScore'] ?? 0.0;

        final newTotalQuizzes = currentTotalQuizzes + 1;
        final newTotalCorrect = currentTotalCorrect + correctAnswers;
        final newTotalQuestions = currentTotalQuestions + totalQuestions;
        final newAverageScore = newTotalQuestions > 0 
            ? (newTotalCorrect / newTotalQuestions) * 100 
            : 0.0;
        final newBestScore = score > currentBestScore ? score : currentBestScore;

        transaction.update(userDoc, {
          'lastLoginAt': FieldValue.serverTimestamp(),
          'quizStats': {
            'totalQuizzes': newTotalQuizzes,
            'totalCorrectAnswers': newTotalCorrect,
            'totalQuestions': newTotalQuestions,
            'averageScore': newAverageScore,
            'bestScore': newBestScore,
            'favoriteCategory': category,
          },
        });
      });
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  // Get user stats
  Future<Map<String, dynamic>?> getUserStats() async {
    if (!isSignedIn) return null;

    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      return doc.data()?['quizStats'];
    } catch (e) {
      print('Error getting user stats: $e');
      return null;
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }
}
