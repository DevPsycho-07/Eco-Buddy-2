namespace EcoBackend.Core.Entities;

public class Badge
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string BadgeType { get; set; } = "general";
    
    // Requirements
    public string RequirementType { get; set; } = string.Empty;
    public double RequirementValue { get; set; }
    public string RequirementCategory { get; set; } = string.Empty;
    
    // Rewards
    public int PointsReward { get; set; } = 50;
    public bool IsActive { get; set; } = true;
    
    // Navigation
    public virtual ICollection<UserBadge> UserBadges { get; set; } = new List<UserBadge>();
}

public class UserBadge
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int BadgeId { get; set; }
    public DateTime EarnedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
    public virtual Badge Badge { get; set; } = null!;
}

public class Challenge
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string ChallengeType { get; set; } = "weekly";
    
    // Requirements
    public int? TargetActivityTypeId { get; set; }
    public int? TargetCategoryId { get; set; }
    public double TargetValue { get; set; }
    public string TargetUnit { get; set; } = string.Empty;
    
    // Rewards
    public int PointsReward { get; set; } = 100;
    public int? BadgeRewardId { get; set; }
    
    // Dates
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public bool IsActive { get; set; } = true;
    
    // Navigation
    public virtual ActivityType? TargetActivityType { get; set; }
    public virtual ActivityCategory? TargetCategory { get; set; }
    public virtual Badge? BadgeReward { get; set; }
    public virtual ICollection<UserChallenge> UserChallenges { get; set; } = new List<UserChallenge>();
}

public class UserChallenge
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int ChallengeId { get; set; }
    public double CurrentProgress { get; set; } = 0.0;
    public bool IsCompleted { get; set; } = false;
    public DateTime? CompletedAt { get; set; }
    public DateTime JoinedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
    public virtual Challenge Challenge { get; set; } = null!;
    
    public double ProgressPercentage => Challenge.TargetValue == 0 ? 0 : Math.Min((CurrentProgress / Challenge.TargetValue) * 100, 100);
}
