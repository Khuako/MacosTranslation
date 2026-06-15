import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotkeyService {
  HotKey? _toggleHotKey;

  Future<void> registerToggleHotKey({
    required Future<void> Function() onPressed,
  }) async {
    await hotKeyManager.unregisterAll();

    final hotKey = HotKey(
      key: PhysicalKeyboardKey.space,
      modifiers: [HotKeyModifier.control, HotKeyModifier.alt],
      scope: HotKeyScope.system,
    );

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (_) {
        onPressed();
      },
    );
    _toggleHotKey = hotKey;
  }

  Future<void> dispose() async {
    final hotKey = _toggleHotKey;
    if (hotKey != null) {
      await hotKeyManager.unregister(hotKey);
    }
    _toggleHotKey = null;
  }
}
