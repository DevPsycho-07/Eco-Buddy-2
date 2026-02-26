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
    public DbSet<WeeklyLog> WeeklyLogs => Set<WeeklyLog>();
    public DbSet<PredictionLog> PredictionLogs => Set<PredictionLog>();
    public DbSet<PredictionTrip> PredictionTrips => Set<PredictionTrip>();
    
    // Notifications & Tokens
    public DbSet<DeviceToken> DeviceTokens => Set<DeviceToken>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<NotificationPreference> NotificationPreferences => Set<NotificationPreference>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();
    public DbSet<EmailVerificationToken> EmailVerificationTokens => Set<EmailVerificationToken>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    
    // Chatbot
    public DbSet<ChatSession> ChatSessions => Set<ChatSession>();
    public DbSet<ChatMessage> ChatMessages => Set<ChatMessage>();
    
    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        
        // User configurations
        builder.Entity<User>(entity =>
        {
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Bio).HasMaxLength(500);
            entity.HasIndex(e => e.GoogleAuthId).IsUnique().HasFilter("\"GoogleAuthId\" IS NOT NULL");
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
        
        builder.Entity<DailyLog>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.Date }).IsUnique();
        });
        
        builder.Entity<PredictionTrip>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.Date });
        });
        
        // Notification & Token configurations
        builder.Entity<DeviceToken>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.Token }).IsUnique();
        });
        
        builder.Entity<PasswordResetToken>(entity =>
        {
            entity.HasIndex(e => e.UserId).IsUnique();
            entity.HasIndex(e => e.Token).IsUnique();
        });
        
        builder.Entity<EmailVerificationToken>(entity =>
        {
            entity.HasIndex(e => e.UserId).IsUnique();
            entity.HasIndex(e => e.Token).IsUnique();
        });
        
        builder.Entity<RefreshToken>(entity =>
        {
            entity.HasIndex(e => e.Token).IsUnique();
            entity.HasIndex(e => e.UserId);
        });
        
        // Notification preferences configuration
        builder.Entity<NotificationPreference>(entity =>
        {
            entity.HasIndex(e => e.UserId).IsUnique();
        });
        
        // Weekly log configuration
        builder.Entity<WeeklyLog>(entity =>
        {
            entity.HasIndex(e => new { e.UserId, e.WeekStartDate }).IsUnique();
        });
        
        // Chat session configuration
        builder.Entity<ChatSession>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.User)
                .WithMany(u => u.ChatSessions)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        });
        
        builder.Entity<ChatMessage>(entity =>
        {
            entity.HasOne(e => e.Session)
                .WithMany(s => s.Messages)
                .HasForeignKey(e => e.SessionId)
                .OnDelete(DeleteBehavior.Cascade);
        });
        
        // Seed Badge data
        SeedBadges(builder);
    }
    
    private static void SeedBadges(ModelBuilder builder)
    {
        var badges = new List<Badge>
        {
            // Transport badges
            new Badge { Id = 1, Name = "First Steps", Description = "Log your first walking activity", Icon = "🚶", BadgeType = "transport", RequirementType = "activities_count", RequirementValue = 1, RequirementCategory = "walking", PointsReward = 10 },
            new Badge { Id = 2, Name = "Walker", Description = "Walk a total of 10 km", Icon = "🚶", BadgeType = "transport", RequirementType = "distance", RequirementValue = 10, RequirementCategory = "walking", PointsReward = 25 },
            new Badge { Id = 3, Name = "Cyclist", Description = "Cycle a total of 20 km", Icon = "🚲", BadgeType = "transport", RequirementType = "distance", RequirementValue = 20, RequirementCategory = "cycling", PointsReward = 30 },
            new Badge { Id = 4, Name = "Transit Pro", Description = "Use public transit 20 times", Icon = "🚌", BadgeType = "transport", RequirementType = "activities_count", RequirementValue = 20, RequirementCategory = "public_transit", PointsReward = 35 },
            new Badge { Id = 5, Name = "Marathon Runner", Description = "Run a total of 50 km", Icon = "🏃", BadgeType = "transport", RequirementType = "distance", RequirementValue = 50, RequirementCategory = "running", PointsReward = 50 },
            new Badge { Id = 6, Name = "Eco Commuter", Description = "Use eco-friendly transport 50 times", Icon = "🌍", BadgeType = "transport", RequirementType = "activities_count", RequirementValue = 50, RequirementCategory = "eco_transport", PointsReward = 100 },

            // Food badges
            new Badge { Id = 7, Name = "Vegan Day", Description = "Log vegan for a whole day", Icon = "🌱", BadgeType = "food", RequirementType = "activities_count", RequirementValue = 1, RequirementCategory = "vegan", PointsReward = 20 },
            new Badge { Id = 8, Name = "Vegan Week", Description = "Eat vegan for 7 consecutive days", Icon = "🥬", BadgeType = "food", RequirementType = "streak", RequirementValue = 7, RequirementCategory = "vegan", PointsReward = 60 },
            new Badge { Id = 9, Name = "Local Hero", Description = "Buy local produce 10 times", Icon = "🥕", BadgeType = "food", RequirementType = "activities_count", RequirementValue = 10, RequirementCategory = "local", PointsReward = 30 },
            new Badge { Id = 10, Name = "Vegetarian", Description = "Log vegetarian meals for 5 days", Icon = "🥗", BadgeType = "food", RequirementType = "streak", RequirementValue = 5, RequirementCategory = "vegetarian", PointsReward = 40 },
            new Badge { Id = 11, Name = "Zero Waste Chef", Description = "Log 15 zero waste cooking activities", Icon = "♻️", BadgeType = "food", RequirementType = "activities_count", RequirementValue = 15, RequirementCategory = "zero_waste", PointsReward = 50 },

            // Energy badges
            new Badge { Id = 12, Name = "Energy Saver", Description = "Log solar panelling 30 times", Icon = "☀️", BadgeType = "energy", RequirementType = "activities_count", RequirementValue = 30, RequirementCategory = "solar", PointsReward = 75 },
            new Badge { Id = 13, Name = "Light Master", Description = "Switch to LED bulbs 5 times", Icon = "💡", BadgeType = "energy", RequirementType = "activities_count", RequirementValue = 5, RequirementCategory = "led", PointsReward = 35 },
            new Badge { Id = 14, Name = "Power Manager", Description = "Document 20 energy saving actions", Icon = "⚡", BadgeType = "energy", RequirementType = "activities_count", RequirementValue = 20, RequirementCategory = "power_saving", PointsReward = 60 },
            new Badge { Id = 15, Name = "Renewable Champion", Description = "Use renewable energy sources for 10 days", Icon = "🌊", BadgeType = "energy", RequirementType = "streak", RequirementValue = 10, RequirementCategory = "renewable", PointsReward = 80 },

            // Recycling badges
            new Badge { Id = 16, Name = "Recycling Hero", Description = "Log 15 recycling activities", Icon = "♻️", BadgeType = "recycling", RequirementType = "activities_count", RequirementValue = 15, RequirementCategory = "recycling", PointsReward = 40 },
            new Badge { Id = 17, Name = "Waste Warrior", Description = "Recycle for 10 consecutive days", Icon = "🛡️", BadgeType = "recycling", RequirementType = "streak", RequirementValue = 10, RequirementCategory = "recycling", PointsReward = 70 },
            new Badge { Id = 18, Name = "Upcycler", Description = "Log 20 upcycling activities", Icon = "🎨", BadgeType = "recycling", RequirementType = "activities_count", RequirementValue = 20, RequirementCategory = "upcycling", PointsReward = 55 },
            new Badge { Id = 19, Name = "Compost Champion", Description = "Compost for 7 consecutive days", Icon = "🌿", BadgeType = "recycling", RequirementType = "streak", RequirementValue = 7, RequirementCategory = "composting", PointsReward = 45 },
            new Badge { Id = 20, Name = "Plastic Free", Description = "Use no plastic products for 3 days", Icon = "🚫", BadgeType = "recycling", RequirementType = "streak", RequirementValue = 3, RequirementCategory = "plastic_free", PointsReward = 50 },

            // General/Milestone badges
            new Badge { Id = 21, Name = "Tree Planter", Description = "Plant a tree", Icon = "🌳", BadgeType = "general", RequirementType = "activities_count", RequirementValue = 1, RequirementCategory = "tree_planting", PointsReward = 100 },
            new Badge { Id = 22, Name = "Eco Champion", Description = "Earn 500 eco points", Icon = "👑", BadgeType = "general", RequirementType = "eco_points", RequirementValue = 500, RequirementCategory = "general", PointsReward = 200 },
            new Badge { Id = 23, Name = "Week Warrior", Description = "Maintain 7-day streak", Icon = "🔥", BadgeType = "general", RequirementType = "streak", RequirementValue = 7, RequirementCategory = "general", PointsReward = 80 },
            new Badge { Id = 24, Name = "Month Master", Description = "Maintain 30-day streak", Icon = "🏆", BadgeType = "general", RequirementType = "streak", RequirementValue = 30, RequirementCategory = "general", PointsReward = 300 },
            new Badge { Id = 25, Name = "Century Saver", Description = "Save 100 kg of CO2", Icon = "💚", BadgeType = "general", RequirementType = "co2_saved", RequirementValue = 100, RequirementCategory = "general", PointsReward = 150 },
            new Badge { Id = 26, Name = "Carbon Crusher", Description = "Save 500 kg of CO2", Icon = "💪", BadgeType = "general", RequirementType = "co2_saved", RequirementValue = 500, RequirementCategory = "general", PointsReward = 500 },
        };
        
        builder.Entity<Badge>().HasData(badges);
    }
}
