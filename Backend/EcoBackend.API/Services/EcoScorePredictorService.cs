using Microsoft.ML.OnnxRuntime;
using Microsoft.ML.OnnxRuntime.Tensors;

namespace EcoBackend.API.Services;

/// <summary>
/// Singleton service that wraps the ONNX eco-score prediction model.
/// Mirrors Django's predictions/ml_model.py EcoScorePredictor.
/// </summary>
public sealed class EcoScorePredictorService : IDisposable
{
    private InferenceSession? _session;
    private string[]? _featureNames;
    private readonly ILogger<EcoScorePredictorService> _logger;
    private readonly string _modelDir;

    // ==================== Default values (mirrors Django DEFAULT_VALUES) ====================
    public static readonly Dictionary<string, double> DefaultValues = new()
    {
        ["household_size"] = 1,
        ["car_km"] = 0,
        ["bus_km"] = 0,
        ["train_metro_km"] = 0,
        ["bike_km"] = 0,
        ["walk_km"] = 0,
        ["total_distance_km"] = 0,
        ["num_trips"] = 0,
        ["electricity_kwh"] = 10,
        ["natural_gas_therms"] = 0,
        ["ac_hours"] = 0,
        ["heating_hours"] = 0,
        ["water_usage_liters"] = 100,
        ["renewable_energy_percent"] = 0,
        ["energy_efficiency"] = 0.5,
        ["red_meat_meals"] = 0,
        ["poultry_meals"] = 0,
        ["fish_meals"] = 0,
        ["vegetarian_meals"] = 1,
        ["vegan_meals"] = 0,
        ["grocery_bill"] = 100,
        ["food_waste_kg"] = 0.5,
        ["waste_bag_count"] = 1,
        ["general_waste_kg"] = 2,
        ["recycling_practiced"] = 0,
        ["recycled_waste_kg"] = 0,
        ["composting_practiced"] = 0,
        ["new_clothes_monthly"] = 1,
        ["shower_frequency"] = 1,
        ["tv_pc_hours"] = 2,
        ["internet_hours"] = 2,
        ["public_transport_usage"] = 0,
        ["uses_solar_panels"] = 0,
        ["smart_thermostat"] = 0,
        ["travel_efficiency"] = 0.5,
        ["energy_efficiency_score"] = 0.5,
        ["sustainable_transport_ratio"] = 0,
        ["recycling_rate"] = 0,
        ["per_capita_co2"] = 10,
        ["is_weekend_num"] = 0,
        ["month"] = 1,
    };

    // ==================== Categorical mappings (mirrors Django CATEGORICAL_MAPPINGS) ====================
    public static readonly Dictionary<string, List<string>> CategoricalMappings = new()
    {
        ["age_group"] = new() { "26-35", "36-50", "50+" },
        ["lifestyle_type"] = new() { "remote_worker", "retired", "self_employed", "student" },
        ["location_type"] = new() { "suburban", "urban" },
        ["day_of_week"] = new() { "Monday", "Saturday", "Sunday", "Thursday", "Tuesday", "Wednesday" },
        ["vehicle_type"] = new() { "Car", "Electric Vehicle", "Walking", "car", "diesel", "electric", "hybrid", "lpg", "none", "petrol" },
        ["car_fuel_type"] = new() { "electric", "hybrid", "lpg", "none", "petrol" },
        ["diet_type"] = new() { "pescatarian", "vegan", "vegetarian" },
        ["waste_bag_size"] = new() { "large", "medium", "small" },
        ["social_activity"] = new() { "often", "sometimes" },
        ["season"] = new() { "spring", "summer", "winter" },
    };

    public EcoScorePredictorService(ILogger<EcoScorePredictorService> logger, IWebHostEnvironment env)
    {
        _logger = logger;
        _modelDir = Path.Combine(env.ContentRootPath, "models");
    }

    public bool IsLoaded => _session != null && _featureNames != null;
    public int FeaturesCount => _featureNames?.Length ?? 82;

    /// <summary>Load ONNX model and feature list from disk.</summary>
    public void Load()
    {
        try
        {
            var modelPath = Path.Combine(_modelDir, "eco_score_model.onnx");
            var featuresPath = Path.Combine(_modelDir, "model_features.txt");

            if (!File.Exists(modelPath))
            {
                _logger.LogWarning("ONNX model not found at {Path}", modelPath);
                return;
            }

            if (!File.Exists(featuresPath))
            {
                _logger.LogWarning("Feature names not found at {Path}", featuresPath);
                return;
            }

            _featureNames = File.ReadAllLines(featuresPath)
                .Where(l => !string.IsNullOrWhiteSpace(l))
                .ToArray();

            var opts = new Microsoft.ML.OnnxRuntime.SessionOptions { LogSeverityLevel = OrtLoggingLevel.ORT_LOGGING_LEVEL_WARNING };
            _session = new InferenceSession(modelPath, opts);
            _logger.LogInformation("ONNX eco-score model loaded ({Features} features)", _featureNames.Length);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to load ONNX model");
            _session = null;
            _featureNames = null;
        }
    }

