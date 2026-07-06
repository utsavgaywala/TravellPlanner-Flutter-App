import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/trip_model.dart';
import '../providers/app_providers.dart';

/// Vertical timeline view of the trip itinerary.
class TimelineScreen extends ConsumerWidget {
  final String tripId;
  const TimelineScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripByIdProvider(tripId));
    if (trip == null) return const Scaffold(body: Center(child: Text('Trip not found')));
    final moodColor = AppColors.getMoodColor(trip.mood.index);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('${trip.destination} Timeline'),
        leading: IconButton(icon: const Icon(LucideIcons.chevronLeft), onPressed: () => Navigator.pop(context)),
      ),
      body: trip.itinerary.isEmpty
        ? const Center(child: Text('No timeline data'))
        : ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: trip.itinerary.fold<int>(0, (sum, day) => sum + day.activities.length + 1), // +1 for day headers
            itemBuilder: (context, index) {
              // Flatten the itinerary into a list of day headers and activities
              int currentIndex = 0;
              for (final day in trip.itinerary) {
                if (index == currentIndex) {
                  // Day header
                  return _DayHeader(day: day, moodColor: moodColor);
                }
                currentIndex++;
                for (int i = 0; i < day.activities.length; i++) {
                  if (index == currentIndex) {
                    return _TimelineActivity(
                      activity: day.activities[i],
                      isFirst: i == 0,
                      isLast: i == day.activities.length - 1,
                      moodColor: moodColor,
                      isDark: isDark,
                    );
                  }
                  currentIndex++;
                }
              }
              return const SizedBox.shrink();
            },
          ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final ItineraryDay day;
  final Color moodColor;
  const _DayHeader({required this.day, required this.moodColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [moodColor, moodColor.withValues(alpha: 0.7)]), borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: moodColor.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))]),
          child: Text('Day ${day.dayNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(day.title, style: Theme.of(context).textTheme.titleLarge),
          Text('${DateFormat('EEEE, MMM d').format(day.date)} ${day.weatherIcon ?? ''} ${day.temperature?.toStringAsFixed(0) ?? ''}°', style: Theme.of(context).textTheme.bodySmall),
        ])),
      ]),
    );
  }
}

class _TimelineActivity extends StatelessWidget {
  final Activity activity;
  final bool isFirst, isLast;
  final Color moodColor;
  final bool isDark;
  const _TimelineActivity({required this.activity, required this.isFirst, required this.isLast, required this.moodColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Timeline line + dot
        SizedBox(width: 50, child: Column(children: [
          if (!isFirst) Container(width: 2, height: 8, color: moodColor.withValues(alpha: 0.2)),
          Container(width: 14, height: 14, decoration: BoxDecoration(
            shape: BoxShape.circle, color: activity.isCompleted ? AppColors.tertiary : moodColor,
            boxShadow: [BoxShadow(color: (activity.isCompleted ? AppColors.tertiary : moodColor).withValues(alpha: 0.3), blurRadius: 6)],
          )),
          if (!isLast) Expanded(child: Container(width: 2, color: moodColor.withValues(alpha: 0.2))),
        ])),

        // Activity card
        Expanded(child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(activity.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(child: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: moodColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                child: Text(activity.timeSlot.toString(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: moodColor))),
            ]),
            const SizedBox(height: 6),
            Text(activity.description, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(children: [
              if (activity.location != null) ...[
                Icon(LucideIcons.mapPin, size: 13, color: Colors.grey[500]),
                const SizedBox(width: 3),
                Flexible(child: Text(activity.location!, style: TextStyle(fontSize: 11, color: Colors.grey[500]), overflow: TextOverflow.ellipsis)),
              ],
              const Spacer(),
              if (activity.estimatedCost != null)
                Text('₹${activity.estimatedCost!.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.moodLuxury)),
            ]),
          ]),
        )),
      ]),
    );
  }
}
