/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Copyright (c) 2026. The Nexc Contributors
 */

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexc_flutter/core/util/rest_alert_audio.dart';

void main() {
  group('rest alert audio context', () {
    test('Android requests transient focus that may duck other audio', () {
      expect(
        restAlertAudioContextAndroid.contentType,
        AndroidContentType.sonification,
      );
      expect(restAlertAudioContextAndroid.usageType, AndroidUsageType.media);
      expect(restAlertAudioContextAndroid.audioMode, AndroidAudioMode.normal);
      expect(
        restAlertAudioContextAndroid.audioFocus,
        AndroidAudioFocus.gainTransientMayDuck,
      );
    });

    test('iOS plays in playback category and ducks other sessions', () {
      expect(
        restAlertAudioContext.iOS.category,
        AVAudioSessionCategory.playback,
      );
      expect(
        restAlertAudioContext.iOS.options,
        contains(AVAudioSessionOptions.duckOthers),
      );
      expect(
        restAlertAudioContext.iOS.options,
        isNot(contains(AVAudioSessionOptions.mixWithOthers)),
      );
      expect(
        restAlertAudioContext.iOS.options,
        isNot(
          contains(AVAudioSessionOptions.interruptSpokenAudioAndMixWithOthers),
        ),
      );
    });

    test('platform context carries the Android configuration', () {
      expect(restAlertAudioContext.android, restAlertAudioContextAndroid);
    });
  });
}
