using Microsoft.EntityFrameworkCore;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using NotificationEntity = EcoBackend.Core.Entities.Notification;

namespace EcoBackend.API.Services;

/// <summary>
/// Service for managing notifications and sending push notifications via FCM
/// </summary>
public class NotificationService
{
    private readonly EcoDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly ILogger<NotificationService> _logger;
    private static bool _firebaseInitialized = false;
    private static readonly object _lockObject = new object();
    
    public NotificationService(
        EcoDbContext context, 
        IConfiguration configuration, 
        ILogger<NotificationService> logger)
    {
        _context = context;
        _configuration = configuration;
        _logger = logger;
        InitializeFirebase();
    }
    
    /// <summary>
    /// Initialize Firebase Admin SDK
    /// </summary>
    private void InitializeFirebase()
    {
        if (_firebaseInitialized) return;
        
        lock (_lockObject)
        {
            if (_firebaseInitialized) return;
            
            try
            {
                var credentialPath = _configuration["Firebase:CredentialPath"];
                
                if (string.IsNullOrEmpty(credentialPath))
                {
                    _logger.LogWarning("Firebase credentials not configured. Push notifications will be disabled.");
                    return;
                }
                
                if (!File.Exists(credentialPath))
                {
                    _logger.LogWarning("Firebase credential file not found at {Path}. Push notifications will be disabled.", credentialPath);
                    return;
                }
                
                if (FirebaseApp.DefaultInstance == null)
                {
                    FirebaseApp.Create(new AppOptions
                    {
                        Credential = GoogleCredential.FromFile(credentialPath)
                    });
                    
                    _firebaseInitialized = true;
                    _logger.LogInformation("Firebase Admin SDK initialized successfully");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to initialize Firebase Admin SDK");
            }
        }
    }
    
    /// <summary>
    /// Register or update device token for a user
    /// </summary>
    public async Task<DeviceToken> RegisterDeviceTokenAsync(int userId, string token, string deviceType = "mobile")
    {
        var existingToken = await _context.DeviceTokens
            .FirstOrDefaultAsync(dt => dt.UserId == userId && dt.Token == token);
        
        if (existingToken != null)
        {
            existingToken.DeviceType = deviceType;
            existingToken.IsActive = true;
            existingToken.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            return existingToken;
        }
        
        var deviceToken = new DeviceToken
        {
            UserId = userId,
            Token = token,
            DeviceType = deviceType,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        
        _context.DeviceTokens.Add(deviceToken);
        await _context.SaveChangesAsync();
        return deviceToken;
    }
    
    /// <summary>
    /// Deactivate a device token
    /// </summary>
    public async Task<bool> DeactivateDeviceTokenAsync(int userId, string token)
    {
        var deviceToken = await _context.DeviceTokens
            .FirstOrDefaultAsync(dt => dt.UserId == userId && dt.Token == token);
        
        if (deviceToken == null) return false;
        
        deviceToken.IsActive = false;
        deviceToken.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return true;
    }
    
    /// <summary>
    /// Create a notification in the database
    /// </summary>
    public async Task<NotificationEntity> CreateNotificationAsync(
        int userId,
        string title,
        string body,
        string notificationType = "general",
        int? targetId = null)
    {
        var notification = new NotificationEntity
        {
            UserId = userId,
            Title = title,
            Body = body,
            NotificationType = notificationType,
            TargetId = targetId,
            IsRead = false,
            IsSent = false,
            CreatedAt = DateTime.UtcNow
        };
        
        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();
        
        // Automatically send push notification
        await SendNotificationToUserAsync(userId, notification);
        
        return notification;
    }
    
    /// <summary>
    /// Send push notification to a user's devices
    /// </summary>
    public async Task<bool> SendNotificationToUserAsync(int userId, NotificationEntity notification)
    {
        if (!_firebaseInitialized)
        {
            _logger.LogWarning("Firebase not initialized. Skipping push notification.");
            return false;
        }
        
        try
        {
            // Get active device tokens for user
            var deviceTokens = await _context.DeviceTokens
                .Where(dt => dt.UserId == userId && dt.IsActive)
                .Select(dt => dt.Token)
                .ToListAsync();
            
            if (deviceTokens.Count == 0)
            {
                _logger.LogInformation("No active device tokens for user {UserId}", userId);
                return false;
            }
            
            // Prepare FCM message
            var message = new MulticastMessage
            {
                Tokens = deviceTokens,
                Notification = new FirebaseAdmin.Messaging.Notification
                {
                    Title = notification.Title,
                    Body = notification.Body
                },
                Data = new Dictionary<string, string>
                {
                    { "type", notification.NotificationType },
                    { "target_id", notification.TargetId?.ToString() ?? "" },
                    { "notification_id", notification.Id.ToString() },
                    { "action", "refresh_notifications" }
                }
            };
            
            // Send multicast message
            var response = await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(message);
            
            _logger.LogInformation(
                "Successfully sent {SuccessCount} out of {TotalCount} messages for notification {NotificationId}",
                response.SuccessCount, deviceTokens.Count, notification.Id);
            
            // Update notification status
            notification.IsSent = true;
            notification.SentAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            
            // Clean up invalid tokens
            if (response.FailureCount > 0)
            {
                await CleanupInvalidTokensAsync(response, deviceTokens);
            }
            
            return response.SuccessCount > 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send push notification for notification {NotificationId}", notification.Id);
            return false;
        }
    }
    
    /// <summary>
    /// Send achievement notification
    /// </summary>
    public async Task SendAchievementNotificationAsync(int userId, string achievementTitle, int? achievementId = null)
    {
        await CreateNotificationAsync(
            userId,
            "🎉 Achievement Unlocked!",
            achievementTitle,
            "achievement",
            achievementId
        );
    }
    
    /// <summary>
    /// Send badge notification
    /// </summary>
    public async Task SendBadgeNotificationAsync(int userId, string badgeTitle, int? badgeId = null)
    {
        await CreateNotificationAsync(
            userId,
            "🏅 Badge Earned!",
            badgeTitle,
            "badge",
            badgeId
        );
    }
    
    /// <summary>
    /// Send challenge notification
    /// </summary>
    public async Task SendChallengeNotificationAsync(int userId, string message, int? challengeId = null)
    {
        await CreateNotificationAsync(
            userId,
            "🎯 Challenge Update",
            message,
            "challenge",
            challengeId
        );
    }
    
    /// <summary>
    /// Send streak milestone notification
    /// </summary>
    public async Task SendStreakNotificationAsync(int userId, int streakDays)
    {
        await CreateNotificationAsync(
            userId,
            "🔥 Streak Milestone!",
            $"Amazing! You've maintained a {streakDays}-day streak!",
            "streak",
            streakDays
        );
    }
    
    /// <summary>
    /// Get notifications for a user with pagination
    /// </summary>
    public async Task<(List<NotificationEntity> notifications, int total, int unread)> GetUserNotificationsAsync(
        int userId, 
        int page = 1, 
        int limit = 20)
    {
        var query = _context.Notifications.Where(n => n.UserId == userId);
        
        var total = await query.CountAsync();
        var unread = await query.Where(n => !n.IsRead).CountAsync();
        
        var notifications = await query
            .OrderByDescending(n => n.CreatedAt)
            .Skip((page - 1) * limit)
            .Take(limit)
            .ToListAsync();
        
        return (notifications, total, unread);
    }
    
    /// <summary>
    /// Mark notification as read
    /// </summary>
    public async Task<bool> MarkNotificationAsReadAsync(int notificationId, int userId)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId);
        
        if (notification == null) return false;
        
        notification.IsRead = true;
        await _context.SaveChangesAsync();
        return true;
    }
    
