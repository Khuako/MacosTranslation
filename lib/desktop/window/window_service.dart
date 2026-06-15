import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowService with WindowListener {
  Future<void> initialize() async {
    windowManager.addListener(this);
    const windowOptions = WindowOptions(
      size: Size(500, 260),
      minimumSize: Size(480, 240),
      maximumSize: Size(560, 340),
      center: true,
      alwaysOnTop: true,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
      backgroundColor: Colors.transparent,
    );

    await windowManager.setPreventClose(true);
    await windowManager.setAsFrameless();
    await windowManager.setBackgroundColor(Colors.transparent);
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.hide();
    });
  }

  Future<void> showTranslator() async {
    await windowManager.setAlwaysOnTop(true);
    await windowManager.center();
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> hideTranslator() => windowManager.hide();

  Future<void> toggleTranslator() async {
    if (await windowManager.isVisible()) {
      await hideTranslator();
    } else {
      await showTranslator();
    }
  }

  @override
  void onWindowClose() {
    hideTranslator();
  }
}
