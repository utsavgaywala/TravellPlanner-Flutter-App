import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/trip_model.dart';
import '../providers/app_providers.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'trip_detail_screen.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});
  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _destCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController(text: '2000');
  DateTime _start = DateTime.now().add(const Duration(days: 7));
  DateTime _end = DateTime.now().add(const Duration(days: 14));
  int _moodIdx = -1;
  final Set<String> _interests = {};
  bool _loading = false;

  @override
  void dispose() { _destCtrl.dispose(); _budgetCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate(bool isStart) async {
    final d = await showDatePicker(
      context: context, 
      initialDate: isStart ? _start : _end,
      firstDate: DateTime.now(), 
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (d != null) {
      setState(() {
        if (isStart) {
          _start = d;
          if (_end.isBefore(_start.add(const Duration(days: 3)))) {
            _end = _start.add(const Duration(days: 3));
          }
        } else {
          // Check if end date is at least 4 days after start
          if (d.difference(_start).inDays < 3) {
            _showError('Trip must be at least 4 days long');
            _end = _start.add(const Duration(days: 3));
          } else if (d.difference(_start).inDays > 60) {
            // "if user select 1april user cannot select 31may" -> approx 60 days
            _showError('Trip duration cannot exceed 60 days');
            _end = _start.add(const Duration(days: 60));
          } else {
            _end = d;
          }
        }
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(LucideIcons.circleAlert, color: Colors.white), const SizedBox(width: 12), Text(msg)]),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _generate() async {
    final days = _end.difference(_start).inDays + 1;
    final budget = double.tryParse(_budgetCtrl.text) ?? 0;
    final minBudget = days * 1000;

    if (_destCtrl.text.isEmpty) { 
      _showError('Where are we going? Enter a destination'); 
      return; 
    }
    
    if (days < 4) {
      _showError('Your trip must be at least 4 days long');
      return;
    }

    if (budget < minBudget) {
      _showError('Minimum budget for $days days is ₹${minBudget.toStringAsFixed(0)}');
      return;
    }

    if (_moodIdx == -1) {
      _showError('Select your travel mood');
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    
    final trip = Trip(
      id: const Uuid().v4(), 
      destination: _destCtrl.text, 
      startDate: _start, 
      endDate: _end, 
      mood: TravelMood.values[_moodIdx], 
      budget: budget, 
      interests: _interests.toList(), 
      itinerary: _mockItinerary(), 
      packingList: [
        PackingItem(id: const Uuid().v4(), name: 'Passport & Docs', category: 'Essentials'),
        PackingItem(id: const Uuid().v4(), name: 'Travel Insurance', category: 'Essentials'),
        PackingItem(id: const Uuid().v4(), name: 'Universal Adapter', category: 'Tech'),
        PackingItem(id: const Uuid().v4(), name: 'Basic First Aid', category: 'Health'),
      ], 
      createdAt: DateTime.now(), 
      updatedAt: DateTime.now()
    );
    
    ref.read(tripsProvider.notifier).addTrip(trip);
    setState(() => _loading = false);
    if (mounted) Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: trip.id)));
  }

  List<ItineraryDay> _mockItinerary() {
    final days = _end.difference(_start).inDays + 1;
    final mood = TravelMood.values[_moodIdx];
    
    // Expanded activity pool based on mood
    final activityPool = {
      TravelMood.relaxed: [
        ('Morning Yoga', 'Gentle stretches to start the day', 'Wellness', '🧘'),
        ('Botanical Garden', 'Walk through rare exotic flora', 'Nature', '🌿'),
        ('Riverside Brunch', 'Slow meal with a view', 'Food', '☕'),
        ('Art Gallery', 'Local contemporary art exhibition', 'Culture', '🖼️'),
        ('Sunset Spa', 'Relaxing aromatherapy session', 'Wellness', '💆'),
      ],
      TravelMood.adventure: [
        ('Mountain Trek', 'Breathtaking trails and views', 'Adventure', '🧗'),
        ('River Rafting', 'Challenging the white water rapids', 'Adventure', '🚣'),
        ('Zip Lining', 'Gliding through the forest canopy', 'Adventure', '⚡'),
        ('Local Market', 'Finding rare local artifacts', 'Exploration', '🏺'),
        ('Night Safari', 'Observe wildlife after dark', 'Adventure', '🐆'),
      ],
      TravelMood.luxury: [
        ('Private Yacht', 'Champagne cruise at sunset', 'Luxury', '🛥️'),
        ('Michelin Dining', 'Multi-course tasting menu', 'Food', '🍽️'),
        ('Designer Shopping', 'Exclusive boutique tour', 'Lifestyle', '🛍️'),
        ('Helicopter Tour', 'Aerial view of the city', 'Luxury', '🚁'),
        ('Private Villa', 'Evening poolside lounge', 'Luxury', '🏡'),
      ],
      TravelMood.social: [
        ('Bar Hopping', 'Best local cocktail spots', 'Nightlife', '🍸'),
        ('Music Festival', 'Live performances by local artists', 'Social', '🎸'),
        ('Street Food Tour', 'Tasting the city\'s best bites', 'Food', '🍢'),
        ('Beach Party', 'Sun, sand, and music', 'Social', '🏖️'),
        ('Networking Hub', 'Meet local entrepreneurs', 'Social', '🤝'),
      ],
    };

    final pool = activityPool[mood] ?? activityPool[TravelMood.relaxed]!;
    
    return List.generate(days, (di) {
      final date = _start.add(Duration(days: di));
      return ItineraryDay(
        dayNumber: di + 1,
        date: date,
        title: 'Day ${di + 1}: ${mood.label} ${['Experience', 'Escape', 'Journey', 'Discovery'][di % 4]}',
        weatherForecast: ['Sunny', 'Partly Cloudy', 'Breezy', 'Clear'][di % 4],
        weatherIcon: ['☀️', '⛅', '🍃', '🌙'][di % 4],
        temperature: 22.0 + (di % 8),
        activities: List.generate(4, (ai) {
          final act = pool[(di * 2 + ai) % pool.length];
          return Activity(
            id: 'act_${di}_${ai}_${const Uuid().v4().substring(0, 4)}',
            title: act.$1,
            description: act.$2,
            category: act.$3,
            icon: act.$4,
            timeSlot: TimeSlot(
              startTime: '${8 + ai * 3}:00',
              endTime: '${10 + ai * 3}:30',
            ),
            location: _destCtrl.text,
            estimatedCost: (500 + (ai * 1000)).toDouble(),
          );
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _end.difference(_start).inDays + 1;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.mainBgGradient),
        child: CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          SliverAppBar(
            expandedHeight: 200, 
            pinned: true, 
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 0), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        if (Navigator.canPop(context))
                          IconButton(
                            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(LucideIcons.sparkles, color: AppColors.accent, size: 28),
                        ),
                        const SizedBox(height: 20),
                        const Text('Plan Your\nAdventure', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, height: 1, letterSpacing: -1.5)),
                      ]
                    )
                )
              )
            )
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  _lbl('Where to?'), 
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _destCtrl, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'e.g., Tokyo, Japan', 
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontWeight: FontWeight.w400),
                        prefixIcon: const Icon(LucideIcons.mapPin, color: AppColors.accent), 
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      )
                    ),
                  ),
                  const SizedBox(height: 32), 
                  
                  _lbl('Travel Dates'), 
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(children: [
                          Expanded(child: _dateBox('Departure', _start, () => _pickDate(true))), 
                          Container(height: 40, width: 1, color: Colors.white.withValues(alpha: 0.1), margin: const EdgeInsets.symmetric(horizontal: 16)),
                          Expanded(child: _dateBox('Return', _end, () => _pickDate(false)))
                        ]),
                        const Divider(height: 32, color: Colors.white10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.calendar, size: 14, color: days < 4 ? Colors.redAccent : AppColors.accent),
                            const SizedBox(width: 10),
                            Text(
                              '$days Days Trip ${days < 4 ? "(Min 4 req.)" : ""}', 
                              style: TextStyle(color: days < 4 ? Colors.redAccent : AppColors.accent, fontWeight: FontWeight.w800, fontSize: 14)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32), 
                  _lbl('Budget (₹)'), 
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _budgetCtrl, 
                      keyboardType: TextInputType.number, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                      decoration: InputDecoration(
                        hintText: 'e.g. 5000', 
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                        prefixIcon: const Icon(LucideIcons.wallet, color: AppColors.accent),
                        suffixText: 'total',
                        suffixStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text('Minimum required: ₹${(days * 1000).toStringAsFixed(0)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
                  
                  const SizedBox(height: 32), 
                  _lbl('Travel Mood'), 
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: TravelMood.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final m = TravelMood.values[i];
                        final isSelected = _moodIdx == i;
                        return MoodChip(
                          label: m.label, 
                          emoji: m.emoji, 
                          color: AppColors.getMoodColor(i), 
                          isSelected: isSelected, 
                          onTap: () => setState(() => _moodIdx = i)
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32), 
                  _lbl('Interests'), 
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12, 
                    runSpacing: 12, 
                    children: AppConstants.interestTags.map((t) { 
                      final sel = _interests.contains(t); 
                      return GestureDetector(
                        onTap: () => setState(() { sel ? _interests.remove(t) : _interests.add(t); }), 
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300), 
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), 
                          decoration: BoxDecoration(
                            color: sel ? Colors.white : Colors.white.withValues(alpha: 0.05), 
                            borderRadius: BorderRadius.circular(16), 
                            boxShadow: sel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))] : null,
                            border: Border.all(color: sel ? AppColors.primary : Colors.white.withValues(alpha: 0.1), width: 1)
                          ), 
                          child: Text(t, style: TextStyle(fontSize: 14, fontWeight: sel ? FontWeight.w900 : FontWeight.w500, color: sel ? Colors.black : Colors.white.withValues(alpha: 0.6)))
                        )
                      ); 
                    }).toList()
                  ),
                  
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _generate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8,
                        shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      child: _loading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.sparkles),
                              SizedBox(width: 12),
                              Text('Generate AI Itinerary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            ],
                          ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ]
              )
            ),
          )
        ]),
      ),
    );
  }

  Widget _lbl(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text, 
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5)
      ),
    );
  }

  Widget _dateBox(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(DateFormat('MMM dd, yyyy').format(date), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
