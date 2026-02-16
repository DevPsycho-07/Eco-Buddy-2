namespace EcoBackend.API.DTOs;

public class DeviceTokenDto
{
    public int Id { get; set; }
    public required string Token { get; set; }
    public string DeviceType { get; set; } = "mobile";
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class RegisterDeviceTokenDto
{
    public required string DeviceToken { get; set; }
    public string DeviceType { get; set; } = "mobile"; // mobile, web, tablet
}

public class DeactivateDeviceTokenDto
{
    public required string DeviceToken { get; set; }
}

public class NotificationDto
{
    public int Id { get; set; }
    public string Type { get; set; } = string.Empty;
    public string NotificationType { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public int? TargetId { get; set; }
    public bool IsRead { get; set; }
    public bool IsSent { get; set; }
    public DateTime? SentAt { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class NotificationListResponseDto
{
    public List<NotificationDto> Notifications { get; set; } = new();
    public int Total { get; set; }
    public int Unread { get; set; }
    public int Page { get; set; }
    public int Limit { get; set; }
    public int Pages { get; set; }
}

public class MarkNotificationReadDto
{
    public int NotificationId { get; set; }
}

public class SendTestNotificationDto
{
    public string Type { get; set; } = "general";
    public string Title { get; set; } = "Test Notification";
    public string Body { get; set; } = "This is a test notification";
    public int? TargetId { get; set; }
}
