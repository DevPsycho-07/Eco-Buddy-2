using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using EcoBackend.Infrastructure.Data;
using EcoBackend.Core.Entities;

namespace EcoBackend.Tests.Utilities;

/// <summary>
/// Helper class for setting up test databases
/// </summary>
public static class TestDatabaseHelper
{
    /// <summary>
    /// Creates an in-memory database context for testing
    /// </summary>
    public static EcoDbContext CreateInMemoryContext(string databaseName = "TestDb")
    {
        var options = new DbContextOptionsBuilder<EcoDbContext>()
            .UseInMemoryDatabase(databaseName: databaseName)
            .Options;

        var context = new EcoDbContext(options);
        context.Database.EnsureCreated();
        return context;
    }

    /// <summary>
    /// Creates a context with a specific database instance
    /// </summary>
    public static (EcoDbContext context, DbContextOptions<EcoDbContext> options) CreateDatabaseContext()
    {
        var options = new DbContextOptionsBuilder<EcoDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        var context = new EcoDbContext(options);
        return (context, options);
    }

    /// <summary>
    /// Seed base test data into the database
    /// </summary>
    public static async Task SeedBasicDataAsync(EcoDbContext context)
    {
        // Clear existing data
        context.Users.RemoveRange(context.Users);
        context.Activities.RemoveRange(context.Activities);
        context.UserGoals.RemoveRange(context.UserGoals);
        context.Badges.RemoveRange(context.Badges);

        await context.SaveChangesAsync();

        // Add test users
        var users = new List<EcoBackend.Core.Entities.User>();
        for (int i = 1; i <= 3; i++)
        {
            users.Add(new EcoBackend.Core.Entities.User
            {
                UserName = $"testuser{i}",
                Email = $"testuser{i}@example.com",
                FirstName = $"Test{i}",
                LastName = "User",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("TestPassword123!"),
                EcoScore = i * 100,
                CurrentStreak = i,
                EmailConfirmed = true,
                CreatedAt = DateTime.UtcNow.AddDays(-i)
            });
        }

        context.Users.AddRange(users);
        await context.SaveChangesAsync();
    }

    /// <summary>
    /// Clears all data from the database
    /// </summary>
    public static async Task ClearAllDataAsync(EcoDbContext context)
    {
        // Delete in order of dependencies
        context.Notifications.RemoveRange(context.Notifications);
        context.UserBadges.RemoveRange(context.UserBadges);
        context.UserChallenges.RemoveRange(context.UserChallenges);
        context.Challenges.RemoveRange(context.Challenges);
        context.Trips.RemoveRange(context.Trips);
        context.UserGoals.RemoveRange(context.UserGoals);
        context.Activities.RemoveRange(context.Activities);
        context.DeviceTokens.RemoveRange(context.DeviceTokens);
        context.DailyScores.RemoveRange(context.DailyScores);
        context.WeeklyReports.RemoveRange(context.WeeklyReports);
        context.MonthlyReports.RemoveRange(context.MonthlyReports);
        context.RefreshTokens.RemoveRange(context.RefreshTokens);
        context.PasswordResetTokens.RemoveRange(context.PasswordResetTokens);
        context.EmailVerificationTokens.RemoveRange(context.EmailVerificationTokens);
        context.Users.RemoveRange(context.Users);
        context.Badges.RemoveRange(context.Badges);

        await context.SaveChangesAsync();
    }
}

/// <summary>
/// Extension methods for easier test assertions
/// </summary>
public static class TestExtensions
{
    /// <summary>
    /// Checks if a user has a specific badge
    /// </summary>
    public static async Task<bool> UserHasBadgeAsync(
        EcoDbContext context,
        int userId,
        int badgeId)
    {
        return await context.UserBadges
            .AnyAsync(ub => ub.UserId == userId && ub.BadgeId == badgeId);
    }

    /// <summary>
    /// Gets the most recent notification for a user
    /// </summary>
    public static async Task<EcoBackend.Core.Entities.Notification?> GetLatestNotificationAsync(
        EcoDbContext context,
        int userId)
    {
        return await context.Notifications
            .Where(n => n.UserId == userId)
            .OrderByDescending(n => n.CreatedAt)
            .FirstOrDefaultAsync();
    }

    /// <summary>
    /// Gets all unread notifications for a user
    /// </summary>
    public static async Task<List<EcoBackend.Core.Entities.Notification>> GetUnreadNotificationsAsync(
        EcoDbContext context,
        int userId)
    {
        return await context.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync();
    }

    /// <summary>
    /// Checks if a token has expired
    /// </summary>
    public static bool IsTokenExpired(DateTime createdAt, int expirationSeconds)
    {
        return DateTime.UtcNow > createdAt.AddSeconds(expirationSeconds);
    }
}
