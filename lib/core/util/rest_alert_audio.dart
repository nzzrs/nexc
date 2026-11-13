/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 *
 * LibreFit is subject to additional terms covering author attribution and trademark usage;
 * see the ADDITIONAL_TERMS.md and TRADEMARK_POLICY.md files in the project root.
 */

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Asset played when the rest timer finishes.
const String restAlertSoundAsset = 'sounds/rest_done.wav';

/// Android context for the short rest alert.
///
/// [AndroidAudioFocus.gainTransientMayDuck] asks the system to lower the volume
/// of other audio (for example music) while the alert plays, and to restore it
/// as soon as the transient focus is abandoned.
const AudioContextAndroid restAlertAudioContextAndroid = AudioContextAndroid(
  contentType: AndroidContentType.sonification,
  audioMode: AndroidAudioMode.normal,
  usageType: AndroidUsageType.media,
  audioFocus: AndroidAudioFocus.gainTransientMayDuck,
);

/// Platform context for the short rest alert.
///
/// On iOS the [AVAudioSessionOptions.duckOthers] option lowers other sessions
/// instead of mixing at full volume.
AudioContext get restAlertAudioContext => AudioContext(
  android: restAlertAudioContextAndroid,
  iOS: AudioContextIOS(
    category: AVAudioSessionCategory.playback,
    options: const {AVAudioSessionOptions.duckOthers},
  ),
);

/// Applies the rest alert audio context to [player].
Future<void> applyRestAlertAudioContext(AudioPlayer player) {
  return player.setAudioContext(restAlertAudioContext);
}

/// Plays [source] once and releases the transient audio focus afterwards.
///
/// Stopping the player abandons Android's focus request and clears iOS session
/// activation, so ducked media returns to its normal volume.
Future<void> playRestAlert(
  AudioPlayer player,
  Source source, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  await applyRestAlertAudioContext(player);
  final completed = Completer<void>();
  final completion = player.onPlayerComplete.listen((_) {
    if (!completed.isCompleted) {
      completed.complete();
    }
  });
  try {
    await player.play(source);
    await completed.future.timeout(timeout);
  } finally {
    await completion.cancel();
    try {
      await player.stop();
    } catch (_) {
      // Releasing focus is best effort; callers treat audio failures as non-fatal.
    }
  }
}