    /// <summary>
    /// Predict eco score from a dictionary of raw input features.
    /// Returns (score, category, recommendations).
    /// </summary>
    public (double Score, string Category, List<string> Recommendations) Predict(Dictionary<string, object> inputData)
    {
        if (!IsLoaded)
            throw new InvalidOperationException("ML model is not loaded. Ensure model files are in the models directory.");

        var features = PrepareFeatures(inputData);
        var tensor = new DenseTensor<float>(new[] { 1, _featureNames!.Length });

        for (int i = 0; i < _featureNames.Length; i++)
        {
            tensor[0, i] = features.TryGetValue(_featureNames[i], out var v) ? (float)v : 0f;
        }

        var inputs = new List<NamedOnnxValue>
        {
            NamedOnnxValue.CreateFromTensor("input", tensor)
        };

        using var results = _session!.Run(inputs);
        var output = results.First().AsTensor<float>();
        double score = Math.Clamp(output[0], 0, 100);

        var category = GetScoreCategory(score);
        var recommendations = GenerateRecommendations(inputData, score);

        return (Math.Round(score, 2), category, recommendations);
    }

    // ==================== Feature preparation (mirrors Django _prepare_features) ====================

    private Dictionary<string, double> PrepareFeatures(Dictionary<string, object> inputData)
    {
        // Start with defaults
        var features = new Dictionary<string, double>(DefaultValues);

        // Override with provided values
        foreach (var (key, value) in inputData)
        {
            if (features.ContainsKey(key))
            {
                features[key] = value switch
                {
                    bool b => b ? 1.0 : 0.0,
                    int i => i,
                    double d => d,
                    float f => f,
                    long l => l,
                    _ => double.TryParse(value?.ToString(), out var parsed) ? parsed : features[key]
                };
            }
        }

        // Calculate derived features
        CalculateDerivedFeatures(features);

        // One-hot encode categoricals
        var today = DateTime.UtcNow;

        OneHotEncode(features, "age_group", GetStringValue(inputData, "age_group", "26-35"));
        OneHotEncode(features, "lifestyle_type", GetStringValue(inputData, "lifestyle_type", "office_worker"));
        OneHotEncode(features, "location_type", GetStringValue(inputData, "location_type", "urban"));

        var dayName = today.DayOfWeek.ToString();
        OneHotEncode(features, "day_of_week", dayName);

        OneHotEncode(features, "vehicle_type", GetStringValue(inputData, "vehicle_type", "none"));
        OneHotEncode(features, "car_fuel_type", GetStringValue(inputData, "car_fuel_type", "none"));
        OneHotEncode(features, "diet_type", GetStringValue(inputData, "diet_type", "omnivore"));
        OneHotEncode(features, "waste_bag_size", GetStringValue(inputData, "waste_bag_size", "medium"));
        OneHotEncode(features, "social_activity", GetStringValue(inputData, "social_activity", "sometimes"));

        var season = GetSeason(today.Month);
        OneHotEncode(features, "season", season);

        return features;
    }

    private static void CalculateDerivedFeatures(Dictionary<string, double> f)
    {
        f["total_distance_km"] = f["car_km"] + f["bus_km"] + f["train_metro_km"] + f["bike_km"] + f["walk_km"];

        var total = f["total_distance_km"];
        if (total > 0)
        {
            var sustainable = f["bike_km"] + f["walk_km"] + f["bus_km"] + f["train_metro_km"];
            f["sustainable_transport_ratio"] = sustainable / total;
            f["public_transport_usage"] = (f["bus_km"] + f["train_metro_km"]) / total;
        }
        else
        {
            f["sustainable_transport_ratio"] = 1.0;
            f["public_transport_usage"] = 0;
        }

        f["travel_efficiency"] = f["sustainable_transport_ratio"];

        var renewable = f["renewable_energy_percent"] / 100.0;
        var solar = f["uses_solar_panels"] > 0 ? 1.0 : 0.0;
        var thermostat = f["smart_thermostat"] > 0 ? 1.0 : 0.0;
        f["energy_efficiency"] = (renewable + solar * 0.3 + thermostat * 0.2) / 1.5;
        f["energy_efficiency_score"] = f["energy_efficiency"];

        var totalWaste = f["general_waste_kg"] + f["recycled_waste_kg"];
        f["recycling_rate"] = totalWaste > 0 ? f["recycled_waste_kg"] / totalWaste : 0;

        var household = Math.Max(f["household_size"], 1);
        var carCo2 = f["car_km"] * 0.21;
        var energyCo2 = f["electricity_kwh"] * 0.5;
        f["per_capita_co2"] = (carCo2 + energyCo2) / household;

        var today = DateTime.UtcNow;
        f["is_weekend_num"] = today.DayOfWeek is DayOfWeek.Saturday or DayOfWeek.Sunday ? 1 : 0;
        f["month"] = today.Month;
    }

