import 'package:window_manager/window_manager.dart';

import '../desktop/hotkeys/hotkey_service.dart';
import '../desktop/tray/tray_service.dart';
import '../desktop/window/window_service.dart';
import '../features/settings/settings_service.dart';
import '../features/translation/data/providers/google_translator_provider.dart';
import '../features/translation/data/repositories/translation_repository_impl.dart';
import '../features/translation/domain/services/translation_service.dart';
import '../features/translation/presentation/translator_controller.dart';

class AppDependencies {
  const AppDependencies({
    required this.settingsService,
    required this.translationService,
    required this.translatorController,
    required this.windowService,
    required this.hotkeyService,
    required this.trayService,
  });

  final SettingsService settingsService;
  final TranslationService translationService;
  final TranslatorController translatorController;
  final WindowService windowService;
  final HotkeyService hotkeyService;
  final TrayService trayService;

  Future<void> shutdown() async {
    translatorController.dispose();
    await hotkeyService.dispose();
    await trayService.dispose();
    await windowManager.destroy();
  }
}

Future<AppDependencies> bootstrap() async {
  await windowManager.ensureInitialized();

  final settingsService = SettingsService();
  final settings = await settingsService.load();
  final provider = GoogleTranslatorProvider();
  final repository = TranslationRepositoryImpl(providers: [provider]);
  final translationService = TranslationService(repository: repository);
  final translatorController = TranslatorController(
    translationService: translationService,
    initialSettings: settings,
  );
  final windowService = WindowService();

  await windowService.initialize();

  return AppDependencies(
    settingsService: settingsService,
    translationService: translationService,
    translatorController: translatorController,
    windowService: windowService,
    hotkeyService: HotkeyService(),
    trayService: TrayService(),
  );
}
