import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/trip_model.dart';
import '../../core/data/mock_data.dart';

/// Manages the global list of trips and provides CRUD operations.
class TripsNotifier extends StateNotifier<List<Trip>> {
  TripsNotifier() : super([]);

  /// Add a new trip.
  void addTrip(Trip trip) {
    state = [...state, trip];
  }

  /// Remove a trip by ID.
  void removeTrip(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  /// Update an existing trip.
  void updateTrip(Trip updated) {
    state = state.map((t) => t.id == updated.id ? updated : t).toList();
  }

  /// Toggle the favorite status of a trip.
  void toggleFavorite(String id) {
    state = state.map((t) {
      if (t.id == id) {
        return t.copyWith(isFavorite: !t.isFavorite);
      }
      return t;
    }).toList();
  }

  /// Add an expense to a trip.
  void addExpense(String tripId, Expense expense) {
    state = state.map((t) {
      if (t.id == tripId) {
        return t.copyWith(
          expenses: [...t.expenses, expense],
          updatedAt: DateTime.now(),
        );
      }
      return t;
    }).toList();
  }

  /// Toggle packing item status.
  void togglePackingItem(String tripId, String itemId) {
    state = state.map((t) {
      if (t.id == tripId) {
        final updatedList = t.packingList.map((item) {
          if (item.id == itemId) {
            return item.copyWith(isPacked: !item.isPacked);
          }
          return item;
        }).toList();
        return t.copyWith(packingList: updatedList, updatedAt: DateTime.now());
      }
      return t;
    }).toList();
  }

  /// Toggle activity completion.
  void toggleActivityCompletion(
      String tripId, int dayNumber, String activityId) {
    state = state.map((t) {
      if (t.id == tripId) {
        final updatedItinerary = t.itinerary.map((day) {
          if (day.dayNumber == dayNumber) {
            final updatedActivities = day.activities.map((act) {
              if (act.id == activityId) {
                return act.copyWith(isCompleted: !act.isCompleted);
              }
              return act;
            }).toList();
            return day.copyWith(activities: updatedActivities);
          }
          return day;
        }).toList();
        return t.copyWith(
            itinerary: updatedItinerary, updatedAt: DateTime.now());
      }
      return t;
    }).toList();
  }
}

/// Global trips provider.
final tripsProvider =
    StateNotifierProvider<TripsNotifier, List<Trip>>((ref) => TripsNotifier());

/// Provider for upcoming trips (future start dates).
final upcomingTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  final now = DateTime.now();
  return trips
      .where((t) => t.startDate.isAfter(now))
      .toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
});

/// Provider for past trips.
final pastTripsProvider = Provider<List<Trip>>((ref) {
  final trips = ref.watch(tripsProvider);
  final now = DateTime.now();
  return trips
      .where((t) => t.endDate.isBefore(now))
      .toList()
    ..sort((a, b) => b.endDate.compareTo(a.endDate));
});

/// Provider for a specific trip by ID.
final tripByIdProvider = Provider.family<Trip?, String>((ref, id) {
  final trips = ref.watch(tripsProvider);
  try {
    return trips.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
});

/// Theme mode provider for dark/light mode toggle.
final themeModeProvider = StateProvider<bool>((ref) => false); // false = light

/// Selected mood provider for trip creation.
final selectedMoodProvider = StateProvider<TravelMood?>((ref) => null);

/// Bottom navigation index provider.
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Search query provider for explore page.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search query provider for budget page.
final budgetSearchQueryProvider = StateProvider<String>((ref) => '');

/// Chat messages provider for AI assistant.
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super(MockData.sampleChatMessages);

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }

  /// Simulate an AI response.
  Future<void> sendMessage(String userMessage) async {
    // Add user message
    addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    // Simulate AI thinking delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock AI response
    final response = _generateResponse(userMessage);
    addMessage(ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      message: response,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  String _generateResponse(String input) {
    final lower = input.toLowerCase();
    
    // Greeting
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return 'Hey there! 🌍 I\'m your personal travel companion. Where are we dreaming of going today? Or maybe you need help with a current plan?';
    }
    
    // Help/Capabilities
    if (lower.contains('what can you do') || lower.contains('help')) {
      return 'I can help you with almost anything travel-related! ✈️\n\n'
             '• Suggest hidden gems in any city\n'
             '• Optimize your travel budget\n'
             '• Create personalized packing lists\n'
             '• Help you find the best street food spots\n\n'
             'Just name a destination or ask a specific question!';
    }

    if (lower.contains('bali')) {
      return '🌴 Bali is absolutely magical! If you\'re going, you HAVE to visit Ubud for the rice terraces, but for a real hidden gem, check out Sidemen—it\'s like Ubud was 20 years ago. Are you looking for relaxation or more of an adventure there?';
    } else if (lower.contains('budget') || lower.contains('cheap') || lower.contains('money')) {
      return '💰 Smart move. Traveling on a budget doesn\'t mean missing out. My top tip: eat where the locals eat (follow the crowds!) and try to travel during the "shoulder season"—just before or after the peak. What\'s your target budget for this trip?';
    } else if (lower.contains('tokyo') || lower.contains('japan')) {
      return '🗼 Tokyo is a feast for the senses! Make sure to get a Suica card for the subway—it works everywhere, even in vending machines. And definitely don\'t miss the TeamLab exhibitions; they\'re mind-blowing. Want me to suggest a 3-day Tokyo itinerary?';
    } else if (lower.contains('pack') || lower.contains('bring')) {
      return '🎒 Packing light is an art! Always bring a universal adapter and a reusable water bottle. For clothes, think "layers." Do you want me to generate a specific packing list for your next destination?';
    } else if (lower.contains('thank')) {
      return 'You\'re very welcome! 😊 I\'m always here if you need more tips or help planning your next big adventure. Anything else on your mind?';
    } else {
      return 'That sounds interesting! ✨ Tell me more about your plans. Are you thinking about a specific destination, or should I suggest some trending spots for this season?';
    }
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) => ChatNotifier());
