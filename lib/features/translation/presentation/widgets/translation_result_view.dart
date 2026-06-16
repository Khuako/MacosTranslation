import 'package:flutter/material.dart';

import '../../../../app/macos_translator_theme.dart';
import '../../domain/entities/translation_result.dart';

class TranslationResultView extends StatelessWidget {
  const TranslationResultView({
    super.key,
    required this.isLoading,
    required this.result,
    required this.errorMessage,
  });

  final bool isLoading;
  final TranslationResult? result;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final errorMessage = this.errorMessage;
    final result = this.result;

    if (isLoading) {
      return const _ResultShell(
        child: Align(
          alignment: Alignment.centerLeft,
          child: _BreathingLoader(),
        ),
      );
    }

    if (errorMessage != null) {
      return _ResultShell(
        child: Text(
          errorMessage,
          style: const TextStyle(color: MacTranslatorKit.error, fontSize: 14),
        ),
      );
    }

    if (result == null) {
      return const _ResultShell(
        child: SizedBox.shrink(),
      );
    }

    return _ResultShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result.translatedText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MacTranslatorKit.ink,
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (result.alternatives.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final alternative in result.alternatives.take(3))
                  _ResultChip(text: alternative),
              ],
            ),
          ],
          if (result.contextNotes.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final note in result.contextNotes.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: MacTranslatorKit.secondaryInk,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 144),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: MacTranslatorKit.glassSurfaceBarely,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: MacTranslatorKit.hairline, width: 0.8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: MacTranslatorKit.ink,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BreathingLoader extends StatefulWidget {
  const _BreathingLoader();

  @override
  State<_BreathingLoader> createState() => _BreathingLoaderState();
}

class _BreathingLoaderState extends State<_BreathingLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOutCubic.transform(_controller.value);
        return SizedBox(
          width: 46,
          height: 18,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++) ...[
                _LoaderDot(
                  opacity: (0.30 + (0.56 * ((t + i * 0.24) % 1.0)))
                      .clamp(0.30, 0.86),
                  size: i == 1 ? 8 : 7,
                ),
                if (i != 2) const SizedBox(width: 6),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LoaderDot extends StatelessWidget {
  const _LoaderDot({
    required this.opacity,
    required this.size,
  });

  final double opacity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: MacTranslatorKit.graphite.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: MacTranslatorKit.graphite.withValues(alpha: opacity * 0.18),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

class _ResultShell extends StatelessWidget {
  const _ResultShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: MacTranslatorKit.glassInset,
        borderRadius: BorderRadius.circular(MacTranslatorKit.radiusField),
        border: Border.all(color: MacTranslatorKit.hairline, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}
