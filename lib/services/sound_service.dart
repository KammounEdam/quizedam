import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'preferences_service.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PreferencesService? _preferencesService;

  static final SoundService _instance = SoundService._internal();

  factory SoundService() {
    return _instance;
  }

  SoundService._internal();

  Future<void> initialize() async {
    _preferencesService = await PreferencesService.getInstance();
  }

  bool get _soundEnabled => _preferencesService?.getSoundEnabled() ?? true;
  bool get _vibrationEnabled =>
      _preferencesService?.getVibrationEnabled() ?? true;

  /// Try to play audio file with multiple format support
  Future<void> _playAudioFile(String basePath) async {
    // List of supported formats in order of preference
    final formats = ['ogg', 'mp3', 'wav', 'aac'];

    for (String format in formats) {
      try {
        await _audioPlayer.play(AssetSource('$basePath.$format'));
        return; // Success, exit the loop
      } catch (e) {
        // Try next format
        continue;
      }
    }

    // If all formats fail, throw an exception
    throw Exception('No audio file found for $basePath');
  }

  Future<void> playCorrectAnswer() async {
    if (_soundEnabled) {
      try {
        // Try multiple formats in order of preference
        await _playAudioFile('sounds/correct');
      } catch (e) {
        // Fallback to system sound - success sound
        await SystemSound.play(SystemSoundType.alert);
      }
    }
    if (_vibrationEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> playWrongAnswer() async {
    if (_soundEnabled) {
      try {
        await _playAudioFile('sounds/wrong');
      } catch (e) {
        // Fallback to system sound - error sound
        await SystemSound.play(SystemSoundType.click);
      }
    }
    if (_vibrationEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }

  Future<void> playButtonClick() async {
    if (_soundEnabled) {
      try {
        await _playAudioFile('sounds/click');
      } catch (e) {
        // Fallback to system sound - click sound
        await SystemSound.play(SystemSoundType.click);
      }
    }
    if (_vibrationEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
