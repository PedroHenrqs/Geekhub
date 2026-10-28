import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      avatar: icon == null
          ? null
          : Icon(icon,
              size: 18,
              color: selected ? AppColors.accent : AppColors.textSecondary),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.accentSoft,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: selected ? AppColors.accent : AppColors.border),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.accent : AppColors.textSecondary,
      ),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
