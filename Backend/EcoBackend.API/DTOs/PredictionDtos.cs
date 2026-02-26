namespace EcoBackend.API.DTOs;

// ==================== Trip DTOs ====================

public class PredictionTripCreateDto
{
    public string TransportMode { get; set; } = "walk";
    public double StartLatitude { get; set; }
    public double StartLongitude { get; set; }
    public double EndLatitude { get; set; }
    public double EndLongitude { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public DateTime? Date { get; set; }
}

public class PredictionTripDto
{
    public int Id { get; set; }
    public string TransportMode { get; set; } = string.Empty;
    public double DistanceKm { get; set; }
    public double StartLatitude { get; set; }
    public double StartLongitude { get; set; }
    public double EndLatitude { get; set; }
    public double EndLongitude { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public DateTime Date { get; set; }
    public DateTime CreatedAt { get; set; }
}

// ==================== Daily Log DTOs ====================

public class DailyLogDto
{
    public int Id { get; set; }
    public DateTime Date { get; set; }

    // Travel
    public double CarKm { get; set; }
    public double BusKm { get; set; }
    public double TrainMetroKm { get; set; }
    public double BikeKm { get; set; }
    public double WalkKm { get; set; }
    public double TotalDistanceKm { get; set; }
    public int NumTrips { get; set; }

    // Energy
    public double ElectricityKwh { get; set; }
    public double NaturalGasTherms { get; set; }
    public double AcHours { get; set; }
    public double HeatingHours { get; set; }
    public double WaterUsageLiters { get; set; }

    // Food
    public int RedMeatMeals { get; set; }
    public int PoultryMeals { get; set; }
    public int FishMeals { get; set; }
    public int VegetarianMeals { get; set; }
    public int VeganMeals { get; set; }
    public double FoodWasteKg { get; set; }

    // Lifestyle
    public int ShowerFrequency { get; set; }
    public double TvPcHours { get; set; }
    public double InternetHours { get; set; }

    // Results
    public double? EcoScore { get; set; }
    public string ScoreCategory { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class DailyLogInputDto
{
    // Travel (manual input)
    public double? CarKm { get; set; }
    public double? BusKm { get; set; }
    public double? TrainMetroKm { get; set; }
    public double? BikeKm { get; set; }
    public double? WalkKm { get; set; }

    // Energy
    public double? ElectricityKwh { get; set; }
    public double? NaturalGasTherms { get; set; }
    public double? AcHours { get; set; }
    public double? HeatingHours { get; set; }
    public double? WaterUsageLiters { get; set; }

    // Food
    public int? RedMeatMeals { get; set; }
    public int? PoultryMeals { get; set; }
    public int? FishMeals { get; set; }
    public int? VegetarianMeals { get; set; }
    public int? VeganMeals { get; set; }
    public double? FoodWasteKg { get; set; }

    // Lifestyle
    public int? ShowerFrequency { get; set; }
    public double? TvPcHours { get; set; }
    public double? InternetHours { get; set; }
}

// ==================== Prediction Input/Output DTOs ====================

public class PredictionInputDto
{
    // Profile (auto from UserEcoProfile)
    public int? HouseholdSize { get; set; }

    // Travel
    public double? CarKm { get; set; }
    public double? BusKm { get; set; }
    public double? TrainMetroKm { get; set; }
    public double? BikeKm { get; set; }
    public double? WalkKm { get; set; }

    // Energy
    public double? ElectricityKwh { get; set; }
    public double? NaturalGasTherms { get; set; }
    public double? AcHours { get; set; }
    public double? HeatingHours { get; set; }
    public double? WaterUsageLiters { get; set; }
    public double? RenewableEnergyPercent { get; set; }

    // Food
    public int? RedMeatMeals { get; set; }
    public int? PoultryMeals { get; set; }
    public int? FishMeals { get; set; }
    public int? VegetarianMeals { get; set; }
    public int? VeganMeals { get; set; }
    public double? GroceryBill { get; set; }
    public double? FoodWasteKg { get; set; }

    // Waste
    public int? WasteBagCount { get; set; }
    public double? GeneralWasteKg { get; set; }
    public bool? RecyclingPracticed { get; set; }
    public double? RecycledWasteKg { get; set; }
    public bool? CompostingPracticed { get; set; }

    // Lifestyle
    public int? NewClothesMonthly { get; set; }
    public int? ShowerFrequency { get; set; }
    public double? TvPcHours { get; set; }
    public double? InternetHours { get; set; }

    // Booleans
    public bool? UsesSolarPanels { get; set; }
    public bool? SmartThermostat { get; set; }

    // Categorical
    public string? AgeGroup { get; set; }
    public string? LifestyleType { get; set; }
    public string? LocationType { get; set; }
    public string? VehicleType { get; set; }
    public string? CarFuelType { get; set; }
    public string? DietType { get; set; }
    public string? WasteBagSize { get; set; }
    public string? SocialActivity { get; set; }
}

public class PredictionOutputDto
{
    public double PredictedScore { get; set; }
    public string ScoreCategory { get; set; } = string.Empty;
    public List<string> Recommendations { get; set; } = new();
    public Dictionary<string, object> DataSources { get; set; } = new();
    public double? PreviousScore { get; set; }
}

// ==================== Prediction Log DTO ====================

public class PredictionLogDto
{
    public int Id { get; set; }
    public string? Username { get; set; }
    public string InputData { get; set; } = "{}";
    public double PredictedScore { get; set; }
    public double? Confidence { get; set; }
    public string ModelVersion { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

// ==================== Model Info DTO ====================

public class ModelInfoDto
{
    public bool ModelLoaded { get; set; }
    public string ModelVersion { get; set; } = "v1.0";
    public string ModelType { get; set; } = "RandomForestRegressor";
    public int FeaturesCount { get; set; }
    public Dictionary<string, List<string>> CategoricalOptions { get; set; } = new();
    public List<ScoreCategoryInfo> ScoreCategories { get; set; } = new();
}

public class ScoreCategoryInfo
{
    public int Min { get; set; }
    public int Max { get; set; }
    public string Label { get; set; } = string.Empty;
}

// ==================== Dashboard DTO ====================

public class PredictionDashboardDto
{
    public bool ProfileComplete { get; set; }
    public double? LatestScore { get; set; }
    public DashboardTodaySummary? TodaySummary { get; set; }
    public List<DashboardWeekTrend> WeekTrend { get; set; } = new();
    public int TotalPredictions { get; set; }
    public int TripsToday { get; set; }
}

public class DashboardTodaySummary
{
    public double TotalDistance { get; set; }
    public int MealsLogged { get; set; }
    public bool Recycled { get; set; }
}

public class DashboardWeekTrend
{
    public DateTime Date { get; set; }
    public double AvgScore { get; set; }
}
