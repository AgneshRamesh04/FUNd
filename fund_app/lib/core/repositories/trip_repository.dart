import 'package:fund_app/core/models/trip_model.dart';
import 'package:fund_app/core/services/supabase_service.dart';
import 'package:fund_app/core/constants/app_constants.dart';

class TripRepository {
  final SupabaseService _supabaseService;

  TripRepository(this._supabaseService);

  Future<Trip> createTrip({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final now = DateTime.now();
    final data = {
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': now.toIso8601String(),
    };

    final response = await _supabaseService.client
        .from(AppConstants.tripsTable)
        .insert(data)
        .select()
        .single();

    return Trip.fromJson(response);
  }

  Future<Trip?> getTrip(String tripId) async {
    try {
      final response = await _supabaseService.client
          .from(AppConstants.tripsTable)
          .select()
          .eq('id', tripId)
          .single();

      return Trip.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<Trip>> getAllTrips() async {
    final response = await _supabaseService.client
        .from(AppConstants.tripsTable)
        .select()
        .order('start_date', ascending: false);

    return (response as List)
        .map((item) => Trip.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Trip> updateTrip({
    required String tripId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final updateData = <String, dynamic>{};

    if (name != null) updateData['name'] = name;
    if (startDate != null) updateData['start_date'] = startDate.toIso8601String();
    if (endDate != null) updateData['end_date'] = endDate.toIso8601String();

    final response = await _supabaseService.client
        .from(AppConstants.tripsTable)
        .update(updateData)
        .eq('id', tripId)
        .select()
        .single();

    return Trip.fromJson(response);
  }

  Future<void> deleteTrip(String tripId) async {
    await _supabaseService.client
        .from(AppConstants.tripsTable)
        .delete()
        .eq('id', tripId);
  }
}
