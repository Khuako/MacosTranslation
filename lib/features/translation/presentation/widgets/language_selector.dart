import 'package:flutter/material.dart';

import '../../../../app/macos_translator_theme.dart';

const supportedLanguageNames = <String, String>{
  'ru': 'Russian',
  'en': 'English',
};

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = supportedLanguageNames.containsKey(value) ? value : 'ru';

    return PopupMenuButton<String>(
      tooltip: label,
      initialValue: selectedValue,
      color: MacTranslatorKit.glassSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MacTranslatorKit.radiusControl),
        side: const BorderSide(color: MacTranslatorKit.glassEdgeMuted),
      ),
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final entry in supportedLanguageNames.entries)
          PopupMenuItem(
            value: entry.key,
            child: Text('${entry.value} (${entry.key.toUpperCase()})'),
          ),
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: MacTranslatorKit.glassInset,
          borderRadius: BorderRadius.circular(MacTranslatorKit.radiusControl),
          border: Border.all(color: MacTranslatorKit.glassEdgeMuted, width: 0.8),
          boxShadow: const [
            BoxShadow(
              color: MacTranslatorKit.glassEdgeMuted,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: MacTranslatorKit.secondaryInk,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedValue.toUpperCase(),
                  style: const TextStyle(
                    color: MacTranslatorKit.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: MacTranslatorKit.graphite,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
