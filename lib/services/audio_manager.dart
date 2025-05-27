import 'sound_service.dart';

/// Global audio manager to provide easy access to sound services
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  late final SoundService _soundService;

  /// Initialize the audio manager
  Future<void> initialize() async {
    _soundService = SoundService();
    await _soundService.initialize();
  }

  /// Play sound for correct answer
  Future<void> playCorrect() async {
    await _soundService.playCorrectAnswer();
  }

  /// Play sound for wrong answer
  Future<void> playWrong() async {
    await _soundService.playWrongAnswer();
  }

  /// Play sound for button click
  Future<void> playClick() async {
    await _soundService.playButtonClick();
  }

  /// Dispose audio resources
  Future<void> dispose() async {
    await _soundService.dispose();
  }
}
