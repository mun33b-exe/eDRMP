import '../../../core/constants/app_strings.dart';
import 'theft_zone_model.dart';

class TheftZoneRepository {
  const TheftZoneRepository();

  /// TODO(Phase 9): Replace with live hotspot data from Supabase.
  List<TheftZone> fetchZones() {
    return const [
      TheftZone(
        name: AppStrings.theftZoneClifton,
        city: AppStrings.cityKarachi,
        latitude: 24.8138,
        longitude: 67.0326,
        riskLevel: RiskLevel.medium,
        firCount: 18,
      ),
      TheftZone(
        name: AppStrings.theftZoneSaddar,
        city: AppStrings.cityKarachi,
        latitude: 24.8518,
        longitude: 67.0304,
        riskLevel: RiskLevel.high,
        firCount: 32,
      ),
      TheftZone(
        name: AppStrings.theftZoneGulberg,
        city: AppStrings.cityLahore,
        latitude: 31.5204,
        longitude: 74.3587,
        riskLevel: RiskLevel.low,
        firCount: 9,
      ),
      TheftZone(
        name: AppStrings.theftZoneJoharTown,
        city: AppStrings.cityLahore,
        latitude: 31.4697,
        longitude: 74.2728,
        riskLevel: RiskLevel.high,
        firCount: 27,
      ),
      TheftZone(
        name: AppStrings.theftZoneBlueArea,
        city: AppStrings.cityIslamabad,
        latitude: 33.7076,
        longitude: 73.0497,
        riskLevel: RiskLevel.medium,
        firCount: 14,
      ),
      TheftZone(
        name: AppStrings.theftZoneF7,
        city: AppStrings.cityIslamabad,
        latitude: 33.7206,
        longitude: 73.0836,
        riskLevel: RiskLevel.low,
        firCount: 6,
      ),
      TheftZone(
        name: AppStrings.theftZoneHayatabad,
        city: AppStrings.cityPeshawar,
        latitude: 33.9993,
        longitude: 71.4834,
        riskLevel: RiskLevel.medium,
        firCount: 16,
      ),
      TheftZone(
        name: AppStrings.theftZoneSatelliteTown,
        city: AppStrings.cityQuetta,
        latitude: 30.1798,
        longitude: 67.0078,
        riskLevel: RiskLevel.high,
        firCount: 23,
      ),
    ];
  }
}
