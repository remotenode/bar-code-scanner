import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

/// Service for providing haptic and audio feedback on successful scans
class FeedbackService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool? _hasVibrator;

  /// Initialize the feedback service
  Future<void> init() async {
    _hasVibrator = await Vibration.hasVibrator();
  }

  /// Provide vibration feedback
  Future<void> vibrate() async {
    if (_hasVibrator == true) {
      await Vibration.vibrate(duration: 100);
    }
  }

  /// Play scan success sound
  Future<void> playSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
    } catch (e) {
      // Ignore audio playback errors
    }
  }

  /// Provide feedback based on settings
  Future<void> provideFeedback({
    required bool vibrationEnabled,
    required bool soundEnabled,
  }) async {
    if (vibrationEnabled) {
      await vibrate();
    }
    if (soundEnabled) {
      await playSound();
    }
  }

  /// Dispose of resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
