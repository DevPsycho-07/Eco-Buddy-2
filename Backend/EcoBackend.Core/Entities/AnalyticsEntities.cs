namespace EcoBackend.Core.Entities;

public class WeeklyReport
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime WeekStart { get; set; }
    public DateTime WeekEnd { get; set; }
    
    // Stats
    public double TotalCO2Emitted { get; set; } = 0.0;
    public double TotalCO2Saved { get; set; } = 0.0;
    public int TotalActivities { get; set; } = 0;
    public int TotalPoints { get; set; } = 0;
    public double AverageDailyScore { get; set; } = 0.0;
    
    // Breakdown by category (stored as JSON)
    public string CategoryBreakdown { get; set; } = "{}";
    
    // Comparison
    public double ComparisonToPrevious { get; set; } = 0.0;
    public double ComparisonToAverage { get; set; } = 0.0;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}

public class MonthlyReport
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int Year { get; set; }
    public int Month { get; set; }
    
    // Stats
    public double TotalCO2Emitted { get; set; } = 0.0;
    public double TotalCO2Saved { get; set; } = 0.0;
    public int TotalActivities { get; set; } = 0;
    public int TotalPoints { get; set; } = 0;
    public double AverageDailyScore { get; set; } = 0.0;
    
    // Breakdown
    public string CategoryBreakdown { get; set; } = "{}";
    public string DailyBreakdown { get; set; } = "{}";
    
    // Achievements this month
    public int BadgesEarned { get; set; } = 0;
    public int ChallengesCompleted { get; set; } = 0;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation
    public virtual User User { get; set; } = null!;
}
