import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/service_locator.dart';
import '../storage/offline_storage.dart';

/// Provider for unit preference (metric/imperial)
final unitsProvider = StateNotifierProvider<UnitsNotifier, String>((ref) {
  return UnitsNotifier();
});

class UnitsNotifier extends StateNotifier<String> {
  UnitsNotifier() : super('metric') {
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      final storage = sl<OfflineStorage>();
      final settingsBox = storage.getSettingsBox();
      final units = settingsBox.get('units', defaultValue: 'metric') as String;
      state = units;
    } catch (e) {
      // If loading fails, default to metric
      state = 'metric';
    }
  }

  Future<void> setUnits(String units) async {
    state = units;
    try {
      final storage = sl<OfflineStorage>();
      final settingsBox = storage.getSettingsBox();
      await settingsBox.put('units', units);
    } catch (e) {
      // Handle error
    }
  }

  bool get isMetric => state == 'metric';
  bool get isImperial => state == 'imperial';
}
