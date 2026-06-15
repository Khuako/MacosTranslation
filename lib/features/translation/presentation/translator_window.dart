import 'dart:ui';

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
                  child: _LiquidGlassPanel(
                    width: 500,
                    constraints: const BoxConstraints(
                      minHeight: 240,
                      maxHeight: 340,
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

class _LiquidGlassPanel extends StatelessWidget {
  const _LiquidGlassPanel({
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MacTranslatorKit.radiusWindow),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: MacTranslatorKit.glassSurface,
                    borderRadius: BorderRadius.circular(
                      MacTranslatorKit.radiusWindow,
                    ),
                    border: Border.all(
                      color: MacTranslatorKit.glassEdge,
                      width: 0.9,
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        MacTranslatorKit.glassSurface,
                        MacTranslatorKit.glassSurfaceSoft,
                        MacTranslatorKit.glassSurfaceBarely,
                      ],
                      stops: [0, 0.48, 1],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      MacTranslatorKit.radiusWindow,
                    ),
                    gradient: const RadialGradient(
                      center: Alignment(-0.75, -0.85),
                      radius: 1.2,
                      colors: [
                        Color(0xBFFFFFFF),
                        Color(0x00FFFFFF),
                      ],
                      stops: [0, 0.55],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _LiquidGlassHighlightPainter()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassHighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.7),
          Colors.white.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 36));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, size.width - 2, 38),
        const Radius.circular(MacTranslatorKit.radiusWindow - 1),
      ),
      topPaint,
    );

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          MacTranslatorKit.glassEdge,
          MacTranslatorKit.glassEdgeMuted,
          MacTranslatorKit.hairline,
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(MacTranslatorKit.radiusWindow),
      ).deflate(0.5),
      edgePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
            const SizedBox(height: 12),
            TranslationInput(
              controller: controller.inputController,
              focusNode: inputFocusNode,
              onChanged: controller.onInputChanged,
            ),
            const SizedBox(height: 12),
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
            label: 'From',
            value: controller.settings.sourceLanguage,
            onChanged: (language) {
              _saveSourceLanguage(language);
            },
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Swap languages',
          child: IconButton(
            onPressed: _saveSwappedLanguages,
            style: IconButton.styleFrom(
              fixedSize: const Size(42, 42),
              backgroundColor: MacTranslatorKit.glassSurfaceSoft,
              foregroundColor: MacTranslatorKit.graphite,
              shape: const CircleBorder(),
              side: const BorderSide(color: MacTranslatorKit.glassEdgeMuted),
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 21),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LanguageSelector(
            label: 'To',
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
