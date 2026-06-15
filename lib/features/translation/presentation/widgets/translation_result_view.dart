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
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Translating...',
              style: TextStyle(
                color: MacTranslatorKit.secondaryInk,
                fontSize: 13,
              ),
            ),
          ],
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
        child: Text(
          'Translation appears here',
          style: TextStyle(color: MacTranslatorKit.mutedInk, fontSize: 13),
        ),
      );
    }

    return _ResultShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            result.translatedText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: MacTranslatorKit.ink,
              fontSize: 25,
              height: 1.15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${result.sourceLanguage.toUpperCase()} to ${result.targetLanguage.toUpperCase()}',
            style: const TextStyle(
              color: MacTranslatorKit.mutedInk,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: MacTranslatorKit.glassInset,
        borderRadius: BorderRadius.circular(MacTranslatorKit.radiusField),
        border: Border.all(color: MacTranslatorKit.glassEdgeMuted, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: MacTranslatorKit.glassEdgeMuted,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}
