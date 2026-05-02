import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theft_zone_repository.dart';
import '../data/theft_zone_model.dart';

final theftZoneProvider = Provider<List<TheftZone>>((ref) {
  const repository = TheftZoneRepository();
  return repository.fetchZones();
});
