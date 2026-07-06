import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/trip_model.dart';
import '../providers/app_providers.dart';
import '../trip/trip_detail_screen.dart';

/// Redesigned Home screen with high-end Black & White glassmorphism and Lucide Icons.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    
    final upcomingTrips = trips.where((t) {
      final matchesSearch = t.destination.toLowerCase().contains(searchQuery);
      return t.startDate.isAfter(DateTime.now()) && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(gradient: AppColors.mainBgGradient),
          ),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'EXPLORE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                      letterSpacing: -2,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
                    ),
                  ),
                ],
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SearchBar(),
                      const SizedBox(height: 40),
                      _sectionHeader('Your Journey'),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              if (upcomingTrips.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _EmptyTripCard(isSearching: searchQuery.isNotEmpty),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 420,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: upcomingTrips.length,
                      itemBuilder: (context, index) => _TripCard(trip: upcomingTrips[index]),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _sectionHeader('Inspiration'),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _InspirationCard(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.search, color: Colors.white.withValues(alpha: 0.3), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Where to next?',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: trip.id))),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      gradient: LinearGradient(
                        colors: [Colors.white.withValues(alpha: 0.2), Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(child: Text('🏙️', style: TextStyle(fontSize: 80))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.destination.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(LucideIcons.calendar, color: Colors.white.withValues(alpha: 0.4), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${DateFormat('MMM dd').format(trip.startDate)} - ${DateFormat('MMM dd').format(trip.endDate)}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTripCard extends ConsumerWidget {
  final bool isSearching;
  const _EmptyTripCard({this.isSearching = false});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isSearching ? 'No destinations found' : 'No upcoming trips', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 16)),
            const SizedBox(height: 16),
            if (!isSearching)
              ElevatedButton(
                onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Plan Now', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
          ],
        ),
      ),
    );
  }
}

class _InspirationCard extends ConsumerWidget {
  const _InspirationCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _InspirationItem(
          title: 'Start Planning Now',
          subtitle: 'Use our AI to create your dream itinerary in seconds.',
          icon: '✨',
          onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 1,
        ),
        const SizedBox(height: 16),
        _InspirationItem(
          title: 'Ask AI Assistant',
          subtitle: 'Need travel tips? Our AI companion is ready to help.',
          icon: '🤖',
          onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
        ),
        const SizedBox(height: 16),
        _InspirationItem(
          title: 'Track Your Budget',
          subtitle: 'Keep your spending in check with our smart wallet.',
          icon: '💰',
          onTap: () => ref.read(bottomNavIndexProvider.notifier).state = 3,
        ),
      ],
    );
  }
}

class _InspirationItem extends StatelessWidget {
  final String title, subtitle, icon;
  final VoidCallback onTap;
  const _InspirationItem({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        trailing: const Icon(LucideIcons.chevronRight, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}
