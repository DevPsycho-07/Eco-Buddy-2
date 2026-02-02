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
    public double TrainKm { get; set; } = 0;
    public double BikeKm { get; set; } = 0;
    public double WalkKm { get; set; } = 0;
    
    // Food
    public int MeatMeals { get; set; } = 0;
    public int VegMeals { get; set; } = 0;
    public int LocalFoodItems { get; set; } = 0;
    
    // Energy
    public double ElectricityKwh { get; set; } = 0;
    public bool UsedHeating { get; set; } = false;
    public bool UsedCooling { get; set; } = false;
    
    // Waste
    public bool RecycledToday { get; set; } = false;
    public bool CompostedToday { get; set; } = false;
    
    // Shopping
    public int SingleUsePlasticItems { get; set; } = 0;
    public int ReusableItems { get; set; } = 0;
    
    // Calculated CO2
    public double TotalCO2 { get; set; } = 0;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}

public class PredictionLog
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime Date { get; set; }
    
    public double PredictedCO2 { get; set; }
    public double ActualCO2 { get; set; }
    public double ErrorMargin { get; set; }
    
    public string ModelVersion { get; set; } = string.Empty;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}
