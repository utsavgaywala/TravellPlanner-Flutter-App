import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';
import 'settings_screen.dart';
import '../auth/auth_screen.dart';
import '../trip/trip_detail_screen.dart';

/// Redesigned Profile screen with premium Black & White aesthetics.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _userName = 'ALEX RIDER';

  void _editName() {
    final ctrl = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Edit Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Your name',
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white38)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold))),
          TextButton(
            onPressed: () {
              final newName = ctrl.text.trim().toUpperCase();
              if (newName.isNotEmpty) setState(() => _userName = newName);
              Navigator.pop(ctx);
            },
            child: const Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    final totalSpent = trips.fold<double>(0, (s, t) => s + t.totalSpent);
    final pastTrips = trips.where((t) => t.endDate.isBefore(DateTime.now())).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(gradient: AppColors.mainBgGradient),
          ),
          
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Profile Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PROFILE',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -2),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.settings, color: Colors.white, size: 24),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Avatar (No background box as requested)
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: _editName,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
                      ),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.pencil, color: Colors.white.withValues(alpha: 0.3), size: 16),
                    ],
                  ),
                ),
                Text(
                  'PLATINUM TRAVELER',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 2),
                ),
                
                const SizedBox(height: 48),
                
                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Trips', value: '${trips.length}')),
                      const SizedBox(width: 16),
                      Expanded(child: _StatCard(label: 'Spent', value: '₹${totalSpent.toStringAsFixed(0)}')),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Menu List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACCOUNT SETTINGS',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2),
                      ),
                      const SizedBox(height: 20),
                      _MenuItem(
                        icon: LucideIcons.heart, 
                        label: 'Saved Destinations',
                        onTap: () => _showSavedDestinations(context),
                      ),
                      _MenuItem(
                        icon: LucideIcons.history, 
                        label: 'Past Journeys',
                        onTap: () => _showPastJourneys(context, pastTrips),
                      ),
                      _MenuItem(
                        icon: LucideIcons.shieldCheck, 
                        label: 'Privacy & Safety',
                        onTap: () => _showPrivacySafety(context),
                      ),
                      const SizedBox(height: 32),
                      _MenuItem(
                        icon: LucideIcons.logOut, 
                        label: 'Sign Out', 
                        isDestructive: true, 
                        onTap: () {
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (route) => false);
                        }
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSavedDestinations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Color(0xFF111111), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Saved Destinations', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 40),
            const Text('❤️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('No saved destinations yet', style: TextStyle(color: Colors.white38)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showPastJourneys(BuildContext context, List trips) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Color(0xFF111111), borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          children: [
            const Text('Past Journeys', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            if (trips.isEmpty)
              const Expanded(child: Center(child: Text('No completed journeys', style: TextStyle(color: Colors.white38))))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, i) {
                    final t = trips[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        title: Text(t.destination, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('MMM yyyy').format(t.startDate), style: const TextStyle(color: Colors.white38)),
                        trailing: const Icon(LucideIcons.chevronRight, color: Colors.white24),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: t.id)));
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPrivacySafety(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Privacy & Safety', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: const Text(
          'Your data is encrypted and stored securely. We do not share your travel plans with third parties without your consent.\n\nTwo-factor authentication is enabled for your account.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('GOT IT', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, this.isDestructive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? Colors.redAccent : Colors.white, size: 20),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? Colors.redAccent : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(LucideIcons.chevronRight, color: Colors.white.withValues(alpha: 0.2), size: 18),
          ],
        ),
      ),
    );
  }
}
