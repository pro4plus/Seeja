import 'dart:math';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../services/settings_store.dart';

class SoundManager {
  static final List<AudioPlayer> _pool = List.generate(6, (_) => AudioPlayer());
  static int _poolIdx = 0;
  static final Random _rng = Random();

  static Future<void> init() async {}

  static Future<void> play(String assetName, {bool varyPitch = false}) async {
    if (!SettingsStore.soundEnabled) return;
    try {
      final player = _pool[_poolIdx];
      _poolIdx = (_poolIdx + 1) % _pool.length;
      await player.setAsset('assets/sounds/$assetName');
      await player.setVolume(SettingsStore.soundVolume);
      await player.setSpeed(varyPitch ? (0.96 + _rng.nextDouble() * 0.08) : 1.0);
      await player.play();
    } catch (_) {}
  }

  static void tap() {
    play('ui_tap.wav', varyPitch: true);
    if (SettingsStore.hapticsEnabled) HapticFeedback.selectionClick();
  }

  static void select() {
    play('select.wav', varyPitch: true);
    if (SettingsStore.hapticsEnabled) HapticFeedback.selectionClick();
  }

  static void place() {
    play('place_${_rng.nextInt(3) + 1}.wav', varyPitch: true);
    if (SettingsStore.hapticsEnabled) HapticFeedback.lightImpact();
  }

  static void moveLand() {
    play('land.wav');
    if (SettingsStore.hapticsEnabled) HapticFeedback.lightImpact();
  }

  static void capture(int count) {
    if (count > 1) {
      play('capture_multi.wav');
      if (SettingsStore.hapticsEnabled) HapticFeedback.heavyImpact();
    } else {
      play('capture_${_rng.nextInt(3) + 1}.wav');
      if (SettingsStore.hapticsEnabled) HapticFeedback.mediumImpact();
    }
  }

  static void invalid() {
    play('invalid.wav');
    if (SettingsStore.hapticsEnabled) HapticFeedback.heavyImpact();
  }

  static void win() {
    play('win.wav');
    if (SettingsStore.hapticsEnabled) HapticFeedback.mediumImpact();
  }

  static void lose() => play('lose.wav');
  static void draw() => play('draw.wav');
}
