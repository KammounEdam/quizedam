import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();
  Future<void> initialize() async {
    // Notifications temporarily disabled
    print('📱 Notification service initialized (disabled)');
  }

  Future<void> scheduleQuizReminder() async {
    // Notifications temporarily disabled
    print('📅 Quiz reminder scheduled for 6 PM (disabled)');
  }

  Future<void> showQuizCompleteNotification(int score, int total) async {
    // Notifications temporarily disabled
    print(
        '🎉 Quiz complete notification: You scored $score out of $total. Great job! (disabled)');
  }
}
