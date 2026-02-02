namespace EcoBackend.API.DTOs;

public class BadgeDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Icon { get; set; } = string.Empty;
    public string BadgeType { get; set; } = string.Empty;
    public int PointsReward { get; set; }
}

public class UserBadgeDto
{
    public int Id { get; set; }
    public BadgeDto Badge { get; set; } = null!;
    public DateTime EarnedAt { get; set; }
}

public class ChallengeDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string ChallengeType { get; set; } = string.Empty;
    public double TargetValue { get; set; }
    public string TargetUnit { get; set; } = string.Empty;
    public int PointsReward { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public bool IsActive { get; set; }
}

public class UserChallengeDto
{
    public int Id { get; set; }
    public ChallengeDto Challenge { get; set; } = null!;
    public double CurrentProgress { get; set; }
    public bool IsCompleted { get; set; }
    public double ProgressPercentage { get; set; }
    public DateTime JoinedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
}
