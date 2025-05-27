// import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService extends ChangeNotifier {
  // In-memory storage for simplified version
  bool _isDarkMode = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _language = 'en';
  List<Map<String, dynamic>> _highScores = [];

  static PreferencesService? _instance;
  static Future<PreferencesService> getInstance() async {
    _instance ??= PreferencesService._();
    return _instance!;
  }

  PreferencesService._();

  // Theme
  bool get isDarkMode => _isDarkMode;

  Future<void> setThemeMode(String mode) async {
    _isDarkMode = mode == 'dark';
    notifyListeners();
  }

  String getThemeMode() {
    return _isDarkMode ? 'dark' : 'light';
  }

  // Language
  Locale get locale => Locale(_language);

  Future<void> setLanguage(String language) async {
    _language = language;
    notifyListeners();
  }

  String getLanguage() {
    return _language;
  }

  // Sound
  Future<bool> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    notifyListeners();
    return true;
  }

  bool getSoundEnabled() {
    return _soundEnabled;
  }

  // Vibration
  Future<bool> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    notifyListeners();
    return true;
  }

  bool getVibrationEnabled() {
    return _vibrationEnabled;
  }

  // High Scores
  Future<bool> saveHighScore(Map<String, dynamic> score) async {
    _highScores.add(score);
    _highScores.sort((a, b) => b['score'].compareTo(a['score']));
    if (_highScores.length > 10) {
      _highScores.removeLast();
    }
    return true;
  }

  List<Map<String, dynamic>> getHighScores() {
    return List.from(_highScores);
  }

  Future<void> clearHighScores() async {
    _highScores.clear();
  }
}
