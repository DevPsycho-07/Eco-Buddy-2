using Microsoft.AspNetCore.Identity;

namespace EcoBackend.Core.Entities;

public class User : IdentityUser<int>
{
    public const string DefaultProfilePicture = "profile_pictures/default-encrypted.png.enc";
    
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string ProfilePicture { get; set; } = DefaultProfilePicture;
    public string Bio { get; set; } = string.Empty;
    
    // Eco-related fields
    public int EcoScore { get; set; } = 0;
    public double TotalCO2Saved { get; set; } = 0.0;
    public int CurrentStreak { get; set; } = 0;
    public int LongestStreak { get; set; } = 0;
    public int Level { get; set; } = 1;
    public int ExperiencePoints { get; set; } = 0;
    
    // Streak tracking
    public DateOnly? LastActivityDate { get; set; }
    
    // Preferences
    public string Units { get; set; } = "metric";
    public bool NotificationsEnabled { get; set; } = true;
    public bool DarkMode { get; set; } = false;
    
    // Email verification
    public bool EmailVerified { get; set; } = false;
    
    // Google OAuth
    public string? GoogleAuthId { get; set; }
    
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
    public virtual NotificationPreference? NotificationPreferences { get; set; }
    public virtual ICollection<ChatSession> ChatSessions { get; set; } = new List<ChatSession>();
    
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

public class DeviceToken
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string Token { get; set; } = string.Empty;
    public string DeviceType { get; set; } = "mobile"; // mobile, web, tablet
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}

public class Notification
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string NotificationType { get; set; } = "general"; // achievement, badge, challenge, milestone, streak, general
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public int? TargetId { get; set; }
    public bool IsRead { get; set; } = false;
    public bool IsSent { get; set; } = false;
    public DateTime? SentAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}

public class NotificationPreference
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public bool DailyReminders { get; set; } = true;
    public bool AchievementAlerts { get; set; } = true;
    public bool WeeklyReports { get; set; } = true;
    public bool TipsAndSuggestions { get; set; } = true;
    public bool CommunityUpdates { get; set; } = false;
    
    // Navigation
    public virtual User User { get; set; } = null!;
    
    /// <summary>Returns whether a given notification_type is opted-in.</summary>
    public bool IsTypeEnabled(string notificationType) => notificationType switch
    {
        "achievement" or "badge" or "challenge" or "milestone" or "streak" or "level_up" or "goal" => AchievementAlerts,
        "daily_reminder" => DailyReminders,
        "weekly_report" => WeeklyReports,
        "tip" => TipsAndSuggestions,
        _ => CommunityUpdates,
    };
}

public class PasswordResetToken
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string Token { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
    
    public bool IsValid(int timeoutSeconds)
    {
        return DateTime.UtcNow < CreatedAt.AddSeconds(timeoutSeconds);
    }
}

public class EmailVerificationToken
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string Token { get; set; } = string.Empty;
    public bool IsVerified { get; set; } = false;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
    
    public bool IsValid(int timeoutSeconds)
    {
        return DateTime.UtcNow < CreatedAt.AddSeconds(timeoutSeconds) && !IsVerified;
    }
}

public class RefreshToken
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public bool IsRevoked { get; set; } = false;
    public DateTime? RevokedAt { get; set; }
    public string? ReplacedByToken { get; set; }
    
    // Navigation
    public virtual User User { get; set; } = null!;
    
    public bool IsValid => !IsRevoked && DateTime.UtcNow < ExpiresAt;
    public bool IsExpired => DateTime.UtcNow >= ExpiresAt;
}
