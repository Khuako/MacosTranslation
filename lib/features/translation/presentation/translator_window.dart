import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../../../app/app.dart';
import '../../../app/macos_translator_theme.dart';
import '../../settings/settings_service.dart';
import 'translator_controller.dart';
import 'widgets/language_selector.dart';
import 'widgets/translation_input.dart';
import 'widgets/translation_result_view.dart';

class TranslatorWindow extends StatefulWidget {
  const TranslatorWindow({
    super.key,
    required this.controller,
    required this.settingsService,
    required this.windowMode,
    required this.onHideWindow,
  });

  final TranslatorController controller;
  final SettingsService settingsService;
  final ValueNotifier<TranslatorWindowMode> windowMode;
  final Future<void> Function() onHideWindow;

  @override
  State<TranslatorWindow> createState() => _TranslatorWindowState();
}

class _TranslatorWindowState extends State<TranslatorWindow> {
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.windowMode.addListener(_handleModeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusInput());
  }

  @override
  void dispose() {
    widget.windowMode.removeListener(_handleModeChanged);
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _handleModeChanged() {
    setState(() {});
    if (widget.windowMode.value == TranslatorWindowMode.translate) {
      _focusInput();
    }
  }

  void _focusInput() {
    if (mounted) {
      _inputFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): _HideWindowIntent(),
        SingleActivator(LogicalKeyboardKey.keyW, meta: true):
            _HideWindowIntent(),
      },
      child: Actions(
        actions: {
          _HideWindowIntent: CallbackAction<_HideWindowIntent>(
            onInvoke: (_) {
              widget.onHideWindow();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: DragToMoveArea(
                  child: _GeminiPanel(
                    width: 520,
                    constraints: const BoxConstraints(
                      minHeight: 238,
                      maxHeight: 420,
                    ),
                    child: ValueListenableBuilder<TranslatorWindowMode>(
                      valueListenable: widget.windowMode,
                      builder: (context, mode, _) {
                        return mode == TranslatorWindowMode.settings
                            ? _SettingsPanel(
                                controller: widget.controller,
                                onBack: () {
                                  widget.windowMode.value =
                                      TranslatorWindowMode.translate;
                                },
                              )
                            : _TranslatePanel(
                                controller: widget.controller,
                                settingsService: widget.settingsService,
                                inputFocusNode: _inputFocusNode,
                              );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GeminiPanel extends StatelessWidget {
  const _GeminiPanel({
    required this.width,
    required this.constraints,
    required this.child,
  });

  final double width;
  final BoxConstraints constraints;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MacTranslatorKit.radiusWindow),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MacTranslatorKit.radiusWindow),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: MacTranslatorKit.glassSurface,
            borderRadius: BorderRadius.circular(MacTranslatorKit.radiusWindow),
            border: Border.all(color: MacTranslatorKit.glassEdgeMuted),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF181B20),
                Color(0xFF101216),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _TranslatePanel extends StatelessWidget {
  const _TranslatePanel({
    required this.controller,
    required this.settingsService,
    required this.inputFocusNode,
  });

  final TranslatorController controller;
  final SettingsService settingsService;
  final FocusNode inputFocusNode;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LanguageRail(
              controller: controller,
              settingsService: settingsService,
            ),
            const SizedBox(height: 14),
            TranslationInput(
              controller: controller.inputController,
              focusNode: inputFocusNode,
              onChanged: controller.onInputChanged,
            ),
            const SizedBox(height: 14),
            TranslationResultView(
              isLoading: controller.isLoading,
              result: controller.result,
              errorMessage: controller.errorMessage,
            ),
          ],
        );
      },
    );
  }
}

class _LanguageRail extends StatelessWidget {
  const _LanguageRail({
    required this.controller,
    required this.settingsService,
  });

  final TranslatorController controller;
  final SettingsService settingsService;

  Future<void> _saveSourceLanguage(String language) async {
    controller.setSourceLanguage(language);
    await settingsService.save(controller.settings);
  }

  Future<void> _saveTargetLanguage(String language) async {
    controller.setTargetLanguage(language);
    await settingsService.save(controller.settings);
  }

  Future<void> _saveSwappedLanguages() async {
    controller.swapLanguages();
    await settingsService.save(controller.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LanguageSelector(
            value: controller.settings.sourceLanguage,
            onChanged: (language) {
              _saveSourceLanguage(language);
            },
          ),
        ),
        const SizedBox(width: 8),
        _LiquidSwapButton(
          onPressed: _saveSwappedLanguages,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LanguageSelector(
            value: controller.settings.targetLanguage,
            onChanged: (language) {
              _saveTargetLanguage(language);
            },
          ),
        ),
      ],
    );
  }
}

class _LiquidSwapButton extends StatefulWidget {
  const _LiquidSwapButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_LiquidSwapButton> createState() => _LiquidSwapButtonState();
}

class _LiquidSwapButtonState extends State<_LiquidSwapButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 90),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 130),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pressed
                  ? MacTranslatorKit.glassSurfaceBarely
                  : (_hovered
                      ? MacTranslatorKit.glassInsetStrong
                      : MacTranslatorKit.glassInset),
              border: Border.all(
                color: _hovered
                    ? MacTranslatorKit.glassEdge
                    : MacTranslatorKit.glassEdgeMuted,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.swap_horiz_rounded,
                color: MacTranslatorKit.graphite,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.controller,
    required this.onBack,
  });

  final TranslatorController controller;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final settings = controller.settings;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Shortcut: ${settings.shortcutDescription}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Languages: ${settings.sourceLanguage.toUpperCase()} to ${settings.targetLanguage.toUpperCase()}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Provider: ${settings.selectedProviderId}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        );
      },
    );
  }
}

class _HideWindowIntent extends Intent {
  const _HideWindowIntent();
}
