import '../../../core/services/supabase_service.dart';
import 'theft_zone_model.dart';

class TheftZoneRepository {
  const TheftZoneRepository();

  Future<List<TheftZone>> fetchAll() async {
    final rows = await SupabaseService.client
        .from('theft_zones')
        .select()
        .order('created_at', ascending: false);
    return rows.map(TheftZone.fromJson).toList();
  }
}
