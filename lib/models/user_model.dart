import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isAnonymous;
  final QuizStats quizStats;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.createdAt,
    this.lastLoginAt,
    required this.isAnonymous,
    required this.quizStats,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      createdAt: data['createdAt']?.toDate(),
      lastLoginAt: data['lastLoginAt']?.toDate(),
      isAnonymous: data['isAnonymous'] ?? false,
      quizStats: QuizStats.fromMap(data['quizStats'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'isAnonymous': isAnonymous,
      'quizStats': quizStats.toMap(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isAnonymous,
    QuizStats? quizStats,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      quizStats: quizStats ?? this.quizStats,
    );
  }
}

class QuizStats {
  final int totalQuizzes;
  final int totalCorrectAnswers;
  final int totalQuestions;
  final double averageScore;
  final double bestScore;
  final String favoriteCategory;

  QuizStats({
    required this.totalQuizzes,
    required this.totalCorrectAnswers,
    required this.totalQuestions,
    required this.averageScore,
    required this.bestScore,
    required this.favoriteCategory,
  });

  factory QuizStats.fromMap(Map<String, dynamic> map) {
    return QuizStats(
      totalQuizzes: map['totalQuizzes'] ?? 0,
      totalCorrectAnswers: map['totalCorrectAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      averageScore: (map['averageScore'] ?? 0.0).toDouble(),
      bestScore: (map['bestScore'] ?? 0.0).toDouble(),
      favoriteCategory: map['favoriteCategory'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalQuizzes': totalQuizzes,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalQuestions': totalQuestions,
      'averageScore': averageScore,
      'bestScore': bestScore,
      'favoriteCategory': favoriteCategory,
    };
  }

  QuizStats copyWith({
    int? totalQuizzes,
    int? totalCorrectAnswers,
    int? totalQuestions,
    double? averageScore,
    double? bestScore,
    String? favoriteCategory,
  }) {
    return QuizStats(
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      averageScore: averageScore ?? this.averageScore,
      bestScore: bestScore ?? this.bestScore,
      favoriteCategory: favoriteCategory ?? this.favoriteCategory,
    );
  }

  // Calculate accuracy percentage
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return (totalCorrectAnswers / totalQuestions) * 100;
  }

  // Get performance level
  String get performanceLevel {
    if (averageScore >= 90) return 'Expert';
    if (averageScore >= 80) return 'Advanced';
    if (averageScore >= 70) return 'Intermediate';
    if (averageScore >= 60) return 'Beginner';
    return 'Novice';
  }
}
