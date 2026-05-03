import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_padding.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_sizes.dart';
import '../../../theme/colors.dart';
import '../../settings/logic/theme_mode_notifier.dart';

/// Settings screen: language (locked), theme toggle, notifications, about, version.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.titleSettings,
                style: TextStyle(
                  fontSize: AppSizes.h2(context),
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              AppSpacing.vXl,
              _SettingsCard(
                isDark: isDark,
                children: [
                  // Language — locked to English
                  _SettingRow(
                    label: AppStrings.settingsLanguage,
                    trailing: Text(
                      AppStrings.settingsLanguageValue,
                      style: TextStyle(
                        fontSize: AppSizes.bodyRegular(context),
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    isDark: isDark,
                    isLast: false,
                  ),
                  // Theme
                  _SettingRow(
                    label: AppStrings.settingsTheme,
                    trailing: _ThemeSegment(
                      current: themeMode,
                      onChanged: (mode) =>
                          ref.read(themeModeProvider.notifier).setMode(mode),
                    ),
                    isDark: isDark,
                    isLast: true,
                  ),
                ],
              ),
              AppSpacing.vLg,
              _SettingsCard(
                isDark: isDark,
                children: [
                  _SettingRow(
                    label: AppStrings.settingsNotifications,
                    trailing: Switch.adaptive(
                      value: _notificationsEnabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      onChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                    ),
                    isDark: isDark,
                    isLast: true,
                  ),
                ],
              ),
              AppSpacing.vLg,
              _SettingsCard(
                isDark: isDark,
                children: [
                  _SettingRow(
                    label: AppStrings.settingsAbout,
                    trailing: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                    ),
                    isDark: isDark,
                    isLast: false,
                    onTap: () => _showAboutDialog(context),
                  ),
                  _SettingRow(
                    label: AppStrings.settingsVersion,
                    trailing: Text(
                      '1.0.0 (Phase 2)',
                      style: TextStyle(
                        fontSize: AppSizes.bodyRegular(context),
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
                      ),
                    ),
                    isDark: isDark,
                    isLast: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.settingsAbout),
        content: const Text(AppStrings.settingsAboutText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.close),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card container for a group of settings rows
// ---------------------------------------------------------------------------

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark, required this.children});

  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.card,
        borderRadius: AppRadius.allLg,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(children: children),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual setting row
// ---------------------------------------------------------------------------

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.trailing,
    required this.isDark,
    required this.isLast,
    this.onTap,
  });

  final String label;
  final Widget trailing;
  final bool isDark;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.lg,
        vertical: AppPadding.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.bodyRegular(context),
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          trailing,
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: isLast
          ? content
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.divider,
                  ),
                ),
              ),
              child: content,
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Three-way theme segment control
// ---------------------------------------------------------------------------

class _ThemeSegment extends StatelessWidget {
  const _ThemeSegment({required this.current, required this.onChanged});

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      (AppStrings.settingsThemeSystem, ThemeMode.system),
      (AppStrings.settingsThemeLight, ThemeMode.light),
      (AppStrings.settingsThemeDark, ThemeMode.dark),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: AppRadius.allSm,
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((entry) {
          final (label, mode) = entry;
          final isSelected = current == mode;
          return GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppPadding.sm,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: AppRadius.allXs,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppSizes.bodySmall(context),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textTertiary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
