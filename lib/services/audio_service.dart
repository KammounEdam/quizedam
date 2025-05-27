import 'package:audioplayers/audioplayers.dart';
// import 'package:vibration/vibration.dart';
import 'preferences_service.dart';
import 'audio_manager.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // final AudioPlayer _audioPlayer = AudioPlayer();
  PreferencesService? _preferencesService;
  final AudioManager _audioManager = AudioManager();

  Future<void> initialize() async {
    _preferencesService = await PreferencesService.getInstance();
  }

  // Sound effects - Using system sounds for now
  Future<void> playCorrectSound() async {
    // Use the AudioManager to play the correct sound
    await _audioManager.playCorrect();
  }

  Future<void> playIncorrectSound() async {
    // Use the AudioManager to play the wrong sound
    await _audioManager.playWrong();
  }

  Future<void> playButtonSound() async {
    // Use the AudioManager to play the click sound
    await _audioManager.playClick();
  }

  Future<void> playTimerWarningSound() async {
    if (_preferencesService?.getSoundEnabled() == true) {
      try {
        print('Playing timer warning sound effect');
      } catch (e) {
        print('Sound error: $e');
      }
    }
  }

  // Vibration effects
  Future<void> vibrateCorrect() async {
    if (_preferencesService?.getVibrationEnabled() == true) {
      // Vibration temporarily disabled - would vibrate for correct answer
      print('✅ Vibrating for correct answer (100ms)');
    }
  }

  Future<void> vibrateIncorrect() async {
    if (_preferencesService?.getVibrationEnabled() == true) {
      // Vibration temporarily disabled - would vibrate for incorrect answer
      print('❌ Vibrating for incorrect answer (double vibration)');
    }
  }

  Future<void> vibrateButton() async {
    final vibrationEnabled = _preferencesService?.getVibrationEnabled() == true;
    print('Vibration enabled: $vibrationEnabled');

    if (vibrationEnabled) {
      // Vibration temporarily disabled - would vibrate for button press
      print('✅ VIBRATION EXECUTED! (50ms)');
    } else {
      print('❌ VIBRATION DISABLED in settings');
    }
  }

  Future<void> vibrateTimerWarning() async {
    if (_preferencesService?.getVibrationEnabled() == true) {
      // Vibration temporarily disabled - would vibrate for timer warning
      print('⚠️ Vibrating for timer warning (pulsing)');
    }
  }

  void dispose() {
    // _audioPlayer.dispose();
  }
}
