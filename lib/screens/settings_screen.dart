import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryPurple =
      Color(0xFF7C3AED);

  static const Color lightPurple =
      Color(0xFFF3E8FF);

  static const Color textDark =
      Color(0xFF18181B);

  static const Color textSecondary =
      Color(0xFF667085);

  static const Color dangerColor =
      Color(0xFFF04438);

  static const Color backgroundColor =
      Color(0xFFF8F7FC);

  // ============================================================
  // VERSION
  // ============================================================

  static const String appVersion =
      '1.0.0';

  // ============================================================
  // THEME
  // ============================================================

  ThemeMode get currentTheme =>
      AppTheme.themeMode.value;

  // ============================================================
  // CHANGE THEME
  // ============================================================

  Future<void> changeTheme(
    ThemeMode mode,
  ) async {
    await AppTheme.setThemeMode(mode);

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // DELETE ALL DATA
  // ============================================================

  Future<void> confirmDeleteAllData() async {
    final bool? confirmed =
        await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus seluruh data?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Semua transaksi, data tabungan, dan riwayat tabungan akan dihapus secara permanen.\n\nTindakan ini tidak dapat dibatalkan.',
            style: TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false);
              },
              child: const Text(
                'Batal',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true);
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    dangerColor,
                foregroundColor:
                    Colors.white,
                elevation: 0,
              ),
              child: const Text(
                'Hapus Semua',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _deleteAllData();
  }

  // ============================================================
  // DELETE DATA
  // ============================================================

  Future<void> _deleteAllData() async {
    try {
      await DatabaseHelper.instance
          .clearAllData();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Seluruh data berhasil dihapus',
          ),
          behavior:
              SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus data: $e',
          ),
          behavior:
              SnackBarBehavior.floating,
          margin:
              const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        currentTheme == ThemeMode.dark;

    final Color pageBackground =
        Theme.of(context).brightness ==
                Brightness.dark
            ? const Color(0xFF111114)
            : backgroundColor;

    final Color cardColor =
        Theme.of(context).brightness ==
                Brightness.dark
            ? const Color(0xFF1C1C21)
            : Colors.white;

    final Color titleColor =
        Theme.of(context).brightness ==
                Brightness.dark
            ? Colors.white
            : textDark;

    final Color subtitleColor =
        Theme.of(context).brightness ==
                Brightness.dark
            ? const Color(0xFFA1A1AA)
            : textSecondary;

    return Scaffold(
      backgroundColor:
          pageBackground,

      body: SafeArea(
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding:
              const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            125,
          ),

          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setting',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight:
                              FontWeight.w700,
                          color: titleColor,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        'Atur aplikasi sesuai kebutuhan kamu',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              subtitleColor,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 42,
                  height: 42,
                  decoration:
                      BoxDecoration(
                    color: isDark
                        ? const Color(
                            0xFF2A2140,
                          )
                        : lightPurple,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color:
                        primaryPurple,
                    size: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ==================================================
            // TEMA
            // ==================================================

            Text(
              'Tampilan',
              style: TextStyle(
                color: titleColor,
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration:
                  BoxDecoration(
                color: cardColor,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: Theme.of(context)
                              .brightness ==
                          Brightness.dark
                      ? const Color(
                          0xFF2A2A31,
                        )
                      : const Color(
                          0xFFF0EEF5,
                        ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildIconBox(
                        icon:
                            Icons.palette_rounded,
                        isDark: isDark,
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'Tema aplikasi',
                              style: TextStyle(
                                color:
                                    titleColor,
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              isDark
                                  ? 'Mode gelap aktif'
                                  : 'Mode terang aktif',
                              style: TextStyle(
                                color:
                                    subtitleColor,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Container(
                    padding:
                        const EdgeInsets.all(4),
                    decoration:
                        BoxDecoration(
                      color: Theme.of(context)
                                  .brightness ==
                              Brightness.dark
                          ? const Color(
                              0xFF111114,
                            )
                          : const Color(
                              0xFFF5F3F9,
                            ),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child:
                              _buildThemeButton(
                            icon:
                                Icons.light_mode_rounded,
                            label: 'Light',
                            selected:
                                !isDark,
                            onTap: () =>
                                changeTheme(
                              ThemeMode.light,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Expanded(
                          child:
                              _buildThemeButton(
                            icon:
                                Icons.dark_mode_rounded,
                            label: 'Dark',
                            selected:
                                isDark,
                            onTap: () =>
                                changeTheme(
                              ThemeMode.dark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // INFORMASI APLIKASI
            // ==================================================

            Text(
              'Informasi',
              style: TextStyle(
                color: titleColor,
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration:
                  BoxDecoration(
                color: cardColor,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: Theme.of(context)
                              .brightness ==
                          Brightness.dark
                      ? const Color(
                          0xFF2A2A31,
                        )
                      : const Color(
                          0xFFF0EEF5,
                        ),
                ),
              ),
              child: Row(
                children: [
                  _buildIconBox(
                    icon:
                        Icons.info_outline_rounded,
                    isDark: isDark,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          'Versi aplikasi',
                          style: TextStyle(
                            color:
                                titleColor,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          'UangQu',
                          style: TextStyle(
                            color:
                                subtitleColor,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    'v$appVersion',
                    style: const TextStyle(
                      color:
                          primaryPurple,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ==================================================
            // DATA
            // ==================================================

            Text(
              'Data',
              style: TextStyle(
                color: titleColor,
                fontSize: 17,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration:
                  BoxDecoration(
                color: cardColor,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color: Theme.of(context)
                              .brightness ==
                          Brightness.dark
                      ? const Color(
                          0xFF2A2A31,
                        )
                      : const Color(
                          0xFFF0EEF5,
                        ),
                ),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),

                leading: Container(
                  width: 42,
                  height: 42,
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFFFEFED,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .delete_outline_rounded,
                    color: dangerColor,
                    size: 22,
                  ),
                ),

                title: Text(
                  'Hapus seluruh data',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                subtitle: Text(
                  'Menghapus semua transaksi dan tabungan',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 11.5,
                  ),
                ),

                trailing: const Icon(
                  Icons
                      .chevron_right_rounded,
                  color:
                      textSecondary,
                ),

                onTap:
                    confirmDeleteAllData,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ICON BOX
  // ============================================================

  Widget _buildIconBox({
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2A2140)
            : lightPurple,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: primaryPurple,
        size: 21,
      ),
    );
  }

  // ============================================================
  // THEME BUTTON
  // ============================================================

  Widget _buildThemeButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final bool dark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? primaryPurple
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected
                  ? Colors.white
                  : dark
                      ? const Color(
                          0xFFA1A1AA,
                        )
                      : textSecondary,
            ),

            const SizedBox(width: 7),

            Text(
              label,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : dark
                        ? const Color(
                            0xFFA1A1AA,
                          )
                        : textSecondary,
                fontSize: 12,
                fontWeight:
                    selected
                        ? FontWeight.w700
                        : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}