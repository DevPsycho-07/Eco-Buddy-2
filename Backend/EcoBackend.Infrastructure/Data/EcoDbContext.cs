using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using EcoBackend.Core.Entities;

namespace EcoBackend.Infrastructure.Data;

public class EcoDbContext : IdentityDbContext<User, IdentityRole<int>, int>
{
    public EcoDbContext(DbContextOptions<EcoDbContext> options) : base(options)
    {
    }
    
    // Users
    public DbSet<UserGoal> UserGoals => Set<UserGoal>();
    public DbSet<DailyScore> DailyScores => Set<DailyScore>();
    
    // Activities
    public DbSet<ActivityCategory> ActivityCategories => Set<ActivityCategory>();
    public DbSet<ActivityType> ActivityTypes => Set<ActivityType>();
    public DbSet<Activity> Activities => Set<Activity>();
    public DbSet<Tip> Tips => Set<Tip>();
    
    // Achievements
    public DbSet<Badge> Badges => Set<Badge>();
    public DbSet<UserBadge> UserBadges => Set<UserBadge>();
    public DbSet<Challenge> Challenges => Set<Challenge>();
    public DbSet<UserChallenge> UserChallenges => Set<UserChallenge>();
    
    // Travel
    public DbSet<Trip> Trips => Set<Trip>();
    public DbSet<LocationPoint> LocationPoints => Set<LocationPoint>();
    public DbSet<TravelSummary> TravelSummaries => Set<TravelSummary>();
    
    // Analytics
    public DbSet<WeeklyReport> WeeklyReports => Set<WeeklyReport>();
    public DbSet<MonthlyReport> MonthlyReports => Set<MonthlyReport>();
    
    // Predictions
    public DbSet<UserEcoProfile> UserEcoProfiles => Set<UserEcoProfile>();
    public DbSet<DailyLog> DailyLogs => Set<DailyLog>();
    public DbSet<PredictionLog> PredictionLogs => Set<PredictionLog>();
    
    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        
        // User configurations
        builder.Entity<User>(entity =>
        {
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Bio).HasMaxLength(500);
        });
        
        builder.Entity<DailyScore>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.Date }).IsUnique();
        });
        
        // Activity configurations
        builder.Entity<ActivityCategory>(entity =>
        {
            entity.HasIndex(e => e.Name).IsUnique();
        });
        
        builder.Entity<Activity>(entity =>
        {
            entity.HasOne(a => a.User)
                .WithMany(u => u.Activities)
                .HasForeignKey(a => a.UserId)
                .OnDelete(DeleteBehavior.Cascade);
                
            entity.HasOne(a => a.ActivityType)
                .WithMany(at => at.Activities)
                .HasForeignKey(a => a.ActivityTypeId)
                .OnDelete(DeleteBehavior.Restrict);
        });
        
        // Achievement configurations
        builder.Entity<UserBadge>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.BadgeId }).IsUnique();
        });
        
        builder.Entity<UserChallenge>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.ChallengeId }).IsUnique();
        });
        
        // Travel configurations
        builder.Entity<TravelSummary>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.Date }).IsUnique();
        });
        
        // Analytics configurations
        builder.Entity<WeeklyReport>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.WeekStart }).IsUnique();
        });
        
        builder.Entity<MonthlyReport>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.Year, e.Month }).IsUnique();
        });
        
        // Prediction configurations
        builder.Entity<UserEcoProfile>(entity =>
        {
            entity.HasIndex(e => e.UserId).IsUnique();
        });
    }
}
