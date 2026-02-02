namespace EcoBackend.Core.Entities;

public class Trip
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string TransportMode { get; set; } = string.Empty;
    
    // Trip details
    public double DistanceKm { get; set; }
    public int? DurationMinutes { get; set; }
    
    // Locations
    public double? StartLatitude { get; set; }
    public double? StartLongitude { get; set; }
    public string StartLocation { get; set; } = string.Empty;
    
    public double? EndLatitude { get; set; }
    public double? EndLongitude { get; set; }
    public string EndLocation { get; set; } = string.Empty;
    
    // Carbon impact
    public double CO2Emitted { get; set; }
    public double CO2Saved { get; set; } = 0;
    
    // Timestamps
    public DateTime TripDate { get; set; }
    public TimeSpan? StartTime { get; set; }
    public TimeSpan? EndTime { get; set; }
    
    // Detection
    public bool IsAutoDetected { get; set; } = false;
    public double ConfidenceScore { get; set; } = 1.0;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
    public virtual ICollection<LocationPoint> Points { get; set; } = new List<LocationPoint>();
    
    // CO2 emissions per km for each transport mode (in kg)
    public static readonly Dictionary<string, double> CO2PerKm = new()
    {
        { "walking", 0 },
        { "cycling", 0 },
        { "running", 0 },
        { "bus", 0.089 },
        { "train", 0.041 },
        { "metro", 0.033 },
        { "car", 0.21 },
        { "carpool", 0.105 },
        { "taxi", 0.21 },
        { "motorcycle", 0.103 },
        { "flight", 0.255 },
        { "other", 0.15 }
    };
}

public class LocationPoint
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int? TripId { get; set; }
    
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public double? Altitude { get; set; }
    public double? Accuracy { get; set; }
    public double? Speed { get; set; }
    
    public DateTime Timestamp { get; set; }
    
    // Activity detection
    public string DetectedActivity { get; set; } = string.Empty;
    public double ActivityConfidence { get; set; } = 0;
    
    // Navigation
    public virtual User User { get; set; } = null!;
    public virtual Trip? Trip { get; set; }
}

public class TravelSummary
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime Date { get; set; }
    
    // Distance by mode
    public double WalkingKm { get; set; } = 0;
    public double CyclingKm { get; set; } = 0;
    public double PublicTransitKm { get; set; } = 0;
    public double CarKm { get; set; } = 0;
    public double OtherKm { get; set; } = 0;
    
    // Totals
    public double TotalKm { get; set; } = 0;
    public int TotalTrips { get; set; } = 0;
    public double TotalCO2Emitted { get; set; } = 0;
    public double TotalCO2Saved { get; set; } = 0;
    
    // Steps (from pedometer)
    public int Steps { get; set; } = 0;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}
