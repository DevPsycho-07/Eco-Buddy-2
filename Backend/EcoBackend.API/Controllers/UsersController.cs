using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using EcoBackend.API.DTOs;
using EcoBackend.API.Services;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly UserService _userService;
    private readonly GoalService _goalService;
    private readonly DailyScoreService _dailyScoreService;
    private readonly NotificationService _notificationService;

    public UsersController(
        UserService userService,
        GoalService goalService,
        DailyScoreService dailyScoreService,
        NotificationService notificationService)
    {
        _userService = userService;
        _goalService = goalService;
        _dailyScoreService = dailyScoreService;
        _notificationService = notificationService;
    }

    // ========== Auth ==========

    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<IActionResult> Register([FromBody] UserRegistrationDto dto)
    {
        var (response, errors) = await _userService.RegisterAsync(dto);
        if (errors != null) return BadRequest(new { errors });
        return Ok(response);
    }

    [HttpGet("check-username/{username}")]
    [AllowAnonymous]
    public async Task<IActionResult> CheckUsername(string username)
    {
        var exists = await _userService.CheckUsernameExistsAsync(username);
        return Ok(new { exists });
    }

    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var result = await _userService.LoginAsync(dto);
        if (result == null) return Unauthorized(new { error = "Invalid email or password" });
        return Ok(result);
    }

    [HttpPost("token/refresh")]
    [AllowAnonymous]
    public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenDto dto)
    {
        if (string.IsNullOrEmpty(dto.RefreshToken))
            return BadRequest(new { error = "Refresh token is required" });

        var result = await _userService.RefreshTokenAsync(dto.RefreshToken);
        if (result != null) return Ok(result);

        var error = await _userService.GetRefreshTokenErrorAsync(dto.RefreshToken);
        return Unauthorized(new { error = error ?? "Invalid refresh token" });
    }

    [HttpPost("logout")]
    [Authorize]
    public async Task<IActionResult> Logout([FromBody] LogoutDto? dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await _userService.LogoutAsync(userId, dto?.RefreshToken);
        return Ok(new { message = "Successfully logged out" });
    }

    // ========== Profile ==========

    [HttpGet("profile")]
    [Authorize]
    public async Task<IActionResult> GetProfile()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var profile = await _userService.GetProfileAsync(userId);
        if (profile == null) return NotFound();
        return Ok(profile);
    }

    [HttpPut("profile")]
    [Authorize]
    public async Task<IActionResult> UpdateProfile([FromBody] UserProfileUpdateDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var profile = await _userService.UpdateProfileAsync(userId, dto);
        if (profile == null) return NotFound();
        return Ok(profile);
    }

    // ========== Profile Picture ==========

    [HttpPost("upload-picture")]
    [Authorize]
    public async Task<IActionResult> UploadProfilePicture(IFormFile profile_picture)
    {
        if (profile_picture == null || profile_picture.Length == 0)
            return BadRequest(new { error = "No file provided" });

        var allowedTypes = new[] { "image/jpeg", "image/png", "image/jpg", "image/webp" };
        if (!allowedTypes.Contains(profile_picture.ContentType.ToLower()))
            return BadRequest(new { error = "Invalid file type. Only jpeg, png, and webp are allowed." });

        if (profile_picture.Length > 5 * 1024 * 1024)
            return BadRequest(new { error = "File size exceeds 5MB limit." });

        try
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
            var result = await _userService.UploadProfilePictureAsync(userId, profile_picture);
            if (result == null) return NotFound();
            return Ok(new { profilePicture = result });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = $"Failed to upload file: {ex.Message}" });
        }
    }

    [HttpGet("profile-picture")]
    [Authorize]
    public async Task<IActionResult> GetOwnProfilePicture()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var result = await _userService.GetProfilePictureAsync(userId);
        if (result == null) return NotFound(new { error = "Profile picture not found" });
        var (data, contentType, cacheControl) = result.Value;
        if (data == null) return NotFound(new { error = "Profile picture not found" });
        Response.Headers["Cache-Control"] = cacheControl;
        return File(data, contentType);
    }

    [HttpGet("profile-picture/{userId}")]
    [Authorize]
    public async Task<IActionResult> GetUserProfilePicture(int userId)
    {
        var result = await _userService.GetProfilePictureByUserIdAsync(userId);
        if (result == null) return NotFound();
        var (data, contentType, cacheControl) = result.Value;
        if (data == null) return NotFound(new { error = "Profile picture not found" });
        Response.Headers["Cache-Control"] = cacheControl;
        return File(data, contentType);
    }

    [HttpDelete("profile-picture")]
    [Authorize]
    public async Task<IActionResult> DeleteProfilePicture()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var deleted = await _userService.DeleteProfilePictureAsync(userId);
        if (!deleted) return NotFound();
        return Ok(new { message = "Profile picture deleted successfully" });
    }

    // ========== Settings ==========

    [HttpGet("privacy-settings")]
    [Authorize]
    public async Task<IActionResult> GetPrivacySettings()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var settings = await _userService.GetPrivacySettingsAsync(userId);
        if (settings == null) return NotFound();
        return Ok(settings);
    }

    [HttpPut("privacy-settings")]
    [Authorize]
    public async Task<IActionResult> UpdatePrivacySettings([FromBody] UserPrivacySettingsDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var settings = await _userService.UpdatePrivacySettingsAsync(userId, dto);
        if (settings == null) return NotFound();
        return Ok(settings);
    }

    [HttpPatch("privacy-settings")]
    [Authorize]
    public async Task<IActionResult> PatchPrivacySettings([FromBody] UserPrivacySettingsDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var settings = await _userService.UpdatePrivacySettingsAsync(userId, dto);
        if (settings == null) return NotFound();
        return Ok(settings);
    }

    [HttpGet("notification-settings")]
    [Authorize]
    public async Task<IActionResult> GetNotificationSettings()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var settings = await _userService.GetNotificationSettingsAsync(userId);
        if (settings == null) return NotFound();
        return Ok(settings);
    }

    [HttpPut("notification-settings")]
    [Authorize]
    public async Task<IActionResult> UpdateNotificationSettings([FromBody] NotificationSettingsDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var settings = await _userService.UpdateNotificationSettingsAsync(userId, dto);
        if (settings == null) return NotFound();
        return Ok(settings);
    }

    [HttpPatch("notification-settings")]
    [Authorize]
    public async Task<IActionResult> PatchNotificationSettings([FromBody] NotificationSettingsDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)!;
        var settings = await _userService.UpdateNotificationSettingsAsync(userId, dto);
        if (settings == null) return NotFound();
        return Ok(settings);
    }

    // ========== Data Export ==========

    [HttpGet("export-data")]
    [Authorize]
    public async Task<IActionResult> ExportData()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var exportData = await _userService.ExportDataAsync(userId);
        if (exportData == null) return NotFound();
        return Ok(exportData);
    }

    // ========== Leaderboard ==========

    [HttpGet("rank")]
    [Authorize]
    public async Task<IActionResult> GetTopRankedUsers([FromQuery] int limit = 10)
    {
        var leaderboard = await _userService.GetLeaderboardAsync(limit);
        return Ok(leaderboard);
    }

    [HttpGet("leaderboard")]
    [Authorize]
    public async Task<IActionResult> GetLeaderboard([FromQuery] int limit = 10)
    {
        var leaderboard = await _userService.GetLeaderboardAsync(limit);
        return Ok(leaderboard);
    }

    [HttpGet("my-rank")]
    [Authorize]
    public async Task<IActionResult> GetMyRank()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var result = await _userService.GetMyRankAsync(userId);
        if (result == null) return NotFound(new { error = "User not found" });
        return Ok(result);
    }

    // ========== Goals ==========

    [HttpGet("goals")]
    [Authorize]
    public async Task<IActionResult> GetGoals()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var goals = await _goalService.GetGoalsAsync(userId);
        return Ok(goals);
    }

    [HttpPost("goals")]
    [Authorize]
    public async Task<IActionResult> CreateGoal([FromBody] CreateUserGoalDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var goal = await _goalService.CreateGoalAsync(userId, dto);
        return CreatedAtAction(nameof(GetGoals), new { id = goal.Id }, goal);
    }

    [HttpPut("goals/{id}")]
    [Authorize]
    public async Task<IActionResult> UpdateGoal(int id, [FromBody] UpdateUserGoalDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var goal = await _goalService.UpdateGoalAsync(id, userId, dto);
        if (goal == null) return NotFound(new { error = "Goal not found" });
        return Ok(goal);
    }

    [HttpDelete("goals/{id}")]
    [Authorize]
    public async Task<IActionResult> DeleteGoal(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var deleted = await _goalService.DeleteGoalAsync(id, userId);
        if (!deleted) return NotFound(new { error = "Goal not found" });
        return Ok(new { message = "Goal deleted successfully" });
    }

    [HttpPatch("goals/{id}")]
    [Authorize]
    public async Task<IActionResult> PatchGoal(int id, [FromBody] UpdateUserGoalDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var goal = await _goalService.UpdateGoalAsync(id, userId, dto);
        if (goal == null) return NotFound(new { error = "Goal not found" });
        return Ok(goal);
    }

    // ========== Daily Scores ==========

    [HttpGet("daily-scores")]
    [Authorize]
    public async Task<IActionResult> GetDailyScores([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var scores = await _dailyScoreService.GetDailyScoresAsync(userId, startDate, endDate);
        return Ok(scores);
    }

    [HttpGet("daily-scores/{date}")]
    [Authorize]
    public async Task<IActionResult> GetDailyScoreByDate(DateTime date)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var score = await _dailyScoreService.GetDailyScoreByDateAsync(userId, date);
        if (score == null) return NotFound(new { error = "Daily score not found for the specified date" });
        return Ok(score);
    }

    [HttpPost("daily-scores")]
    [Authorize]
    public async Task<IActionResult> CreateOrUpdateDailyScore([FromBody] CreateDailyScoreDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var score = await _dailyScoreService.CreateOrUpdateDailyScoreAsync(userId, dto);
        return Ok(score);
    }

    [HttpPut("daily-scores/{date}")]
    [Authorize]
    public async Task<IActionResult> UpdateDailyScore(DateTime date, [FromBody] UpdateDailyScoreDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var score = await _dailyScoreService.UpdateDailyScoreAsync(userId, date, dto);
        if (score == null) return NotFound(new { error = "Daily score not found for the specified date" });
        return Ok(score);
    }

    [HttpDelete("daily-scores/{date}")]
    [Authorize]
    public async Task<IActionResult> DeleteDailyScore(DateTime date)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var deleted = await _dailyScoreService.DeleteDailyScoreAsync(userId, date);
        if (!deleted) return NotFound(new { error = "Daily score not found for the specified date" });
        return Ok(new { message = "Daily score deleted successfully" });
    }

    // ========== Dashboard ==========

    [HttpGet("dashboard")]
    [Authorize]
    public async Task<IActionResult> GetDashboard()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var dashboard = await _userService.GetDashboardAsync(userId);
        if (dashboard == null) return NotFound(new { error = "User not found" });
        return Ok(dashboard);
    }

    // ========== Notifications ==========

    [HttpPost("register-device-token")]
    [Authorize]
    public async Task<IActionResult> RegisterDeviceToken([FromBody] RegisterDeviceTokenDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var deviceToken = await _notificationService.RegisterDeviceTokenAsync(userId, dto.DeviceToken, dto.DeviceType);
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

    [HttpDelete("register-device-token")]
    [Authorize]
    public async Task<IActionResult> DeactivateDeviceToken([FromBody] RegisterDeviceTokenDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var success = await _notificationService.DeactivateDeviceTokenAsync(userId, dto.DeviceToken);
        if (success) return Ok(new { message = "Device token deactivated successfully" });
        return NotFound(new { error = "Device token not found" });
    }

    [HttpGet("notifications")]
    [Authorize]
    public async Task<IActionResult> GetNotifications([FromQuery] int page = 1, [FromQuery] int limit = 20)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        if (page < 1) page = 1;
        if (limit < 1 || limit > 100) limit = 20;

        var (notifications, total, unread) = await _notificationService.GetUserNotificationsAsync(userId, page, limit);
        var notificationDtos = notifications.Select(n => new NotificationDto
        {
            Id = n.Id,
            Type = n.NotificationType,
            Title = n.Title,
            Message = n.Body,
            IsRead = n.IsRead,
            CreatedAt = n.CreatedAt
        }).ToList();

        return Ok(notificationDtos);
    }

    [HttpGet("notifications/unread-count")]
    [Authorize]
    public async Task<IActionResult> GetUnreadCount()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var (_, _, unread) = await _notificationService.GetUserNotificationsAsync(userId, 1, 1);
        return Ok(new { count = unread });
    }

    [HttpPost("notifications/{notificationId}/mark-as-read")]
    [Authorize]
    public async Task<IActionResult> MarkNotificationAsRead(int notificationId)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var success = await _notificationService.MarkNotificationAsReadAsync(notificationId, userId);
        if (!success) return NotFound(new { error = "Notification not found" });
        return Ok(new { message = "Notification marked as read" });
    }

    [HttpPost("notifications/mark-all-as-read")]
    [Authorize]
    public async Task<IActionResult> MarkAllNotificationsAsRead()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await _notificationService.MarkAllNotificationsAsReadAsync(userId);
        return Ok(new { message = "All notifications marked as read" });
    }

    [HttpDelete("notifications/delete-read")]
    [Authorize]
    public async Task<IActionResult> DeleteReadNotifications()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var (allNotifications, _, _) = await _notificationService.GetUserNotificationsAsync(userId, 1, 1000);
        var readNotifications = allNotifications.Where(n => n.IsRead).ToList();

        foreach (var notification in readNotifications)
        {
            await _notificationService.DeleteNotificationAsync(notification.Id, userId);
        }

        return Ok(new { message = $"Deleted {readNotifications.Count} read notifications" });
    }

    [HttpDelete("notifications/{notificationId}")]
    [Authorize]
    public async Task<IActionResult> DeleteNotification(int notificationId)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var success = await _notificationService.DeleteNotificationAsync(notificationId, userId);
        if (!success) return NotFound(new { error = "Notification not found" });
        return Ok(new { message = "Notification deleted" });
    }

    // ========== Password & Email Verification ==========

    [HttpPost("forgot-password")]
    [AllowAnonymous]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordDto dto)
    {
        var success = await _userService.ForgotPasswordAsync(dto.Email);
        if (success)
            return Ok(new { message = "If an account with that email exists, a password reset link has been sent." });
        return StatusCode(500, new { error = "Failed to send password reset email. Please try again later." });
    }

    [HttpPost("reset-password")]
    [AllowAnonymous]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordDto dto)
    {
        var (success, error) = await _userService.ResetPasswordAsync(dto);
        if (success)
            return Ok(new { message = "Password reset successfully. You can now log in with your new password." });
        return BadRequest(new { error });
    }

    [HttpPost("verify-email")]
    [AllowAnonymous]
    public async Task<IActionResult> VerifyEmail([FromBody] VerifyEmailDto dto)
    {
        var success = await _userService.VerifyEmailAsync(dto.Email, dto.Token);
        if (success)
            return Ok(new { message = "Email verified successfully! Your account is now active." });
        return BadRequest(new { error = "Invalid or expired verification token." });
    }

    [HttpPost("resend-verification-email")]
    [AllowAnonymous]
    public async Task<IActionResult> ResendVerificationEmail([FromBody] ResendVerificationEmailDto dto)
    {
        var (success, error) = await _userService.ResendVerificationEmailAsync(dto.Email);
        if (success)
            return Ok(new { message = "Verification email sent successfully. Check your inbox." });
        if (error != null)
            return BadRequest(new { error });
        return StatusCode(500, new { error = "Failed to send verification email. Please try again later." });
    }
}
