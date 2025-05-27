import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? false;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user == null) {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (result != null) {
        _user = result.user;
        await _loadUserModel();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result != null) {
        _user = result.user;
        await _loadUserModel();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.signInWithGoogle();

      if (result != null) {
        _user = result.user;
        await _loadUserModel();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in anonymously
  Future<bool> signInAnonymously() async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.signInAnonymously();

      if (result != null) {
        _user = result.user;
        await _loadUserModel();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signOut();
      _user = null;
      _userModel = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user stats after quiz
  Future<void> updateUserStats({
    required int correctAnswers,
    required int totalQuestions,
    required double score,
    required String category,
  }) async {
    try {
      await _authService.updateUserStats(
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        score: score,
        category: category,
      );
      
      // Reload user model to get updated stats
      await _loadUserModel();
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  // Load user model from Firestore
  Future<void> _loadUserModel() async {
    if (_user == null) return;

    try {
      final stats = await _authService.getUserStats();
      if (stats != null) {
        _userModel = UserModel(
          uid: _user!.uid,
          email: _user!.email ?? '',
          displayName: _user!.displayName ?? 'User',
          photoURL: _user!.photoURL,
          createdAt: _user!.metadata.creationTime,
          lastLoginAt: _user!.metadata.lastSignInTime,
          isAnonymous: _user!.isAnonymous,
          quizStats: QuizStats.fromMap(stats),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user model: $e');
    }
  }

  // Get user display name
  String get displayName {
    if (_userModel != null) return _userModel!.displayName;
    if (_user != null) return _user!.displayName ?? 'User';
    return 'Guest';
  }

  // Get user email
  String get email {
    if (_userModel != null) return _userModel!.email;
    if (_user != null) return _user!.email ?? '';
    return '';
  }

  // Get user photo URL
  String? get photoURL {
    if (_userModel != null) return _userModel!.photoURL;
    if (_user != null) return _user!.photoURL;
    return null;
  }

  // Check if user has completed profile
  bool get hasCompletedProfile {
    return _user != null && 
           _user!.displayName != null && 
           _user!.displayName!.isNotEmpty;
  }
}
