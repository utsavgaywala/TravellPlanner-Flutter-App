import 'package:uuid/uuid.dart';
import '../models/trip_model.dart';

/// Provides empty data containers as requested by the user.
class MockData {
  MockData._();
  static const _uuid = Uuid();

  /// Returns an empty list of trips.
  static List<Trip> get sampleTrips => [];

  /// Returns an empty list of chat messages.
  static List<ChatMessage> get sampleChatMessages => [];

  /// Returns empty list of hidden gems.
  static List<Map<String, String>> get hiddenGems => [];
}