    /// <summary>
    /// Mark all notifications as read for a user
    /// </summary>
    public async Task<int> MarkAllNotificationsAsReadAsync(int userId)
    {
        var notifications = await _context.Notifications
            .Where(n => n.UserId == userId && !n.IsRead)
            .ToListAsync();
        
        foreach (var n in notifications)
            n.IsRead = true;
        
        await _context.SaveChangesAsync();
        return notifications.Count;
    }
    
    /// <summary>
    /// Delete notification
    /// </summary>
    public async Task<bool> DeleteNotificationAsync(int notificationId, int userId)
    {
        var notification = await _context.Notifications
            .FirstOrDefaultAsync(n => n.Id == notificationId && n.UserId == userId);
        
        if (notification == null) return false;
        
        _context.Notifications.Remove(notification);
        await _context.SaveChangesAsync();
        return true;
    }
    
    /// <summary>
    /// Clean up invalid FCM tokens
    /// </summary>
    private async Task CleanupInvalidTokensAsync(BatchResponse response, List<string> tokens)
    {
        var invalidTokens = new List<string>();
        
        for (int i = 0; i < response.Responses.Count; i++)
        {
            var sendResponse = response.Responses[i];
            if (!sendResponse.IsSuccess && sendResponse.Exception != null)
            {
                var errorCode = sendResponse.Exception.MessagingErrorCode;
                if (errorCode == MessagingErrorCode.InvalidArgument ||
                    errorCode == MessagingErrorCode.Unregistered)
                {
                    invalidTokens.Add(tokens[i]);
                }
            }
        }
        
        if (invalidTokens.Any())
        {
            await _context.DeviceTokens
                .Where(dt => invalidTokens.Contains(dt.Token))
                .ExecuteUpdateAsync(setters => setters.SetProperty(dt => dt.IsActive, false));
            
            _logger.LogInformation("Deactivated {Count} invalid device tokens", invalidTokens.Count);
        }
    }
}
