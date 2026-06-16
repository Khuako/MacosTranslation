import 'package:flutter/material.dart';

import '../../../../app/macos_translator_theme.dart';

class TranslationInput extends StatelessWidget {
  const TranslationInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      minLines: 1,
      maxLines: 2,
      textInputAction: TextInputAction.done,
      cursorColor: MacTranslatorKit.graphite,
      style: const TextStyle(
        color: MacTranslatorKit.ink,
        fontSize: 21,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: MacTranslatorKit.glassInsetStrong,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MacTranslatorKit.radiusField),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MacTranslatorKit.radiusField),
          borderSide: const BorderSide(
            color: MacTranslatorKit.hairline,
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MacTranslatorKit.radiusField),
          borderSide: const BorderSide(color: MacTranslatorKit.accent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 15,
        ),
      ),
      onChanged: (_) => onChanged(),
    );
  }
}
