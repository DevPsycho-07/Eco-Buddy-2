/// Utility functions for unit conversions and formatting
class UnitConverter {
  // Distance conversions
  static const double kmToMiles = 0.621371;
  static const double milesToKm = 1.609344;
  
  // Weight conversions
  static const double kgToLbs = 2.20462;
  static const double lbsToKg = 0.453592;

  /// Convert kilometers to miles
  static double kmToMi(double km) => km * kmToMiles;

  /// Convert miles to kilometers
  static double miToKm(double miles) => miles * milesToKm;

  /// Convert kilograms to pounds
  static double kgToPounds(double kg) => kg * kgToLbs;

  /// Convert pounds to kilograms
  static double poundsToKg(double lbs) => lbs * lbsToKg;

  /// Format distance based on unit preference
  static String formatDistance(double distanceInKm, {required bool isMetric, int decimals = 1}) {
    if (isMetric) {
      return '${distanceInKm.toStringAsFixed(decimals)} km';
    } else {
      final miles = kmToMi(distanceInKm);
      return '${miles.toStringAsFixed(decimals)} mi';
    }
  }

  /// Format weight based on unit preference
  static String formatWeight(double weightInKg, {required bool isMetric, int decimals = 1}) {
    if (isMetric) {
      return '${weightInKg.toStringAsFixed(decimals)} kg';
    } else {
      final lbs = kgToPounds(weightInKg);
      return '${lbs.toStringAsFixed(decimals)} lbs';
    }
  }

  /// Get distance unit label
  static String getDistanceUnit(bool isMetric) => isMetric ? 'km' : 'mi';

  /// Get weight unit label
  static String getWeightUnit(bool isMetric) => isMetric ? 'kg' : 'lbs';

  /// Get distance with unit (e.g., "5.2 km" or "3.2 mi")
  static String distanceWithUnit(double distanceInKm, bool isMetric) {
    return formatDistance(distanceInKm, isMetric: isMetric);
  }

  /// Get weight with unit (e.g., "10.5 kg" or "23.1 lbs")
  static String weightWithUnit(double weightInKg, bool isMetric) {
    return formatWeight(weightInKg, isMetric: isMetric);
  }
}
