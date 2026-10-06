import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Ungu tetap menjadi warna utama aplikasi
    const purpleColor = Color(0xFF7C3AED);

    // Warna NavigationBar mengikuti tema
    final backgroundColor = theme.cardColor;

    final unselectedColor = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF667085);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,

      // Background mengikuti Light / Dark Mode
      backgroundColor: backgroundColor,

      // Warna item aktif tetap ungu
      indicatorColor: isDark
          ? const Color(0xFF2A2140)
          : const Color(0xFFF3E8FF),

      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

      destinations: [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: unselectedColor,
          ),
          selectedIcon: const Icon(
            Icons.home,
            color: purpleColor,
          ),
          label: 'Beranda',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.bar_chart_outlined,
            color: unselectedColor,
          ),
          selectedIcon: const Icon(
            Icons.bar_chart,
            color: purpleColor,
          ),
          label: 'Rekapan',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.savings_outlined,
            color: unselectedColor,
          ),
          selectedIcon: const Icon(
            Icons.savings,
            color: purpleColor,
          ),
          label: 'Tabungan',
        ),

        NavigationDestination(
          icon: Icon(
            Icons.person_outline,
            color: unselectedColor,
          ),
          selectedIcon: const Icon(
            Icons.person,
            color: purpleColor,
          ),
          label: 'Profil',
        ),
      ],
    );
  }
}