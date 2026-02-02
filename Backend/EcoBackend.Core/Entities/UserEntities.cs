using Microsoft.AspNetCore.Identity;

namespace EcoBackend.Core.Entities;

public class User : IdentityUser<int>
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? ProfilePicture { get; set; }
    public string Bio { get; set; } = string.Empty;
    
    // Eco-related fields
    public int EcoScore { get; set; } = 0;
    public double TotalCO2Saved { get; set; } = 0.0;
    public int CurrentStreak { get; set; } = 0;
    public int LongestStreak { get; set; } = 0;
    public int Level { get; set; } = 1;
    public int ExperiencePoints { get; set; } = 0;
    
    // Preferences
    public string Units { get; set; } = "metric";
    public bool NotificationsEnabled { get; set; } = true;
    public bool DarkMode { get; set; } = false;
    
    // Privacy settings
    public bool LocationTracking { get; set; } = false;
    public bool ActivityRecognition { get; set; } = false;
    public bool HealthDataSync { get; set; } = false;
    public bool CalendarAccess { get; set; } = false;
    
    // Timestamps
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public virtual ICollection<UserGoal> Goals { get; set; } = new List<UserGoal>();
    public virtual ICollection<DailyScore> DailyScores { get; set; } = new List<DailyScore>();
    public virtual ICollection<Activity> Activities { get; set; } = new List<Activity>();
    public virtual ICollection<UserBadge> Badges { get; set; } = new List<UserBadge>();
    public virtual ICollection<UserChallenge> Challenges { get; set; } = new List<UserChallenge>();
    public virtual ICollection<Trip> Trips { get; set; } = new List<Trip>();
    public virtual UserEcoProfile? EcoProfile { get; set; }
    
    public void CalculateLevel()
    {
        Level = (ExperiencePoints / 100) + 1;
    }
}

public class UserGoal
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public double TargetValue { get; set; }
    public double CurrentValue { get; set; } = 0.0;
    public string Unit { get; set; } = string.Empty;
    public bool IsCompleted { get; set; } = false;
    public DateTime? Deadline { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
    
    public double ProgressPercentage => TargetValue == 0 ? 0 : Math.Min((CurrentValue / TargetValue) * 100, 100);
}

public class DailyScore
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime Date { get; set; }
    public int Score { get; set; } = 0;
    public double CO2Emitted { get; set; } = 0.0;
    public double CO2Saved { get; set; } = 0.0;
    public int Steps { get; set; } = 0;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}