    private void OneHotEncode(Dictionary<string, double> features, string category, string value)
    {
        if (!CategoricalMappings.TryGetValue(category, out var options)) return;
        foreach (var opt in options)
        {
            features[$"{category}_{opt}"] = opt == value ? 1.0 : 0.0;
        }
    }

    // ==================== Score category (mirrors Django _get_score_category) ====================

    public static string GetScoreCategory(double score) => score switch
    {
        >= 80 => "Excellent",
        >= 60 => "Good",
        >= 40 => "Average",
        >= 20 => "Below Average",
        _ => "Needs Improvement"
    };

    // ==================== Recommendations (mirrors Django _generate_recommendations) ====================

    private static List<string> GenerateRecommendations(Dictionary<string, object> inputData, double score)
    {
        var recs = new List<string>();

        var carKm = GetDoubleValue(inputData, "car_km");
        var bikeKm = GetDoubleValue(inputData, "bike_km");
        var walkKm = GetDoubleValue(inputData, "walk_km");

        if (carKm > 10 && (bikeKm + walkKm) < 2)
            recs.Add("🚴 Consider cycling or walking for short trips. Even replacing one car trip per day can save ~2kg CO2.");

        if (carKm > 20)
            recs.Add("🚌 For longer commutes, consider public transport. Buses and trains produce 50-80% less CO2 per passenger.");

        if (!GetBoolValue(inputData, "uses_solar_panels"))
            recs.Add("☀️ Installing solar panels could reduce your carbon footprint by up to 1.5 tons per year.");

        if (GetDoubleValue(inputData, "ac_hours") > 8)
            recs.Add("❄️ Try reducing AC usage by 2 hours daily. Each hour saved can reduce emissions by ~0.5kg CO2.");

        if (GetDoubleValue(inputData, "red_meat_meals") >= 2)
            recs.Add("🥗 Reducing red meat by one meal per week can save ~3.5kg CO2 weekly. Try Meatless Monday!");

        if (!GetBoolValue(inputData, "recycling_practiced"))
            recs.Add("♻️ Start recycling! Recycling one aluminum can saves enough energy to power a TV for 3 hours.");

        if (GetDoubleValue(inputData, "food_waste_kg") > 1)
            recs.Add("🍎 Plan meals to reduce food waste. The average household can save $1,500/year by reducing food waste.");

        if (GetDoubleValue(inputData, "shower_frequency") > 2)
            recs.Add("🚿 Shorter showers save water and energy. A 5-minute shower uses ~40 liters less than a 10-minute one.");

        return recs.Take(5).ToList();
    }

    // ==================== Helpers ====================

    private static string GetStringValue(Dictionary<string, object> d, string key, string fallback)
        => d.TryGetValue(key, out var v) && v is string s ? s : fallback;

    private static double GetDoubleValue(Dictionary<string, object> d, string key)
        => d.TryGetValue(key, out var v) ? Convert.ToDouble(v) : 0;

    private static bool GetBoolValue(Dictionary<string, object> d, string key)
        => d.TryGetValue(key, out var v) && v is bool b && b;

    private static string GetSeason(int month) => month switch
    {
        >= 3 and <= 5 => "spring",
        >= 6 and <= 8 => "summer",
        >= 9 and <= 11 => "fall",
        _ => "winter"
    };

    public void Dispose()
    {
        _session?.Dispose();
    }
}

/// <summary>Hosted service to load the ONNX model at startup.</summary>
public class EcoScoreModelLoaderService : IHostedService
{
    private readonly EcoScorePredictorService _predictor;

    public EcoScoreModelLoaderService(EcoScorePredictorService predictor)
    {
        _predictor = predictor;
    }

    public Task StartAsync(CancellationToken cancellationToken)
    {
        _predictor.Load();
        return Task.CompletedTask;
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
