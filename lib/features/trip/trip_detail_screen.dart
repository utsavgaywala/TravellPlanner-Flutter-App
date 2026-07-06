import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/trip_model.dart';
import '../providers/app_providers.dart';
import '../itinerary/itinerary_screen.dart';
import '../itinerary/timeline_screen.dart';
import '../budget/budget_screen.dart';

/// Trip detail screen showing overview, itinerary, packing list, and actions.
class TripDetailScreen extends ConsumerWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripByIdProvider(tripId));
    if (trip == null) return const Scaffold(body: Center(child: Text('Trip not found')));
    final moodColor = AppColors.getMoodColor(trip.mood.index);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
        // Header
        SliverAppBar(expandedHeight: 220, pinned: true,
          leading: IconButton(icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.chevronLeft, color: Colors.white, size: 20)), onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(
              icon: Icon(
                trip.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: trip.isFavorite ? Colors.redAccent : Colors.white,
              ),
              onPressed: () => ref.read(tripsProvider.notifier).toggleFavorite(tripId),
            ),
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: Colors.white70),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(trip.destination, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
            background: Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [moodColor, moodColor.withValues(alpha: 0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Stack(children: [
                Positioned(top: -40, right: -30, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.05)))),
                Positioned(bottom: -60, left: -40, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.03)))),
                Center(child: Text(trip.mood.emoji, style: const TextStyle(fontSize: 60))),
              ]),
            ),
          ),
        ),

        // Info Cards
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Date & Duration
          Row(children: [
            _InfoChip(icon: LucideIcons.calendar, label: '${DateFormat('MMM d').format(trip.startDate)} – ${DateFormat('MMM d').format(trip.endDate)}', color: AppColors.primary),
            const SizedBox(width: 8),
            _InfoChip(icon: LucideIcons.clock, label: '${trip.durationDays} days', color: AppColors.tertiary),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            _InfoChip(icon: LucideIcons.wallet, label: '\$${trip.budget.toStringAsFixed(0)} budget', color: AppColors.moodLuxury),
            const SizedBox(width: 8),
            _InfoChip(icon: LucideIcons.smile, label: '${trip.mood.emoji} ${trip.mood.label}', color: moodColor),
          ]),

          const SizedBox(height: 24),

          // Action Buttons
          Text('Actions', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _ActionButton(icon: LucideIcons.map, label: 'Itinerary', color: AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ItineraryScreen(tripId: tripId))))),
            const SizedBox(width: 10),
            Expanded(child: _ActionButton(icon: LucideIcons.list, label: 'Timeline', color: AppColors.tertiary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TimelineScreen(tripId: tripId))))),
            const SizedBox(width: 10),
            Expanded(child: _ActionButton(icon: LucideIcons.wallet, label: 'Budget', color: AppColors.moodLuxury, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BudgetScreen(tripId: tripId))))),
          ]),

          // Interests
          if (trip.interests.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Interests', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: trip.interests.map((i) => Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: Text(i, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)))).toList()),
          ],

          // Packing List
          if (trip.packingList.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Packing List', style: Theme.of(context).textTheme.headlineSmall),
              Text('${trip.packingList.where((p) => p.isPacked).length}/${trip.packingList.length}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
            ]),
            const SizedBox(height: 8),
            ...trip.packingList.map((item) => _PackingTile(item: item, onToggle: () => ref.read(tripsProvider.notifier).togglePackingItem(tripId, item.id))),
          ],

          // Itinerary Preview
          if (trip.itinerary.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Itinerary Preview', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            ...trip.itinerary.take(3).map((day) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text('${day.dayNumber}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 16)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(day.title, style: Theme.of(context).textTheme.titleMedium),
                  Text('${day.activities.length} activities • ${day.weatherIcon ?? ''} ${day.temperature?.toStringAsFixed(0) ?? ''}°', style: Theme.of(context).textTheme.bodySmall),
                ])),
                const Icon(LucideIcons.chevronRight, size: 20),
              ]),
            )),
          ],

          const SizedBox(height: 100),
        ]))),
      ]),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Delete Trip?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: const Text('This trip and all its data will be permanently removed.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              ref.read(tripsProvider.notifier).removeTrip(tripId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: color), const SizedBox(width: 6), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color))]));
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 18), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withValues(alpha: 0.12))), child: Column(children: [Icon(icon, color: color, size: 24), const SizedBox(height: 6), Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color))])));
}

class _PackingTile extends StatelessWidget {
  final PackingItem item; final VoidCallback onToggle;
  const _PackingTile({required this.item, required this.onToggle});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onToggle, child: Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)), child: Row(children: [
    AnimatedContainer(duration: const Duration(milliseconds: 200), width: 24, height: 24, decoration: BoxDecoration(color: item.isPacked ? AppColors.tertiary : Colors.transparent, borderRadius: BorderRadius.circular(7), border: Border.all(color: item.isPacked ? AppColors.tertiary : Colors.grey.withValues(alpha: 0.3), width: 2)), child: item.isPacked ? const Icon(LucideIcons.check, size: 16, color: Colors.white) : null),
    const SizedBox(width: 12),
    Expanded(child: Text(item.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, decoration: item.isPacked ? TextDecoration.lineThrough : null, color: item.isPacked ? Colors.grey : null))),
    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6)), child: Text(item.category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.primary))),
  ])));
}
