using System.ComponentModel.DataAnnotations;

namespace EcoBackend.API.DTOs;

public class TripDto
{
    public int Id { get; set; }
    public string TransportMode { get; set; } = string.Empty;
    public double DistanceKm { get; set; }
    public int? DurationMinutes { get; set; }
    
    public double? StartLatitude { get; set; }
    public double? StartLongitude { get; set; }
    public string StartLocation { get; set; } = string.Empty;
    
    public double? EndLatitude { get; set; }
    public double? EndLongitude { get; set; }
    public string EndLocation { get; set; } = string.Empty;
    
    public double CO2Emitted { get; set; }
    public double CO2Saved { get; set; }
    
    public DateTime TripDate { get; set; }
    public TimeSpan? StartTime { get; set; }
    public TimeSpan? EndTime { get; set; }
    
    public bool IsAutoDetected { get; set; }
    public double ConfidenceScore { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateTripDto
{
    [Required]
    public string TransportMode { get; set; } = string.Empty;
    
    [Required]
    [Range(0, double.MaxValue, ErrorMessage = "Distance must be positive")]
    public double DistanceKm { get; set; }
    
    [Range(0, int.MaxValue, ErrorMessage = "Duration cannot be negative")]
    public int? DurationMinutes { get; set; }
    
    public double? StartLatitude { get; set; }
    public double? StartLongitude { get; set; }
    public string StartLocation { get; set; } = string.Empty;
    
    public double? EndLatitude { get; set; }
    public double? EndLongitude { get; set; }
    public string EndLocation { get; set; } = string.Empty;
    
    [Required]
    public DateTime TripDate { get; set; }
    
    public TimeSpan? StartTime { get; set; }
    public TimeSpan? EndTime { get; set; }
    
    public bool IsAutoDetected { get; set; } = false;
    
    [Range(0, 1, ErrorMessage = "Confidence score must be between 0 and 1")]
    public double ConfidenceScore { get; set; } = 1.0;
}

public class UpdateTripDto
{
    public string? TransportMode { get; set; }
    
    [Range(0, double.MaxValue, ErrorMessage = "Distance must be positive")]
    public double? DistanceKm { get; set; }
    
    [Range(0, int.MaxValue, ErrorMessage = "Duration cannot be negative")]
    public int? DurationMinutes { get; set; }
    
    public double? StartLatitude { get; set; }
    public double? StartLongitude { get; set; }
    public string? StartLocation { get; set; }
    
    public double? EndLatitude { get; set; }
    public double? EndLongitude { get; set; }
    public string? EndLocation { get; set; }
    
    public DateTime? TripDate { get; set; }
    public TimeSpan? StartTime { get; set; }
    public TimeSpan? EndTime { get; set; }
    
    [Range(0, 1, ErrorMessage = "Confidence score must be between 0 and 1")]
    public double? ConfidenceScore { get; set; }
}

public class LocationPointDto
{
    public int Id { get; set; }
    public int? TripId { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public double? Altitude { get; set; }
    public double? Accuracy { get; set; }
    public double? Speed { get; set; }
    public DateTime Timestamp { get; set; }
    public string DetectedActivity { get; set; } = string.Empty;
    public double ActivityConfidence { get; set; }
}

public class CreateLocationPointDto
{
    [Required]
    [Range(-90, 90, ErrorMessage = "Latitude must be between -90 and 90")]
    public double Latitude { get; set; }
    
    [Required]
    [Range(-180, 180, ErrorMessage = "Longitude must be between -180 and 180")]
    public double Longitude { get; set; }
    
    public double? Altitude { get; set; }
    public double? Accuracy { get; set; }
    public double? Speed { get; set; }
    
    [Required]
    public DateTime Timestamp { get; set; }
    
    public string DetectedActivity { get; set; } = string.Empty;
    
    [Range(0, 1, ErrorMessage = "Activity confidence must be between 0 and 1")]
    public double ActivityConfidence { get; set; } = 0;
}

public class BatchLocationPointsDto
{
    [Required]
    public List<CreateLocationPointDto> Points { get; set; } = new();
}

public class UpdateStepsDto
{
    [Required]
    public DateTime Date { get; set; }
    
    [Required]
    [Range(0, int.MaxValue, ErrorMessage = "Steps cannot be negative")]
    public int Steps { get; set; }
}

public class TravelSummaryDto
{
    public int Id { get; set; }
    public DateTime Date { get; set; }
    public double WalkingKm { get; set; }
    public double CyclingKm { get; set; }
    public double PublicTransitKm { get; set; }
    public double CarKm { get; set; }
    public double OtherKm { get; set; }
    public double TotalKm { get; set; }
    public int TotalTrips { get; set; }
    public double TotalCO2Emitted { get; set; }
    public double TotalCO2Saved { get; set; }
    public int Steps { get; set; }
}

public class TripStatsDto
{
    public string Period { get; set; } = string.Empty;
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public double TotalDistance { get; set; }
    public int TotalTrips { get; set; }
    public double TotalCO2Emitted { get; set; }
    public double TotalCO2Saved { get; set; }
    public Dictionary<string, ModeStatsDto> ByMode { get; set; } = new();
}

public class ModeStatsDto
{
    public double DistanceKm { get; set; }
    public int Trips { get; set; }
    public double CO2Emitted { get; set; }
}
