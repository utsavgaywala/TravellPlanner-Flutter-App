import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../providers/app_providers.dart';

/// Settings screen with theme toggle, notifications, and app info.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = false;

  void _showSnack(String msg, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        if (icon != null) ...[ Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 10) ],
        Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: Colors.white.withValues(alpha: 0.1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('SETTINGS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.mainBgGradient),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            // Appearance
            _SectionTitle('APPEARANCE'),
            _SettingsTile(
              icon: LucideIcons.moon,
              label: 'Dark Mode',
              color: Colors.white,
              trailing: Switch.adaptive(
                value: isDarkMode,
                activeColor: Colors.white,
                onChanged: (v) => ref.read(themeModeProvider.notifier).state = v,
              ),
            ),
            _SettingsTile(icon: LucideIcons.languages, label: 'Language', color: Colors.white, subtitle: 'English', onTap: () => _showSnack('Language selection coming soon', icon: LucideIcons.languages)),
            _SettingsTile(icon: LucideIcons.type, label: 'Font Size', color: Colors.white, subtitle: 'Medium', onTap: () => _showSnack('Font size adjustment coming soon', icon: LucideIcons.type)),

            const SizedBox(height: 32),
            _SectionTitle('NOTIFICATIONS'),
            _SettingsTile(
              icon: LucideIcons.bell, 
              label: 'Push Notifications', 
              color: Colors.white,
              trailing: Switch.adaptive(
                value: _pushNotifications, 
                activeColor: Colors.white, 
                onChanged: (v) {
                  setState(() => _pushNotifications = v);
                  _showSnack(v ? 'Push notifications enabled' : 'Push notifications disabled', icon: LucideIcons.bell);
                }
              ),
            ),
            _SettingsTile(
              icon: LucideIcons.mail, 
              label: 'Email Updates', 
              color: Colors.white,
              trailing: Switch.adaptive(
                value: _emailUpdates, 
                activeColor: Colors.white, 
                onChanged: (v) {
                  setState(() => _emailUpdates = v);
                  _showSnack(v ? 'Email updates enabled' : 'Email updates disabled', icon: LucideIcons.mail);
                }
              ),
            ),

            const SizedBox(height: 32),
            _SectionTitle('DATA & STORAGE'),
            _SettingsTile(icon: LucideIcons.cloudDownload, label: 'Offline Data', color: Colors.white, subtitle: '12.4 MB', onTap: () => _showSnack('Offline data synced', icon: LucideIcons.cloudDownload)),
            _SettingsTile(
              icon: LucideIcons.trash2, 
              label: 'Clear Cache', 
              color: Colors.redAccent, 
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF111111),
                    title: const Text('Clear Cache?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    content: const Text('This will clear 12.4 MB of cached data.', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold))),
                      TextButton(
                        onPressed: () { Navigator.pop(ctx); _showSnack('Cache cleared successfully ✓', icon: LucideIcons.check); },
                        child: const Text('CLEAR', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                );
              }
            ),
            _SettingsTile(icon: LucideIcons.download, label: 'Export Data', color: Colors.white, onTap: () => _showSnack('Data export started — check your email', icon: LucideIcons.download)),

            const SizedBox(height: 32),
            _SectionTitle('ABOUT'),
            _SettingsTile(icon: LucideIcons.info, label: 'App Version', color: Colors.white, subtitle: AppConstants.appVersion),
            _SettingsTile(icon: LucideIcons.shield, label: 'Privacy Policy', color: Colors.white, onTap: () => _showSnack('Opening Privacy Policy...', icon: LucideIcons.shield)),
            _SettingsTile(icon: LucideIcons.fileText, label: 'Terms of Service', color: Colors.white, onTap: () => _showSnack('Opening Terms of Service...', icon: LucideIcons.fileText)),
            _SettingsTile(icon: LucideIcons.star, label: 'Rate App', color: Colors.white, onTap: () => _showSnack('Thank you for your support! ⭐', icon: LucideIcons.star)),

            const SizedBox(height: 60),
            Center(
              child: Text(
                '${AppConstants.appName.toUpperCase()} v${AppConstants.appVersion}\nPremium AI Travel Planner',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3), fontWeight: FontWeight.w800, letterSpacing: 2, height: 1.6),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16, left: 4),
    child: Text(
      title, 
      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.label, required this.color, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05), 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40, 
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
            if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
          ])),
          if (trailing != null) trailing! else if (onTap != null) const Icon(LucideIcons.chevronRight, size: 18, color: Colors.white24),
        ]),
      ),
    );
  }
}
