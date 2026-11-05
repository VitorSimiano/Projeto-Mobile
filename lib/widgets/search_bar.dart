import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Campo de busca do app. Na Home funciona só como "botão" (readOnly);
/// na tela de pesquisa recebe o texto digitado.
class CineSearchBar extends StatelessWidget {
  const CineSearchBar({
    super.key,
    this.controller,
    this.hint = 'Buscar filmes e séries',
    this.readOnly = false,
    this.autofocus = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController? controller;
  final String hint;
  final bool readOnly;
  final bool autofocus;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    Widget? suffix;
    if (controller != null && onClear != null) {
      suffix = ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller!,
        builder: (context, value, _) => value.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textSecondary,
                onPressed: onClear,
              ),
      );
    }

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        cursorColor: AppColors.accent,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          suffixIcon: suffix,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
