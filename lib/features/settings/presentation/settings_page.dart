import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../theme/colors.dart';
import '../../auth/logic/auth_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  Future<void> _logout() async {
    await AuthController.instance.logout();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.login);
  }

  void _showSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SettingsCard(
              title: 'Dark mode',
              subtitle: 'Use a darker color palette (UI preview only).',
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
            ),
            _SettingsCard(
              title: 'Notifications',
              subtitle: 'Receive case and request updates.',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) =>
                    setState(() => _notificationsEnabled = value),
              ),
            ),
            _SettingsCard(
              title: 'Language',
              subtitle: 'English (Urdu coming soon)',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showSoon('Language settings'),
            ),
            _SettingsCard(
              title: 'Privacy Policy',
              subtitle: 'Read data usage and protection policy',
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => _showSoon('Privacy policy'),
            ),
            _SettingsCard(
              title: 'About App',
              subtitle: 'eDRMP version 1.0.0',
              trailing: const Icon(Icons.info_outline_rounded),
              onTap: () => _showSoon('About section'),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.buttonDanger),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}
