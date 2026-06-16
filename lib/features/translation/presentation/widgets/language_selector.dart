import 'package:flutter/material.dart';

import '../../../../app/macos_translator_theme.dart';

const supportedLanguageNames = <String, String>{
  'ru': 'Russian',
  'en': 'English',
};

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedValue = supportedLanguageNames.containsKey(value) ? value : 'ru';

    return PopupMenuButton<String>(
      tooltip: null,
      initialValue: selectedValue,
      color: MacTranslatorKit.glassSurfaceSoft,
      surfaceTintColor: Colors.transparent,
      menuPadding: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MacTranslatorKit.radiusControl),
        side: const BorderSide(color: MacTranslatorKit.hairline),
      ),
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final entry in supportedLanguageNames.entries)
          PopupMenuItem(
            value: entry.key,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              return TextStyle(
                color: states.contains(WidgetState.disabled)
                    ? MacTranslatorKit.mutedInk
                    : MacTranslatorKit.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              );
            }),
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: entry.key == selectedValue
                    ? MacTranslatorKit.glassSurfaceBarely
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(entry.key.toUpperCase()),
            ),
          ),
      ],
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: MacTranslatorKit.glassInset,
          borderRadius: BorderRadius.circular(MacTranslatorKit.radiusControl),
          border: Border.all(color: MacTranslatorKit.hairline, width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedValue.toUpperCase(),
              style: const TextStyle(
                color: MacTranslatorKit.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: MacTranslatorKit.secondaryInk,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
