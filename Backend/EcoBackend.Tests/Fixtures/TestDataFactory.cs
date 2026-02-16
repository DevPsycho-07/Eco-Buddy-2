using System;
using System.Collections.Generic;
using EcoBackend.Core.Entities;

namespace EcoBackend.Tests.Fixtures;

/// <summary>
/// Test data factory for creating consistent test objects
/// </summary>
public static class TestDataFactory
{
    private static int _userIdCounter = 1;
    private static int _activityIdCounter = 1;
    private static int _badgeIdCounter = 1;
    private static int _deviceTokenIdCounter = 1;
    private static int _notificationIdCounter = 1;

    public static User CreateTestUser(
        string? username = null,
        string? email = null,
        int ecoScore = 100,
        int currentStreak = 0)
    {
        var userId = _userIdCounter++;
        return new User
        {
            Id = userId,
            UserName = username ?? $"user_{Guid.NewGuid().ToString()[..8]}",
            Email = email ?? $"user_{Guid.NewGuid().ToString()[..8]}@example.com",
            NormalizedEmail = (email ?? $"user_{Guid.NewGuid().ToString()[..8]}@example.com").ToUpper(),
            NormalizedUserName = (username ?? $"user_{Guid.NewGuid().ToString()[..8]}").ToUpper(),
            FirstName = "Test",
            LastName = "User",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("TestPassword123!"),
            EcoScore = ecoScore,
            CurrentStreak = currentStreak,
            EmailConfirmed = true,
            CreatedAt = DateTime.UtcNow
        };
    }

    public static Activity CreateTestActivity(
        int userId,
        int activityTypeId = 1,
        double quantity = 5.0,
        int pointsEarned = 50)
    {
        return new Activity
        {
            Id = _activityIdCounter++,
            UserId = userId,
            ActivityTypeId = activityTypeId,
            Quantity = quantity,
            Unit = "km",
            CO2Impact = 2.5,
            PointsEarned = pointsEarned,
            ActivityDate = DateTime.UtcNow,
            CreatedAt = DateTime.UtcNow
        };
    }

    public static Badge CreateTestBadge(
        string name = "Test Badge",
        string description = "A test badge")
    {
        return new Badge
        {
            Id = _badgeIdCounter++,
            Name = name,
            Description = description,
            Icon = "https://example.com/badge.png"
        };
    }

    public static UserGoal CreateTestGoal(
        int userId,
        string title = "Test Goal")
    {
        return new UserGoal
        {
            Id = _badgeIdCounter++,
            UserId = userId,
            Title = title,
            Description = "Test goal description",
            TargetValue = 100,
            CurrentValue = 50,
            Unit = "km",
            IsCompleted = false,
            Deadline = DateTime.UtcNow.AddDays(30),
            CreatedAt = DateTime.UtcNow
        };
    }

    public static Notification CreateTestNotification(
        int userId,
        string notificationType = "general")
    {
        return new Notification
        {
            Id = _notificationIdCounter++,
            UserId = userId,
            NotificationType = notificationType,
            Title = "Test Notification",
            Body = "Test notification body",
            IsRead = false,
            IsSent = false,
            CreatedAt = DateTime.UtcNow
        };
    }

    public static DailyScore CreateTestDailyScore(
        int userId,
        int points = 50)
    {
        return new DailyScore
        {
            Id = _userIdCounter++,
            UserId = userId,
            Date = DateTime.UtcNow.Date,
            Score = points,
            CO2Saved = 2.5,
            CO2Emitted = 1.0,
            Steps = 5000
        };
    }

    public static RefreshToken CreateRefreshToken(
        int userId,
        bool isExpired = false)
    {
        return new RefreshToken
        {
            Id = _userIdCounter++,
            UserId = userId,
            Token = Guid.NewGuid().ToString(),
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = isExpired ? DateTime.UtcNow.AddDays(-1) : DateTime.UtcNow.AddDays(7),
            IsRevoked = false
        };
    }

    public static PasswordResetToken CreatePasswordResetToken(
        int userId,
        bool isExpired = false)
    {
        return new PasswordResetToken
        {
            Id = _userIdCounter++,
            UserId = userId,
            Token = Guid.NewGuid().ToString().Replace("-", ""),
            CreatedAt = isExpired ? DateTime.UtcNow.AddSeconds(-3601) : DateTime.UtcNow
        };
    }

    public static EmailVerificationToken CreateEmailVerificationToken(
        int userId,
        bool isExpired = false)
    {
        return new EmailVerificationToken
        {
            Id = _userIdCounter++,
            UserId = userId,
            Token = Guid.NewGuid().ToString().Replace("-", ""),
            CreatedAt = isExpired ? DateTime.UtcNow.AddSeconds(-86401) : DateTime.UtcNow
        };
    }

    public static DeviceToken CreateDeviceToken(
        int userId,
        string deviceType = "android")
    {
        return new DeviceToken
        {
            Id = _deviceTokenIdCounter++,
            UserId = userId,
            Token = Guid.NewGuid().ToString(),
            DeviceType = deviceType,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };
    }
}
