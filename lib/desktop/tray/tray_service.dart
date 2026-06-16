import 'package:tray_manager/tray_manager.dart';

class TrayService with TrayListener {
  static const _showTranslatorKey = 'show_translator';
  static const _settingsKey = 'settings';
  static const _quitKey = 'quit';

  Future<void> Function()? _onShowTranslator;
  Future<void> Function()? _onShowSettings;
  Future<void> Function()? _onQuit;

  Future<void> initialize({
    required Future<void> Function() onShowTranslator,
    required Future<void> Function() onShowSettings,
    required Future<void> Function() onQuit,
  }) async {
    _onShowTranslator = onShowTranslator;
    _onShowSettings = onShowSettings;
    _onQuit = onQuit;
    trayManager.addListener(this);

    await trayManager.setIcon(
      'assets/tray_icon.png',
      isTemplate: true,
      iconSize: 18,
    );
    await trayManager.setToolTip('Menu Translator');
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: _showTranslatorKey, label: 'Show Translator'),
          MenuItem(key: _settingsKey, label: 'Settings'),
          MenuItem.separator(),
          MenuItem(key: _quitKey, label: 'Quit'),
        ],
      ),
    );
  }

  @override
  void onTrayIconMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case _showTranslatorKey:
        _onShowTranslator?.call();
        break;
      case _settingsKey:
        _onShowSettings?.call();
        break;
      case _quitKey:
        _onQuit?.call();
        break;
    }
  }

  Future<void> dispose() async {
    trayManager.removeListener(this);
    await trayManager.destroy();
  }
}
