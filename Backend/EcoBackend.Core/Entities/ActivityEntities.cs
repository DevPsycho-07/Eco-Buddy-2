namespace EcoBackend.Core.Entities;

public class ActivityCategory
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string Color { get; set; } = "#4CAF50";
    public string Description { get; set; } = string.Empty;
    
    // Navigation
    public virtual ICollection<ActivityType> ActivityTypes { get; set; } = new List<ActivityType>();
    public virtual ICollection<Tip> Tips { get; set; } = new List<Tip>();
}

public class ActivityType
{
    public int Id { get; set; }
    public int CategoryId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public double CO2Impact { get; set; }
    public string ImpactUnit { get; set; } = "per instance";
    public bool IsEcoFriendly { get; set; } = false;
    public int Points { get; set; } = 10;
    
    // Navigation
    public virtual ActivityCategory Category { get; set; } = null!;
    public virtual ICollection<Activity> Activities { get; set; } = new List<Activity>();
}

public class Activity
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int ActivityTypeId { get; set; }
    
    // Activity details
    public double Quantity { get; set; } = 1.0;
    public string Unit { get; set; } = string.Empty;
    public string Notes { get; set; } = string.Empty;
    
    // Calculated impact
    public double CO2Impact { get; set; }
    public int PointsEarned { get; set; } = 0;
    
    // Location data (optional)
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public string LocationName { get; set; } = string.Empty;
    
    // Timestamps
    public DateTime ActivityDate { get; set; }
    public TimeSpan? ActivityTime { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Auto-detected or manual
    public bool IsAutoDetected { get; set; } = false;
    
    // Navigation
    public virtual User User { get; set; } = null!;
    public virtual ActivityType ActivityType { get; set; } = null!;
}

public class Tip
{
    public int Id { get; set; }
    public int? CategoryId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public string ImpactDescription { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public int Priority { get; set; } = 0;
    
    // Navigation
    public virtual ActivityCategory? Category { get; set; }
}
