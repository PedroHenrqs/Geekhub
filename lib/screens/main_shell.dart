import 'package:flutter/material.dart';

import '../widgets/bottom_navigation.dart';
import 'bookshelf_screen.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserva o estado de cada aba sem duplicar telas.
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onOpenTab: _go),
          BookshelfScreen(onOpenTab: _go),
          StatisticsScreen(onOpenTab: _go),
        ],
      ),
      bottomNavigationBar:
          AppBottomNavigation(currentIndex: _index, onSelected: _go),
    );
  }
}
