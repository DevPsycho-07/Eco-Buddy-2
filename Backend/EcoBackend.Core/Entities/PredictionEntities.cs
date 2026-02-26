namespace EcoBackend.Core.Entities;

public class UserEcoProfile
{
    public int Id { get; set; }
    public int UserId { get; set; }
    
    // Household
    public int HouseholdSize { get; set; } = 1;
    
    // Age group
    public string AgeGroup { get; set; } = "26-35";
    
    // Lifestyle type
    public string LifestyleType { get; set; } = "office_worker";
    
    // Location type
    public string LocationType { get; set; } = "urban";
    
    // Vehicle info
    public string VehicleType { get; set; } = "none";
    public string CarFuelType { get; set; } = "none";
    
    // Diet preference
    public string DietType { get; set; } = "omnivore";
    
    // Energy & Home
    public bool UsesSolarPanels { get; set; } = false;
    public bool SmartThermostat { get; set; } = false;
    public double RenewableEnergyPercent { get; set; } = 0;
    
    // Waste habits
    public bool RecyclingPracticed { get; set; } = false;
    public bool CompostingPracticed { get; set; } = false;
    public string WasteBagSize { get; set; } = "medium";
    
    // Social activity
    public string SocialActivity { get; set; } = "sometimes";
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}

public class DailyLog
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime Date { get; set; }
    
    // Travel (auto-calculated from trips)
    public double CarKm { get; set; } = 0;
    public double BusKm { get; set; } = 0;
    /// <summary>Formerly TrainKm — matches Django train_metro_km.</summary>
    public double TrainMetroKm { get; set; } = 0;
    public double BikeKm { get; set; } = 0;
    public double WalkKm { get; set; } = 0;
    
    // Food
    public int MeatMeals { get; set; } = 0;        // broad (kept for backwards compat)
    public int RedMeatMeals { get; set; } = 0;
    public int PoultryMeals { get; set; } = 0;
    public int FishMeals { get; set; } = 0;
    public int VegetarianMeals { get; set; } = 0;
    public int VeganMeals { get; set; } = 0;
    public int VegMeals { get; set; } = 0;         // kept for backwards compat
    public int LocalFoodItems { get; set; } = 0;
    public double FoodWasteKg { get; set; } = 0;
    
    // Energy
    public double ElectricityKwh { get; set; } = 0;
    public double NaturalGasTherms { get; set; } = 0;
    public double AcHours { get; set; } = 0;
    public double HeatingHours { get; set; } = 0;
    public double WaterUsageLiters { get; set; } = 0;
    public bool UsedHeating { get; set; } = false;
    public bool UsedCooling { get; set; } = false;
    
    // Waste
    public bool RecycledToday { get; set; } = false;
    public bool CompostedToday { get; set; } = false;
    
    // Shopping
    public int SingleUsePlasticItems { get; set; } = 0;
    public int ReusableItems { get; set; } = 0;
    
    // Lifestyle
    public int ShowerFrequency { get; set; } = 1;
    public double TvPcHours { get; set; } = 0;
    public double InternetHours { get; set; } = 0;
    
    // Calculated CO2
    public double TotalCO2 { get; set; } = 0;
    
    // Prediction result (filled by ML pipeline)
    public double? EcoScore { get; set; }
    public string ScoreCategory { get; set; } = string.Empty;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}

/// <summary>Weekly activity log for less frequent inputs (mirrors Django WeeklyLog).</summary>
public class WeeklyLog
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateOnly WeekStartDate { get; set; }
    
    // Waste
    public int WasteBagCount { get; set; } = 0;
    public double GeneralWasteKg { get; set; } = 0;
    public double RecycledWasteKg { get; set; } = 0;
    
    // Shopping
    public double GroceryBill { get; set; } = 0;
    public int NewClothesMonthly { get; set; } = 0;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}

public class PredictionLog
{
    public int Id { get; set; }
    public int? UserId { get; set; }
    
    /// <summary>JSON blob of input features used for prediction.</summary>
    public string InputData { get; set; } = "{}";
    
    /// <summary>Predicted eco score (0-100).</summary>
    public double PredictedScore { get; set; }
    
    /// <summary>Model confidence if available.</summary>
    public double? Confidence { get; set; }
    
    public string ModelVersion { get; set; } = "v1.0";
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User? User { get; set; }
}

/// <summary>GPS-tracked trip for prediction distance measurement (mirrors Django predictions.Trip).</summary>
public class PredictionTrip
{
    public int Id { get; set; }
    public int UserId { get; set; }
    
    public string TransportMode { get; set; } = "walk";
    
    // GPS coordinates
    public double StartLatitude { get; set; }
    public double StartLongitude { get; set; }
    public double EndLatitude { get; set; }
    public double EndLongitude { get; set; }
    
    /// <summary>Calculated distance in kilometres (Haversine).</summary>
    public double DistanceKm { get; set; }
    
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public DateTime Date { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
    
    /// <summary>Haversine distance between two GPS coordinates (km).</summary>
    public static double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
    {
        const double R = 6371; // Earth radius in km
        var dLat = DegreesToRadians(lat2 - lat1);
        var dLon = DegreesToRadians(lon2 - lon1);
        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                Math.Cos(DegreesToRadians(lat1)) * Math.Cos(DegreesToRadians(lat2)) *
                Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return R * c;
    }
    
    private static double DegreesToRadians(double degrees) => degrees * Math.PI / 180.0;
}
