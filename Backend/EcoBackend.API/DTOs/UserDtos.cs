namespace EcoBackend.API.DTOs;

public class UserRegistrationDto
{
    public required string Email { get; set; }
    public required string Username { get; set; }
    public required string Password { get; set; }
    public string? FullName { get; set; }
}

public class LoginDto
{
    public required string Email { get; set; }
    public required string Password { get; set; }
}

public class RefreshTokenDto
{
    public required string RefreshToken { get; set; }
}

public class LogoutDto
{
    public string? RefreshToken { get; set; }
}

public class UserDto
{
    public int Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? ProfilePicture { get; set; }
    public string Bio { get; set; } = string.Empty;
    public int EcoScore { get; set; }
    public double TotalCO2Saved { get; set; }
    public int CurrentStreak { get; set; }
    public int LongestStreak { get; set; }
    public int Level { get; set; }
    public int ExperiencePoints { get; set; }
    public string Units { get; set; } = "metric";
    public bool NotificationsEnabled { get; set; }
    public bool DarkMode { get; set; }
    public bool EmailVerified { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class AuthResponseDto
{
    public required UserDto User { get; set; }
    public required string AccessToken { get; set; }
    public required string RefreshToken { get; set; }
}

public class UserProfileUpdateDto
{
    public string? FirstName { get; set; }
    public string? LastName { get; set; }
    public string? Username { get; set; }
    public string? Bio { get; set; }
    public string? ProfilePicture { get; set; }
    public string? Units { get; set; }
    public bool? DarkMode { get; set; }
}

public class UserPrivacySettingsDto
{
    public bool LocationTracking { get; set; }
    public bool ActivityRecognition { get; set; }
    public bool HealthDataSync { get; set; }
    public bool CalendarAccess { get; set; }
}

public class NotificationSettingsDto
{
    public bool NotificationsEnabled { get; set; }
}

public class LeaderboardDto
{
    public int Rank { get; set; }
    public UserDto User { get; set; } = null!;
}

public class ForgotPasswordDto
{
    public required string Email { get; set; }
}

public class ResetPasswordDto
{
    public required string Email { get; set; }
    public required string Token { get; set; }
    public required string NewPassword { get; set; }
    public required string NewPasswordConfirm { get; set; }
}

public class VerifyEmailDto
{
    public required string Email { get; set; }
    public required string Token { get; set; }
}

public class ResendVerificationEmailDto
{
    public required string Email { get; set; }
}
