using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;

namespace EcoBackend.API.Services;

/// <summary>
/// Background jobs for scheduled tasks
/// </summary>
public class BackgroundJobService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<BackgroundJobService> _logger;
    
    public BackgroundJobService(IServiceProvider serviceProvider, ILogger<BackgroundJobService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }
    
    /// <summary>
    /// Calculate and update daily streaks for all users
    /// Runs every day at midnight UTC
    /// </summary>
    public async Task CalculateDailyStreaksAsync()
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<EcoDbContext>();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<User>>();
        
        _logger.LogInformation("Starting daily streak calculation...");
        
        var today = DateTime.UtcNow.Date;
        var yesterday = today.AddDays(-1);
        
        var users = await userManager.Users.ToListAsync();
        int streaksUpdated = 0;
        int streaksReset = 0;
        
        foreach (var user in users)
        {
            // Check if user was active yesterday (had activities or daily score)
            var yesterdayActivity = await context.Activities
                .AnyAsync(a => a.UserId == user.Id && a.ActivityDate.Date == yesterday);
            
            var yesterdayScore = await context.DailyScores
                .AnyAsync(ds => ds.UserId == user.Id && ds.Date.Date == yesterday);
            
            if (yesterdayActivity || yesterdayScore)
            {
                // User was active - increment streak
                user.CurrentStreak++;
                
                // Update longest streak if current exceeds it
                if (user.CurrentStreak > user.LongestStreak)
                {
                    user.LongestStreak = user.CurrentStreak;
                }
                
                streaksUpdated++;
                
                // Send streak milestone notifications
                if (user.CurrentStreak % 7 == 0) // Weekly milestone
                {
                    var notificationService = scope.ServiceProvider.GetRequiredService<NotificationService>();
                    await notificationService.SendStreakNotificationAsync(user.Id, user.CurrentStreak);
                }
            }
            else
            {
                // User was not active - reset streak
                if (user.CurrentStreak > 0)
                {
                    user.CurrentStreak = 0;
                    streaksReset++;
                }
            }
        }
        
        await context.SaveChangesAsync();
        
        _logger.LogInformation(
            $"Daily streak calculation complete. Updated: {streaksUpdated}, Reset: {streaksReset}"
        );
    }
    
    /// <summary>
    /// Generate weekly reports for all active users
    /// Runs every Monday at 1 AM UTC
    /// </summary>
    public async Task GenerateWeeklyReportsAsync()
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<EcoDbContext>();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<User>>();
        
        _logger.LogInformation("Starting weekly report generation...");
        
        var today = DateTime.UtcNow.Date;
        var weekStart = today.AddDays(-7);
        
        var users = await userManager.Users.Where(u => u.EmailConfirmed).ToListAsync();
        int reportsGenerated = 0;
        
        foreach (var user in users)
        {
            // Get activities for the week
            var activities = await context.Activities
                .Where(a => a.UserId == user.Id && a.ActivityDate >= weekStart && a.ActivityDate <= today)
                .ToListAsync();
            
            if (!activities.Any())
            {
                continue; // Skip users with no activities
            }
            
            var totalActivities = activities.Count;
            var totalCO2Saved = activities.Where(a => a.CO2Impact < 0).Sum(a => Math.Abs(a.CO2Impact));
            var totalCO2Emitted = activities.Where(a => a.CO2Impact > 0).Sum(a => a.CO2Impact);
            
            // Get trips for the week
            var trips = await context.Trips
                .Where(t => t.UserId == user.Id && t.TripDate >= weekStart && t.TripDate <= today)
                .ToListAsync();
            
            var totalTripsCO2Saved = trips.Sum(t => t.CO2Saved);
            var totalTripsCO2Emitted = trips.Sum(t => t.CO2Emitted);
            
            // Create summary (log for now - could save to database or send email)
            _logger.LogInformation(
                $"Weekly report for {user.UserName}: " +
                $"Activities: {totalActivities}, " +
                $"CO2 Saved: {totalCO2Saved + totalTripsCO2Saved:F2}kg, " +
                $"CO2 Emitted: {totalCO2Emitted + totalTripsCO2Emitted:F2}kg, " +
                $"Trips: {trips.Count}, " +
                $"Current Streak: {user.CurrentStreak}"
            );
            
            reportsGenerated++;
        }
        
        _logger.LogInformation($"Weekly report generation complete. Generated: {reportsGenerated}");
    }
    
    /// <summary>
    /// Generate monthly reports for all active users
    /// Runs on the 1st day of each month at 2 AM UTC
    /// </summary>
    public async Task GenerateMonthlyReportsAsync()
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<EcoDbContext>();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<User>>();
        
        _logger.LogInformation("Starting monthly report generation...");
        
        var today = DateTime.UtcNow.Date;
        var monthStart = new DateTime(today.Year, today.Month, 1).AddMonths(-1);
        var monthEnd = monthStart.AddMonths(1).AddDays(-1);
        
        var users = await userManager.Users.Where(u => u.EmailConfirmed).ToListAsync();
        int reportsGenerated = 0;
        
        foreach (var user in users)
        {
            // Get activities for the month
            var activities = await context.Activities
                .Where(a => a.UserId == user.Id && a.ActivityDate >= monthStart && a.ActivityDate <= monthEnd)
                .ToListAsync();
            
            if (!activities.Any())
            {
                continue;
            }
            
            var totalActivities = activities.Count;
            var totalCO2Saved = activities.Where(a => a.CO2Impact < 0).Sum(a => Math.Abs(a.CO2Impact));
            var totalCO2Emitted = activities.Where(a => a.CO2Impact > 0).Sum(a => a.CO2Impact);
            
            // Get trips for the month
            var trips = await context.Trips
                .Where(t => t.UserId == user.Id && t.TripDate >= monthStart && t.TripDate <= monthEnd)
                .ToListAsync();
            
            var totalTripsCO2Saved = trips.Sum(t => t.CO2Saved);
            var totalTripsCO2Emitted = trips.Sum(t => t.CO2Emitted);
            
            // Get badges earned this month
            var badgesEarned = await context.UserBadges
                .Where(ub => ub.UserId == user.Id && ub.EarnedAt >= monthStart && ub.EarnedAt <= monthEnd)
                .CountAsync();
            
            _logger.LogInformation(
                $"Monthly report for {user.UserName} ({monthStart:yyyy-MM}): " +
                $"Activities: {totalActivities}, " +
                $"CO2 Saved: {totalCO2Saved + totalTripsCO2Saved:F2}kg, " +
                $"CO2 Emitted: {totalCO2Emitted + totalTripsCO2Emitted:F2}kg, " +
                $"Trips: {trips.Count}, " +
                $"Badges Earned: {badgesEarned}, " +
                $"Level: {user.Level}, " +
                $"Longest Streak: {user.LongestStreak}"
            );
            
            reportsGenerated++;
        }
        
        _logger.LogInformation($"Monthly report generation complete. Generated: {reportsGenerated}");
    }
    
    /// <summary>
    /// Check and award badges to users who meet requirements
    /// Runs every 6 hours
    /// </summary>
    public async Task CheckBadgeRequirementsAsync()
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<EcoDbContext>();
        var achievementService = scope.ServiceProvider.GetRequiredService<AchievementService>();
        var notificationService = scope.ServiceProvider.GetRequiredService<NotificationService>();
        
        _logger.LogInformation("Starting badge requirement check...");
        
        var users = await context.Users.ToListAsync();
        int badgesAwarded = 0;
        
        // Get all badges
        var badges = await context.Badges.ToListAsync();
        
        foreach (var user in users)
        {
            // Get user's existing badges
            var userBadgeIds = await context.UserBadges
                .Where(ub => ub.UserId == user.Id)
                .Select(ub => ub.BadgeId)
                .ToListAsync();
            
            foreach (var badge in badges.Where(b => !userBadgeIds.Contains(b.Id)))
            {
                bool meetsRequirement = false;
                
                // Check badge requirements based on type
                switch (badge.BadgeType.ToLower())
                {
                    case "streak":
                        // Example: "7-day streak" badge requires current_streak >= 7
                        if (badge.Name.Contains("7-day") && user.CurrentStreak >= 7)
                            meetsRequirement = true;
                        else if (badge.Name.Contains("30-day") && user.CurrentStreak >= 30)
                            meetsRequirement = true;
                        else if (badge.Name.Contains("100-day") && user.CurrentStreak >= 100)
                            meetsRequirement = true;
                        break;
                    
                    case "co2_saver":
                        // Check total CO2 saved
                        if (user.TotalCO2Saved >= badge.RequirementValue)
                            meetsRequirement = true;
                        break;
                    
                    case "activity":
                        // Check activity count
                        var activityCount = await context.Activities
                            .CountAsync(a => a.UserId == user.Id);
                        if (activityCount >= badge.RequirementValue)
                            meetsRequirement = true;
                        break;
                    
                    case "level":
                        // Check user level
                        if (user.Level >= badge.RequirementValue)
                            meetsRequirement = true;
                        break;
                }
                
                // Award badge if requirement is met
                if (meetsRequirement)
                {
                    var userBadge = new UserBadge
                    {
                        UserId = user.Id,
                        BadgeId = badge.Id,
                        EarnedAt = DateTime.UtcNow
                    };
                    
                    context.UserBadges.Add(userBadge);
                    await context.SaveChangesAsync();
                    
                    // Send notification
                    await notificationService.SendBadgeNotificationAsync(user.Id, badge.Name, badge.Id);
                    
                    badgesAwarded++;
                    _logger.LogInformation($"Awarded badge '{badge.Name}' to user {user.UserName}");
                }
            }
        }
        
        _logger.LogInformation($"Badge requirement check complete. Badges awarded: {badgesAwarded}");
    }
    
    /// <summary>
    /// Cleanup expired password reset and email verification tokens
    /// Runs daily at 3 AM UTC
    /// </summary>
    public async Task CleanupExpiredTokensAsync()
    {
        using var scope = _serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<EcoDbContext>();
        var configuration = scope.ServiceProvider.GetRequiredService<IConfiguration>();
        
        _logger.LogInformation("Starting expired token cleanup...");
        
        var passwordResetTimeout = configuration.GetValue<int>("Email:PasswordResetTimeout", 3600);
        var emailVerificationTimeout = configuration.GetValue<int>("Email:EmailVerificationTimeout", 86400);
        
        // Remove expired password reset tokens
        var expiredPasswordTokens = await context.PasswordResetTokens
            .Where(t => !t.IsValid(passwordResetTimeout))
            .ToListAsync();
        
        context.PasswordResetTokens.RemoveRange(expiredPasswordTokens);
        
        // Remove expired email verification tokens
        var expiredEmailTokens = await context.EmailVerificationTokens
            .Where(t => !t.IsValid(emailVerificationTimeout))
            .ToListAsync();
        
        context.EmailVerificationTokens.RemoveRange(expiredEmailTokens);
        
        // Remove expired or revoked refresh tokens older than 30 days
        var thirtyDaysAgo = DateTime.UtcNow.AddDays(-30);
        var expiredRefreshTokens = await context.RefreshTokens
            .Where(t => t.ExpiresAt < DateTime.UtcNow || t.IsRevoked && t.RevokedAt < thirtyDaysAgo)
            .ToListAsync();
        
        context.RefreshTokens.RemoveRange(expiredRefreshTokens);
        
        await context.SaveChangesAsync();
        
        _logger.LogInformation(
            $"Expired token cleanup complete. " +
            $"Password reset tokens removed: {expiredPasswordTokens.Count}, " +
            $"Email verification tokens removed: {expiredEmailTokens.Count}, " +
            $"Refresh tokens removed: {expiredRefreshTokens.Count}"
        );
    }
}
