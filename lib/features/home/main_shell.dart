import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/app_providers.dart';
import 'home_screen.dart';
import '../trip/create_trip_screen.dart';
import '../itinerary/ai_chat_screen.dart';
import '../budget/budget_screen.dart';
import 'profile_screen.dart';

/// Main application shell with premium Black & White glassmorphic navigation.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final screens = [
      const HomeScreen(),
      const CreateTripScreen(),
      const AIChatScreen(),
      const BudgetScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey<int>(currentIndex),
          child: screens[currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 44),
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: LucideIcons.layoutGrid,
                label: 'HOME',
                isSelected: currentIndex == 0,
                onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 0,
              ),
              _NavItem(
                icon: LucideIcons.plus,
                label: 'PLAN',
                isSelected: currentIndex == 1,
                onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
              ),
              _NavItem(
                icon: LucideIcons.sparkles,
                label: 'AI',
                isSelected: currentIndex == 2,
                onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
                isPrimary: true,
              ),
              _NavItem(
                icon: LucideIcons.wallet,
                label: 'WALLET',
                isSelected: currentIndex == 3,
                onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 3,
              ),
              _NavItem(
                icon: LucideIcons.user,
                label: 'SELF',
                isSelected: currentIndex == 4,
                onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isPrimary;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isPrimary ? 12 : 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: isPrimary ? 24 : 20,
              color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
