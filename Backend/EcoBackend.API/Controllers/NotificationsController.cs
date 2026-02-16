using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using EcoBackend.API.DTOs;
using EcoBackend.API.Services;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly NotificationService _notificationService;
    private readonly ILogger<NotificationsController> _logger;
    
    public NotificationsController(NotificationService notificationService, ILogger<NotificationsController> logger)
    {
        _notificationService = notificationService;
        _logger = logger;
    }
    
    /// <summary>
    /// Register or update FCM device token for push notifications
    /// </summary>
    [HttpPost("device-token")]
    public async Task<IActionResult> RegisterDeviceToken([FromBody] RegisterDeviceTokenDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var deviceToken = await _notificationService.RegisterDeviceTokenAsync(
            userId, 
            dto.DeviceToken, 
            dto.DeviceType);
        
        return Ok(new
        {
            message = "Device token registered successfully",
            deviceToken = new DeviceTokenDto
            {
                Id = deviceToken.Id,
                Token = deviceToken.Token,
                DeviceType = deviceToken.DeviceType,
                IsActive = deviceToken.IsActive,
                CreatedAt = deviceToken.CreatedAt
            }
        });
    }
    
    /// <summary>
    /// Deactivate a device token
    /// </summary>
    [HttpDelete("device-token")]
    public async Task<IActionResult> DeactivateDeviceToken([FromBody] DeactivateDeviceTokenDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var success = await _notificationService.DeactivateDeviceTokenAsync(userId, dto.DeviceToken);
        
        if (!success)
        {
            return NotFound(new { error = "Device token not found" });
        }
        
        return Ok(new { message = "Device token deactivated" });
    }
    
    /// <summary>
    /// Get notifications for the authenticated user
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetNotifications([FromQuery] int page = 1, [FromQuery] int limit = 20)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        if (page < 1) page = 1;
        if (limit < 1 || limit > 100) limit = 20;
        
        var (notifications, total, unread) = await _notificationService.GetUserNotificationsAsync(userId, page, limit);
        
        var pages = (int)Math.Ceiling(total / (double)limit);
        
        var notificationDtos = notifications.Select(n => new NotificationDto
        {
            Id = n.Id,
            Type = n.NotificationType,
            NotificationType = n.NotificationType,
            Title = n.Title,
            Message = n.Body,
            Body = n.Body,
            TargetId = n.TargetId,
            IsRead = n.IsRead,
            IsSent = n.IsSent,
            SentAt = n.SentAt,
            CreatedAt = n.CreatedAt
        }).ToList();
        
        return Ok(new NotificationListResponseDto
        {
            Notifications = notificationDtos,
            Total = total,
            Unread = unread,
            Page = page,
            Limit = limit,
            Pages = pages
        });
    }
    
    /// <summary>
    /// Mark a notification as read
    /// </summary>
    [HttpPost("read")]
    public async Task<IActionResult> MarkAsRead([FromBody] MarkNotificationReadDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var success = await _notificationService.MarkNotificationAsReadAsync(dto.NotificationId, userId);
        
        if (!success)
        {
            return NotFound(new { error = "Notification not found" });
        }
        
        return Ok(new { message = "Notification marked as read" });
    }
    
    /// <summary>
    /// Mark all notifications as read
    /// </summary>
    [HttpPost("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var count = await _notificationService.MarkAllNotificationsAsReadAsync(userId);
        
        return Ok(new { message = $"{count} notifications marked as read" });
    }
    
    /// <summary>
    /// Delete a notification
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteNotification(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var success = await _notificationService.DeleteNotificationAsync(id, userId);
        
        if (!success)
        {
            return NotFound(new { error = "Notification not found" });
        }
        
        return Ok(new { message = "Notification deleted successfully" });
    }
    
    /// <summary>
    /// Send a test notification (development only)
    /// </summary>
    [HttpPost("test")]
    public async Task<IActionResult> SendTestNotification([FromBody] SendTestNotificationDto dto)
    {
        if (!HttpContext.RequestServices.GetRequiredService<IWebHostEnvironment>().IsDevelopment())
        {
            return StatusCode(403, new { error = "This endpoint is only available in development mode" });
        }
        
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        try
        {
            var notification = await _notificationService.CreateNotificationAsync(
                userId,
                dto.Title,
                dto.Body,
                dto.Type,
                dto.TargetId
            );
            
            return Ok(new
            {
                message = "Test notification sent successfully",
                notification = new NotificationDto
                {
                    Id = notification.Id,
                    Type = notification.NotificationType,
                    NotificationType = notification.NotificationType,
                    Title = notification.Title,
                    Message = notification.Body,
                    Body = notification.Body,
                    TargetId = notification.TargetId,
                    IsRead = notification.IsRead,
                    IsSent = notification.IsSent,
                    SentAt = notification.SentAt,
                    CreatedAt = notification.CreatedAt
                }
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send test notification");
            return StatusCode(500, new { error = "Failed to send test notification", details = ex.Message });
        }
    }
}
