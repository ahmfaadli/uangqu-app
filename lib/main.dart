import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';
import 'screens/report_screen.dart';
import 'screens/savings_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // INIT DATE FORMAT
  // ============================================================

  await initializeDateFormatting(
    'id_ID',
    null,
  );

  // ============================================================
  // LOAD THEME
  // ============================================================

  await AppTheme.loadTheme();

  // ============================================================
  // RUN APP
  // ============================================================

  runApp(
    const UangQuApp(),
  );
}

// ============================================================
// APP
// ============================================================

class UangQuApp extends StatelessWidget {
  const UangQuApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeMode,
      builder: (
        context,
        themeMode,
        child,
      ) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'UangQu',

          // ======================================================
          // LIGHT
          // ======================================================

          theme: AppTheme.lightTheme,

          // ======================================================
          // DARK
          // ======================================================

          darkTheme: AppTheme.darkTheme,

          // ======================================================
          // THEME YANG AKTIF
          // ======================================================

          themeMode: themeMode,

          // ======================================================
          // HOME
          // ======================================================

          home: const MainNavigation(),
        );
      },
    );
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({
    super.key,
  });

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {

  // ==========================================================
  // WARNA UTAMA
  // ==========================================================

  static const Color primaryPurple =
      Color(0xFF7C3AED);

  static const Color inactiveColor =
      Color(0xFF98A2B3);

  // ==========================================================
  // INDEX HALAMAN
  // ==========================================================

  int currentIndex = 0;

  // ==========================================================
  // HALAMAN
  // ==========================================================

  final List<Widget> pages = const [
    HomeScreen(),
    ReportScreen(),
    SavingsScreen(),
    SettingsScreen(),
  ];

  // ==========================================================
  // BUKA TAMBAH TRANSAKSI
  // ==========================================================

  Future<void> openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddTransactionScreen(),
      ),
    );
  }

  // ==========================================================
  // PINDAH HALAMAN
  // ==========================================================

  void changePage(int index) {
    if (currentIndex == index) {
      return;
    }

    setState(() {
      currentIndex = index;
    });
  }

  // ==========================================================
  // ITEM NAVIGASI
  // ==========================================================

  Widget navigationItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected =
        currentIndex == index;

    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            changePage(index);
          },
          borderRadius:
              BorderRadius.circular(16),
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [

                // =================================================
                // ICON
                // =================================================

                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration:
                      BoxDecoration(
                    color: isSelected
                        ? isDark
                            ? const Color(
                                0xFF2A2140,
                              )
                            : const Color(
                                0xFFF3E8FF,
                              )
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 21,
                    color: isSelected
                        ? primaryPurple
                        : inactiveColor,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                // =================================================
                // LABEL
                // =================================================

                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? primaryPurple
                        : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOMBOL TAMBAH
  // ============================================================

  Widget addButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: openAddTransaction,
        customBorder: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryPurple,

            border: Border.all(
              color: Theme.of(context)
                  .scaffoldBackgroundColor,
              width: 4,
            ),

            boxShadow: [
              BoxShadow(
                color: primaryPurple
                    .withOpacity(0.30),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AREA TOMBOL TAMBAH
  // ============================================================

  Widget centerAddButton() {
    return SizedBox(
      width: 78,
      height: 68,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -30,
            child: addButton(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget buildBottomNavigation() {
    final bool isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final Color navigationBackground =
        Theme.of(context).cardColor;

    final Color borderColor = isDark
        ? const Color(0xFF2A2A31)
        : const Color(0xFFF0EEF5);

    return Container(
      decoration: BoxDecoration(
        color: navigationBackground,

        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 1,
          ),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              isDark ? 0.20 : 0.06,
            ),
            blurRadius: 18,
            offset: const Offset(0, -5),
          ),
        ],
      ),

      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [

              // ==================================================
              // BERANDA
              // ==================================================

              navigationItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                index: 0,
              ),

              // ==================================================
              // REKAPAN
              // ==================================================

              navigationItem(
                icon: Icons.bar_chart_rounded,
                label: 'Rekapan',
                index: 1,
              ),

              // ==================================================
              // TOMBOL TAMBAH
              // ==================================================

              centerAddButton(),

              // ==================================================
              // TABUNGAN
              // ==================================================

              navigationItem(
                icon: Icons.savings_rounded,
                label: 'Tabungan',
                index: 2,
              ),

              // ==================================================
              // SETTING
              // ==================================================

              navigationItem(
                icon: Icons.settings_rounded,
                label: 'Setting',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // BACKGROUND MENGIKUTI THEME
      // ========================================================

      backgroundColor:
          Theme.of(context)
              .scaffoldBackgroundColor,

      // ========================================================
      // CONTENT
      // ========================================================

      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar:
          buildBottomNavigation(),
    );
  }
}