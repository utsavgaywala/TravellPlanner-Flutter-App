/// Represents the user's mood for trip planning.
/// The mood affects the itinerary suggestions and UI styling.
enum TravelMood {
  relaxed('Relaxed', '🌿', 'Calm vibes, scenic spots, slow pace'),
  adventure('Adventure', '⚡', 'Thrilling activities, exploration'),
  luxury('Luxury', '💎', 'Premium experiences, fine dining'),
  social('Social', '🎉', 'Nightlife, group activities, events');

  const TravelMood(this.label, this.emoji, this.description);
  final String label;
  final String emoji;
  final String description;
}

/// Represents a complete trip with all its planning data.
class Trip {
  final String id;
  final String destination;
  final String? destinationImageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final TravelMood mood;
  final double budget;
  final String currency;
  final List<String> interests;
  final List<ItineraryDay> itinerary;
  final List<Expense> expenses;
  final List<PackingItem> packingList;
  final String? notes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  Trip({
    required this.id,
    required this.destination,
    this.destinationImageUrl,
    required this.startDate,
    required this.endDate,
    required this.mood,
    required this.budget,
    this.currency = 'INR',
    required this.interests,
    this.itinerary = const [],
    this.expenses = const [],
    this.packingList = const [],
    this.notes,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Number of days in the trip.
  int get durationDays => endDate.difference(startDate).inDays + 1;

  /// Total expenses spent so far.
  double get totalSpent =>
      expenses.fold(0.0, (sum, e) => sum + e.amount);

  /// Remaining budget.
  double get remainingBudget => budget - totalSpent;

  /// Returns a copy with modified fields.
  Trip copyWith({
    String? id,
    String? destination,
    String? destinationImageUrl,
    DateTime? startDate,
    DateTime? endDate,
    TravelMood? mood,
    double? budget,
    String? currency,
    List<String>? interests,
    List<ItineraryDay>? itinerary,
    List<Expense>? expenses,
    List<PackingItem>? packingList,
    String? notes,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      destination: destination ?? this.destination,
      destinationImageUrl: destinationImageUrl ?? this.destinationImageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      mood: mood ?? this.mood,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      interests: interests ?? this.interests,
      itinerary: itinerary ?? this.itinerary,
      expenses: expenses ?? this.expenses,
      packingList: packingList ?? this.packingList,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Represents a single day in the itinerary.
class ItineraryDay {
  final int dayNumber;
  final DateTime date;
  final String title;
  final List<Activity> activities;
  final String? weatherForecast;
  final String? weatherIcon;
  final double? temperature;

  ItineraryDay({
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.activities,
    this.weatherForecast,
    this.weatherIcon,
    this.temperature,
  });

  ItineraryDay copyWith({
    int? dayNumber,
    DateTime? date,
    String? title,
    List<Activity>? activities,
    String? weatherForecast,
    String? weatherIcon,
    double? temperature,
  }) {
    return ItineraryDay(
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      title: title ?? this.title,
      activities: activities ?? this.activities,
      weatherForecast: weatherForecast ?? this.weatherForecast,
      weatherIcon: weatherIcon ?? this.weatherIcon,
      temperature: temperature ?? this.temperature,
    );
  }
}

/// A single activity within a day's itinerary.
class Activity {
  final String id;
  final String title;
  final String description;
  final String category; // e.g., 'Food', 'Sightseeing', 'Adventure'
  final String icon;
  final TimeSlot timeSlot;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? estimatedCost;
  final String? imageUrl;
  final bool isCompleted;
  final String? notes;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.icon = '📍',
    required this.timeSlot,
    this.location,
    this.latitude,
    this.longitude,
    this.estimatedCost,
    this.imageUrl,
    this.isCompleted = false,
    this.notes,
  });

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? icon,
    TimeSlot? timeSlot,
    String? location,
    double? latitude,
    double? longitude,
    double? estimatedCost,
    String? imageUrl,
    bool? isCompleted,
    String? notes,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      timeSlot: timeSlot ?? this.timeSlot,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}

/// Represents a time window for an activity.
class TimeSlot {
  final String startTime; // e.g., "09:00"
  final String endTime;   // e.g., "11:00"

  TimeSlot({required this.startTime, required this.endTime});

  @override
  String toString() => '$startTime - $endTime';
}

/// Represents an expense entry for budget tracking.
class Expense {
  final String id;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String? paymentMethod;

  Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.paymentMethod,
  });
}

/// Item in the packing checklist.
class PackingItem {
  final String id;
  final String name;
  final String category;
  final bool isPacked;

  PackingItem({
    required this.id,
    required this.name,
    required this.category,
    this.isPacked = false,
  });

  PackingItem copyWith({bool? isPacked}) {
    return PackingItem(
      id: id,
      name: name,
      category: category,
      isPacked: isPacked ?? this.isPacked,
    );
  }
}

/// Chat message for the AI travel assistant.
class ChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}
