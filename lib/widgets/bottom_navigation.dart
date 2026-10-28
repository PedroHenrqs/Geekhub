import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation(
      {super.key, required this.currentIndex, required this.onSelected});

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded, color: AppColors.accent),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.collections_bookmark_outlined),
          selectedIcon:
              Icon(Icons.collections_bookmark_rounded, color: AppColors.accent),
          label: 'Estante',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded, color: AppColors.accent),
          label: 'Estatísticas',
        ),
      ],
    );
  }
}
