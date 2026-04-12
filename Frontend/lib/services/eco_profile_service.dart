import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../core/di/service_locator.dart';
import '../core/network/dio_client.dart';

/// Service for managing user's eco profile (one-time setup data)
class EcoProfileService {
  static final _dio = sl<DioClient>().dio;
  static const String baseUrl = ApiConfig.baseUrl;

  /// Check if user has completed eco profile setup
  static Future<bool> hasCompletedSetup() async {
    try {
      await _dio.get('$baseUrl/predictions/profile');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user's eco profile
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get('$baseUrl/predictions/profile');
      return response.data;
    } catch (e) {
      return null;
    }
  }

  /// Create eco profile (first-time setup)
  static Future<Map<String, dynamic>> createProfile({
    required int householdSize,
    required String ageGroup,
    required String lifestyleType,
    required String locationType,
    required String vehicleType,
    required String carFuelType,
    required String dietType,
    required bool usesSolarPanels,
    required bool smartThermostat,
    required bool recyclingPracticed,
    required bool compostingPracticed,
    required String wasteBagSize,
    required String socialActivity,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/predictions/profile',
        data: {
          'household_size': householdSize,
          'age_group': ageGroup,
          'lifestyle_type': lifestyleType,
          'location_type': locationType,
          'vehicle_type': vehicleType,
          'car_fuel_type': carFuelType,
          'diet_type': dietType,
          'uses_solar_panels': usesSolarPanels,
          'smart_thermostat': smartThermostat,
          'recycling_practiced': recyclingPracticed,
          'composting_practiced': compostingPracticed,
          'waste_bag_size': wasteBagSize,
          'social_activity': socialActivity,
        },
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': response.data?['error'] ?? 'Failed to create profile',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? e.message ?? 'Failed to create profile',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Update eco profile
  static Future<Map<String, dynamic>> updateProfile({
    int? householdSize,
    String? ageGroup,
    String? lifestyleType,
    String? locationType,
    String? vehicleType,
    String? carFuelType,
    String? dietType,
    bool? usesSolarPanels,
    bool? smartThermostat,
    bool? recyclingPracticed,
    bool? compostingPracticed,
    String? wasteBagSize,
    String? socialActivity,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (householdSize != null) body['household_size'] = householdSize;
      if (ageGroup != null) body['age_group'] = ageGroup;
      if (lifestyleType != null) body['lifestyle_type'] = lifestyleType;
      if (locationType != null) body['location_type'] = locationType;
      if (vehicleType != null) body['vehicle_type'] = vehicleType;
      if (carFuelType != null) body['car_fuel_type'] = carFuelType;
      if (dietType != null) body['diet_type'] = dietType;
      if (usesSolarPanels != null) body['uses_solar_panels'] = usesSolarPanels;
      if (smartThermostat != null) body['smart_thermostat'] = smartThermostat;
      if (recyclingPracticed != null) body['recycling_practiced'] = recyclingPracticed;
      if (compostingPracticed != null) body['composting_practiced'] = compostingPracticed;
      if (wasteBagSize != null) body['waste_bag_size'] = wasteBagSize;
      if (socialActivity != null) body['social_activity'] = socialActivity;

      final response = await _dio.put(
        '$baseUrl/predictions/profile',
        data: body,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': response.data?['error'] ?? 'Failed to update profile',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? e.message ?? 'Failed to update profile',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get dashboard data
  static Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final response = await _dio.get('$baseUrl/predictions/dashboard');
      return response.data;
    } catch (e) {
      return null;
    }
  }

  /// Get eco score prediction
  static Future<Map<String, dynamic>?> getPrediction() async {
    try {
      final response = await _dio.post(
        '$baseUrl/predictions/predict',
        data: {},
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  // Choice options for dropdowns
  static const List<Map<String, String>> ageGroupOptions = [
    {'value': '18-25', 'label': '18-25 years'},
    {'value': '26-35', 'label': '26-35 years'},
    {'value': '36-50', 'label': '36-50 years'},
    {'value': '50+', 'label': '50+ years'},
  ];

  static const List<Map<String, String>> lifestyleOptions = [
    {'value': 'office_worker', 'label': 'Office Worker'},
    {'value': 'remote_worker', 'label': 'Remote Worker'},
    {'value': 'student', 'label': 'Student'},
    {'value': 'retired', 'label': 'Retired'},
    {'value': 'self_employed', 'label': 'Self Employed'},
  ];

  static const List<Map<String, String>> locationOptions = [
    {'value': 'urban', 'label': 'Urban'},
    {'value': 'suburban', 'label': 'Suburban'},
    {'value': 'rural', 'label': 'Rural'},
  ];

  static const List<Map<String, String>> vehicleOptions = [
    {'value': 'none', 'label': 'No Vehicle / Public Transport Only'},
    {'value': 'bicycle', 'label': 'Bicycle'},
    {'value': 'motorcycle_petrol', 'label': 'Motorcycle (Petrol)'},
    {'value': 'motorcycle_electric', 'label': 'Motorcycle (Electric)'},
    {'value': 'scooter_petrol', 'label': 'Scooter (Petrol)'},
    {'value': 'scooter_electric', 'label': 'Scooter (Electric)'},
    {'value': 'auto_rickshaw', 'label': 'Auto Rickshaw (Three-Wheeler)'},
    {'value': 'car_petrol', 'label': 'Car (Petrol)'},
    {'value': 'car_diesel', 'label': 'Car (Diesel)'},
    {'value': 'car_cng', 'label': 'Car (CNG)'},
    {'value': 'car_lpg', 'label': 'Car (LPG)'},
    {'value': 'car_hybrid', 'label': 'Car (Hybrid)'},
    {'value': 'car_electric', 'label': 'Car (Electric)'},
    {'value': 'suv_petrol', 'label': 'SUV (Petrol)'},
    {'value': 'suv_diesel', 'label': 'SUV (Diesel)'},
    {'value': 'van', 'label': 'Van / Minivan'},
    {'value': 'truck', 'label': 'Truck / Heavy Vehicle'},
  ];

  static const List<Map<String, String>> fuelTypeOptions = [
    {'value': 'petrol', 'label': 'Petrol / Gasoline'},
    {'value': 'diesel', 'label': 'Diesel'},
    {'value': 'cng', 'label': 'CNG (Compressed Natural Gas)'},
    {'value': 'lpg', 'label': 'LPG (Liquefied Petroleum Gas)'},
    {'value': 'electric', 'label': 'Electric'},
    {'value': 'hybrid', 'label': 'Hybrid (Petrol + Electric)'},
  ];

  static const List<Map<String, String>> dietOptions = [
    {'value': 'omnivore', 'label': 'Omnivore'},
    {'value': 'vegetarian', 'label': 'Vegetarian'},
    {'value': 'vegan', 'label': 'Vegan'},
    {'value': 'pescatarian', 'label': 'Pescatarian'},
  ];

  static const List<Map<String, String>> wasteBagSizeOptions = [
    {'value': 'small', 'label': 'Small'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'large', 'label': 'Large'},
  ];

  static const List<Map<String, String>> socialActivityOptions = [
    {'value': 'rarely', 'label': 'Rarely'},
    {'value': 'sometimes', 'label': 'Sometimes'},
    {'value': 'often', 'label': 'Often'},
  ];
}
