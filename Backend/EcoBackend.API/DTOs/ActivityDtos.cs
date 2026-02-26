namespace EcoBackend.API.DTOs;

public class ActivityCategoryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string Color { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public List<ActivityTypeDto> ActivityTypes { get; set; } = new();
}

public class ActivityTypeDto
{
    public int Id { get; set; }
    public int CategoryId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public double CO2Impact { get; set; }
    public string ImpactUnit { get; set; } = string.Empty;
    public bool IsEcoFriendly { get; set; }
    public int Points { get; set; }
    public ActivityCategoryDto? Category { get; set; }
}

public class ActivityDto
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int ActivityTypeId { get; set; }
    public double Quantity { get; set; }
    public string Unit { get; set; } = string.Empty;
    public string Notes { get; set; } = string.Empty;
    public double CO2Impact { get; set; }
    public int PointsEarned { get; set; }
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string LocationName { get; set; } = string.Empty;
    public DateTime ActivityDate { get; set; }
    public TimeSpan? ActivityTime { get; set; }
    public bool IsAutoDetected { get; set; }
    public ActivityTypeDto? ActivityType { get; set; }
}

public class ActivityCreateDto
{
    public int ActivityType { get; set; }
    public double Quantity { get; set; } = 1.0;
    public string? Unit { get; set; }
    public string? Notes { get; set; }
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string? LocationName { get; set; }
    public DateTime ActivityDate { get; set; }
    public TimeSpan? ActivityTime { get; set; }
}

public class ActivitySummaryDto
{
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public int TotalActivities { get; set; }
    public int TotalPoints { get; set; }
    public double TotalCO2Saved { get; set; }
    public double TotalCO2Emitted { get; set; }
    public Dictionary<string, CategoryStats> ByCategory { get; set; } = new();
}

public class CategoryStats
{
    public int Count { get; set; }
    public double CO2Impact { get; set; }
}

public class TipDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string ImpactDescription { get; set; } = string.Empty;
    public int Priority { get; set; }
}
