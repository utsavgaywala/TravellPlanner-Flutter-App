import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/trip_model.dart';
import '../providers/app_providers.dart';

/// Day-wise itinerary screen with expandable days and editable activities.
class ItineraryScreen extends ConsumerStatefulWidget {
  final String tripId;
  const ItineraryScreen({super.key, required this.tripId});
  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  int _expandedDay = 0;

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripByIdProvider(widget.tripId));
    if (trip == null) return const Scaffold(body: Center(child: Text('Trip not found')));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodColor = AppColors.getMoodColor(trip.mood.index);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Itinerary'),
        leading: IconButton(icon: const Icon(LucideIcons.chevronLeft), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(LucideIcons.refreshCw), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔄 Regenerating itinerary...'), behavior: SnackBarBehavior.floating)); })],
      ),
      body: trip.itinerary.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('No itinerary yet', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Generate one from the Create Trip screen', style: Theme.of(context).textTheme.bodyMedium),
          ]))
        : ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: trip.itinerary.length,
            itemBuilder: (context, index) {
              final day = trip.itinerary[index];
              final isExpanded = _expandedDay == index;
              return _DayCard(
                day: day,
                isExpanded: isExpanded,
                moodColor: moodColor,
                isDark: isDark,
                onToggle: () => setState(() => _expandedDay = isExpanded ? -1 : index),
                onActivityToggle: (actId) => ref.read(tripsProvider.notifier).toggleActivityCompletion(widget.tripId, day.dayNumber, actId),
              );
            },
          ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final ItineraryDay day;
  final bool isExpanded;
  final Color moodColor;
  final bool isDark;
  final VoidCallback onToggle;
  final ValueChanged<String> onActivityToggle;

  const _DayCard({required this.day, required this.isExpanded, required this.moodColor, required this.isDark, required this.onToggle, required this.onActivityToggle});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isExpanded ? Border.all(color: moodColor.withValues(alpha: 0.3), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        // Day header
        GestureDetector(
          onTap: onToggle,
          child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(gradient: LinearGradient(colors: [moodColor, moodColor.withValues(alpha: 0.7)]), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text('${day.dayNumber}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(day.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Row(children: [
                Text(DateFormat('EEE, MMM d').format(day.date), style: Theme.of(context).textTheme.bodySmall),
                if (day.weatherIcon != null) ...[
                  const SizedBox(width: 8),
                  Text('${day.weatherIcon} ${day.temperature?.toStringAsFixed(0)}°', style: const TextStyle(fontSize: 12)),
                ],
              ]),
            ])),
            AnimatedRotation(turns: isExpanded ? 0.5 : 0, duration: const Duration(milliseconds: 300), child: const Icon(LucideIcons.chevronDown, size: 24)),
          ])),
        ),

        // Activities (expandable)
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Column(children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...day.activities.map((act) => _ActivityTile(activity: act, moodColor: moodColor, onToggle: () => onActivityToggle(act.id))),
          ])),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ]),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Activity activity;
  final Color moodColor;
  final VoidCallback onToggle;
  const _ActivityTile({required this.activity, required this.moodColor, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: activity.isCompleted ? AppColors.tertiary.withValues(alpha: 0.06) : (Theme.of(context).brightness == Brightness.dark ? AppColors.darkBackground.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(14),
          border: activity.isCompleted ? Border.all(color: AppColors.tertiary.withValues(alpha: 0.2)) : null,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Timeline dot
          Column(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: moodColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(activity.icon, style: const TextStyle(fontSize: 18)))),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(activity.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, decoration: activity.isCompleted ? TextDecoration.lineThrough : null))),
              if (activity.isCompleted) const Icon(LucideIcons.circleCheck, color: AppColors.tertiary, size: 18),
            ]),
            const SizedBox(height: 2),
            Text(activity.description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(children: [
              Icon(LucideIcons.clock, size: 12, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(activity.timeSlot.toString(), style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              if (activity.estimatedCost != null) ...[
                const SizedBox(width: 12),
                Icon(LucideIcons.banknote, size: 12, color: Colors.grey[500]),
                Text('${activity.estimatedCost!.toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500)),
              ],
              if (activity.location != null) ...[
                const SizedBox(width: 12),
                Icon(LucideIcons.mapPin, size: 12, color: Colors.grey[500]),
                Flexible(child: Text(activity.location!, style: TextStyle(fontSize: 11, color: Colors.grey[500]), overflow: TextOverflow.ellipsis)),
              ],
            ]),
          ])),
        ]),
      ),
    );
  }
}
