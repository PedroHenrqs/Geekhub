import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/open_library_service.dart';
import 'app_chip.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onChanged,
    this.errorText,
    this.hint = 'Pesquisar por título ou autor',
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String hint;

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          style: AppText.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            errorText: errorText,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textSecondary),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (value.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Limpar pesquisa',
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                  ),
                IconButton(
                  tooltip: 'Pesquisar',
                  icon: const Icon(Icons.arrow_forward_rounded),
                  color: AppColors.accent,
                  onPressed: () => onSubmitted(controller.text),
                ),
              ],
            ),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.accent, 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, 1.5),
          ),
        );
      },
    );
  }
}

class SearchTypeSelector extends StatelessWidget {
  const SearchTypeSelector(
      {super.key, required this.value, required this.onChanged});

  final SearchType value;
  final ValueChanged<SearchType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        FilterChipButton(
          label: 'Título',
          icon: Icons.title_rounded,
          selected: value == SearchType.title,
          onTap: () => onChanged(SearchType.title),
        ),
        FilterChipButton(
          label: 'Autor',
          icon: Icons.person_rounded,
          selected: value == SearchType.author,
          onTap: () => onChanged(SearchType.author),
        ),
      ],
    );
  }
}
