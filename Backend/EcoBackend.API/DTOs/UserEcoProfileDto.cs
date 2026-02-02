namespace EcoBackend.API.DTOs;

public class UserEcoProfileDto
{
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
}
