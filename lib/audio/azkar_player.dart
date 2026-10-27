import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Plays one recitation at a time. Starting a new one stops the previous one.
/// Notifies listeners whenever playback state changes, so the cards can show
/// play or pause.
class AzkarPlayer extends ChangeNotifier {
  AzkarPlayer() {
    _subscription = _player.playerStateStream.listen((_) => notifyListeners());
  }

  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<PlayerState> _subscription;
  String? _currentKey;

  // just_audio keeps `playing` true after a recording ends, so the finished
  // state is checked as well.
  bool get _finished => _player.processingState == ProcessingState.completed;

  bool isPlaying(String key) =>
      _currentKey == key && _player.playing && !_finished;

  /// Plays, pauses or resumes the recording for [key].
  /// [source] is an https link or an asset path. Returns an error message to
  /// show to the user, or null when everything worked.
  Future<String?> toggle(String key, String source) async {
    try {
      if (_currentKey == key) {
        if (_player.playing && !_finished) {
          await _player.pause();
        } else {
          if (_finished) {
            await _player.seek(Duration.zero);
          }
          unawaited(_player.play());
        }
        return null;
      }

      await _player.stop();
      _currentKey = key;
      if (source.startsWith('http')) {
        await _player.setUrl(source);
      } else {
        await _player.setAsset(source);
      }
      unawaited(_player.play());
      return null;
    } catch (_) {
      _currentKey = null;
      notifyListeners();
      return 'ኦዲዮው ሊጫወት አልቻለም። ኢንተርኔትዎን ወይም ፋይሉን ያረጋግጡ።';
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _player.dispose();
    super.dispose();
  }
}
