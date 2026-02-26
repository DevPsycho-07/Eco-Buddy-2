using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using UserEntity = EcoBackend.Core.Entities.User;

namespace EcoBackend.API.Services;

public class UserService
{
    private readonly UserManager<User> _userManager;
    private readonly SignInManager<User> _signInManager;
    private readonly IConfiguration _configuration;
    private readonly ProfilePictureEncryptionService _encryptionService;
    private readonly EmailService _emailService;
    private readonly NotificationService _notificationService;
    private readonly EcoDbContext _context;

    public UserService(
        UserManager<User> userManager,
        SignInManager<User> signInManager,
        IConfiguration configuration,
        ProfilePictureEncryptionService encryptionService,
        EmailService emailService,
        NotificationService notificationService,
        EcoDbContext context)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _configuration = configuration;
        _encryptionService = encryptionService;
        _emailService = emailService;
        _notificationService = notificationService;
        _context = context;
    }

    // ========== Auth ==========

    public async Task<(AuthResponseDto? Response, IEnumerable<string>? Errors)> RegisterAsync(UserRegistrationDto dto)
    {
        var firstName = string.Empty;
        var lastName = string.Empty;

        if (!string.IsNullOrWhiteSpace(dto.FullName))
        {
            var nameParts = dto.FullName.Trim().Split(' ', 2);
            firstName = nameParts[0];
            lastName = nameParts.Length > 1 ? nameParts[1] : string.Empty;
        }

        var user = new User
        {
            Email = dto.Email,
            UserName = dto.Username,
            NormalizedEmail = dto.Email.ToUpper(),
            NormalizedUserName = dto.Username.ToUpper(),
            FirstName = firstName,
            LastName = lastName,
            ProfilePicture = UserEntity.DefaultProfilePicture
        };

        var result = await _userManager.CreateAsync(user, dto.Password);

        if (!result.Succeeded)
        {
            return (null, result.Errors.Select(e => e.Description));
        }

        var tokens = await GenerateTokensAsync(user);

        return (new AuthResponseDto
        {
            User = MapToUserDto(user),
            Access = tokens.AccessToken,
            Refresh = tokens.RefreshToken,
            EmailVerified = user.EmailConfirmed
        }, null);
    }

    public async Task<bool> CheckUsernameExistsAsync(string username)
    {
        return await _userManager.Users.AnyAsync(u => u.UserName == username);
    }

    public async Task<AuthResponseDto?> LoginAsync(LoginDto dto)
    {
        var user = await _userManager.FindByEmailAsync(dto.Email);

        if (user == null) return null;

        var result = await _signInManager.CheckPasswordSignInAsync(user, dto.Password, false);

        if (!result.Succeeded) return null;

        var tokens = await GenerateTokensAsync(user);

        return new AuthResponseDto
        {
            User = MapToUserDto(user),
            Access = tokens.AccessToken,
            Refresh = tokens.RefreshToken,
            EmailVerified = user.EmailConfirmed
        };
    }

    public async Task<AuthResponseDto?> RefreshTokenAsync(string refreshToken)
    {
        var storedToken = await _context.RefreshTokens
            .Include(rt => rt.User)
            .FirstOrDefaultAsync(rt => rt.Token == refreshToken);

        if (storedToken == null || !storedToken.IsValid)
            return null;

        storedToken.IsRevoked = true;
        storedToken.RevokedAt = DateTime.UtcNow;

        var newTokens = await GenerateTokensAsync(storedToken.User);

        storedToken.ReplacedByToken = newTokens.RefreshToken;
        await _context.SaveChangesAsync();

        return new AuthResponseDto
        {
            User = MapToUserDto(storedToken.User),
            Access = newTokens.AccessToken,
            Refresh = newTokens.RefreshToken,
            EmailVerified = storedToken.User.EmailConfirmed
        };
    }

    public async Task<string?> GetRefreshTokenErrorAsync(string refreshToken)
    {
        var storedToken = await _context.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.Token == refreshToken);

        if (storedToken == null) return "Invalid refresh token";
        if (storedToken.IsExpired) return "Refresh token expired";
        if (storedToken.IsRevoked) return "Refresh token revoked";
        return null;
    }

    public async Task LogoutAsync(int userId, string? refreshToken)
    {
        if (refreshToken != null)
        {
            var token = await _context.RefreshTokens
                .FirstOrDefaultAsync(rt => rt.Token == refreshToken && rt.UserId == userId);

            if (token != null && !token.IsRevoked)
            {
                token.IsRevoked = true;
                token.RevokedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
            }
        }
        else
        {
            var activeTokens = await _context.RefreshTokens
                .Where(rt => rt.UserId == userId && !rt.IsRevoked)
                .ToListAsync();

            foreach (var token in activeTokens)
            {
                token.IsRevoked = true;
                token.RevokedAt = DateTime.UtcNow;
            }

            if (activeTokens.Any())
                await _context.SaveChangesAsync();
        }
    }

    // ========== Profile ==========

    public async Task<UserDto?> GetProfileAsync(string userId)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return null;
        return MapToUserDto(user);
    }

    public async Task<UserDto?> UpdateProfileAsync(string userId, UserProfileUpdateDto dto)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return null;

        if (!string.IsNullOrEmpty(dto.FirstName)) user.FirstName = dto.FirstName;
        if (!string.IsNullOrEmpty(dto.LastName)) user.LastName = dto.LastName;
        if (!string.IsNullOrEmpty(dto.Username)) user.UserName = dto.Username;
        if (!string.IsNullOrEmpty(dto.Bio)) user.Bio = dto.Bio;
        if (dto.ProfilePicture != null) user.ProfilePicture = dto.ProfilePicture;
        if (!string.IsNullOrEmpty(dto.Units)) user.Units = dto.Units;
        if (dto.DarkMode.HasValue) user.DarkMode = dto.DarkMode.Value;

        user.UpdatedAt = DateTime.UtcNow;
        await _userManager.UpdateAsync(user);

        return MapToUserDto(user);
    }

    // ========== Profile Picture ==========

    public async Task<string?> UploadProfilePictureAsync(string userId, IFormFile profilePicture)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return null;

        // Delete old encrypted profile picture if exists
        if (!string.IsNullOrEmpty(user.ProfilePicture))
        {
            var oldFilePath = Path.Combine(_encryptionService.GetMediaPath(),
                Path.GetFileName(user.ProfilePicture));
            if (File.Exists(oldFilePath))
                File.Delete(oldFilePath);
        }

        using var memoryStream = new MemoryStream();
        await profilePicture.CopyToAsync(memoryStream);
        var fileContent = memoryStream.ToArray();

        var secureFilename = await _encryptionService.SaveEncryptedFileAsync(
            fileContent, user.Id, profilePicture.FileName);

        user.ProfilePicture = secureFilename;
        user.UpdatedAt = DateTime.UtcNow;
        await _userManager.UpdateAsync(user);

        return $"/api/users/profile-picture/{user.Id}";
    }

    public async Task<(byte[]? Data, string ContentType, string CacheControl)?> GetProfilePictureAsync(string userId)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return null;

        return await GetProfilePictureForUserAsync(user);
    }

    public async Task<(byte[]? Data, string ContentType, string CacheControl)?> GetProfilePictureByUserIdAsync(int userId)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return null;

        return await GetProfilePictureForUserAsync(user);
    }

    public async Task<bool> DeleteProfilePictureAsync(string userId)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return false;

        if (!string.IsNullOrEmpty(user.ProfilePicture) && user.ProfilePicture != UserEntity.DefaultProfilePicture)
        {
            var filePath = Path.Combine(_encryptionService.GetMediaPath(),
                Path.GetFileName(user.ProfilePicture));
            if (File.Exists(filePath))
                File.Delete(filePath);
        }

        user.ProfilePicture = UserEntity.DefaultProfilePicture;
        user.UpdatedAt = DateTime.UtcNow;
        await _userManager.UpdateAsync(user);

        return true;
    }

    // ========== Settings ==========

    public async Task<UserPrivacySettingsDto?> GetPrivacySettingsAsync(string userId)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return null;

        return new UserPrivacySettingsDto
        {
            LocationTracking = user.LocationTracking,
            ActivityRecognition = user.ActivityRecognition,
            HealthDataSync = user.HealthDataSync,
            CalendarAccess = user.CalendarAccess
        };
    }

    public async Task<UserPrivacySettingsDto?> UpdatePrivacySettingsAsync(string userId, UserPrivacySettingsDto dto)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return null;

        user.LocationTracking = dto.LocationTracking;
        user.ActivityRecognition = dto.ActivityRecognition;
        user.HealthDataSync = dto.HealthDataSync;
        user.CalendarAccess = dto.CalendarAccess;
        user.UpdatedAt = DateTime.UtcNow;

        await _userManager.UpdateAsync(user);

        return new UserPrivacySettingsDto
        {
            LocationTracking = user.LocationTracking,
            ActivityRecognition = user.ActivityRecognition,
            HealthDataSync = user.HealthDataSync,
            CalendarAccess = user.CalendarAccess
        };
    }

    public async Task<NotificationSettingsDto?> GetNotificationSettingsAsync(string userId)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return null;

        return new NotificationSettingsDto
        {
            NotificationsEnabled = user.NotificationsEnabled
        };
    }

    public async Task<NotificationSettingsDto?> UpdateNotificationSettingsAsync(string userId, NotificationSettingsDto dto)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return null;

        user.NotificationsEnabled = dto.NotificationsEnabled;
        user.UpdatedAt = DateTime.UtcNow;

        await _userManager.UpdateAsync(user);

        return new NotificationSettingsDto
        {
            NotificationsEnabled = user.NotificationsEnabled
        };
    }

    // ========== Data Export ==========

    public async Task<object?> ExportDataAsync(int userId)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return null;

        var activities = await _context.Activities.Where(a => a.UserId == userId).ToListAsync();
        var goals = await _context.UserGoals.Where(g => g.UserId == userId).ToListAsync();
        var dailyScores = await _context.DailyScores.Where(ds => ds.UserId == userId).ToListAsync();
        var trips = await _context.Trips.Where(t => t.UserId == userId).ToListAsync();
        var badges = await _context.UserBadges.Include(ub => ub.Badge).Where(ub => ub.UserId == userId).ToListAsync();
        var challenges = await _context.UserChallenges.Include(uc => uc.Challenge).Where(uc => uc.UserId == userId).ToListAsync();

        return new
        {
            user = new
            {
                user.Id, user.Email, user.UserName, user.FirstName, user.LastName,
                user.Bio, user.EcoScore, user.TotalCO2Saved, user.CurrentStreak,
                user.LongestStreak, user.Level, user.ExperiencePoints, user.CreatedAt
            },
            activities = activities.Select(a => new
            {
                a.Id, a.ActivityTypeId, Date = a.ActivityDate, a.Quantity, a.Unit,
                CO2Saved = a.CO2Impact < 0 ? Math.Abs(a.CO2Impact) : 0,
                Points = a.PointsEarned, a.Notes
            }),
            goals,
            dailyScores = dailyScores.Select(ds => new
            {
                ds.Id, ds.Date, ds.Score, ds.CO2Saved, ds.Steps
            }),
            trips = trips.Select(t => new
            {
                t.Id, t.TransportMode, t.DistanceKm, t.DurationMinutes,
                t.CO2Emitted, t.CO2Saved, t.TripDate
            }),
            badges = badges.Select(b => new
            {
                b.Badge.Name, b.Badge.Description, b.EarnedAt
            }),
            challenges = challenges.Select(c => new
            {
                c.Challenge.Title, c.Challenge.Description, c.CurrentProgress,
                c.IsCompleted, c.CompletedAt
            }),
            exportDate = DateTime.UtcNow
        };
    }

    // ========== Leaderboard ==========

    public async Task<List<LeaderboardDto>> GetLeaderboardAsync(int limit)
    {
        var users = await _userManager.Users
            .OrderByDescending(u => u.EcoScore)
            .Take(limit)
            .ToListAsync();

        return users.Select((user, index) => new LeaderboardDto
        {
            Rank = index + 1,
            User = MapToUserDto(user)
        }).ToList();
    }

    public async Task<object?> GetMyRankAsync(int userId)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return null;

        var rank = await _userManager.Users
            .CountAsync(u => u.EcoScore > user.EcoScore) + 1;

        var totalUsers = await _userManager.Users.CountAsync();

        return new
        {
            rank,
            totalUsers,
            ecoScore = user.EcoScore,
            percentile = totalUsers > 0 ? (1 - ((rank - 1) / (double)totalUsers)) * 100 : 100
        };
    }

    // ========== Dashboard ==========

    public async Task<object?> GetDashboardAsync(int userId)
    {
        var user = await _userManager.FindByIdAsync(userId.ToString());
        if (user == null) return null;

        var today = DateTime.UtcNow.Date;
        var weekAgo = today.AddDays(-7);

        var todayScore = await _context.DailyScores
            .FirstOrDefaultAsync(ds => ds.UserId == userId && ds.Date.Date == today);

        var weeklyStats = await _context.DailyScores
            .Where(ds => ds.UserId == userId && ds.Date >= weekAgo)
            .GroupBy(ds => 1)
            .Select(g => new
            {
                TotalCO2Saved = g.Sum(ds => ds.CO2Saved),
                TotalCO2Emitted = g.Sum(ds => ds.CO2Emitted),
                TotalSteps = g.Sum(ds => ds.Steps)
            })
            .FirstOrDefaultAsync();

        var rank = await _userManager.Users
            .CountAsync(u => u.EcoScore > user.EcoScore) + 1;

        var recentActivities = await _context.Activities
            .Where(a => a.UserId == userId)
            .OrderByDescending(a => a.CreatedAt)
            .Take(5)
            .Select(a => new { a.Id, a.ActivityTypeId, a.Notes, a.CO2Impact, a.PointsEarned, a.CreatedAt })
            .ToListAsync();

        var activeGoals = await _context.UserGoals
            .Where(g => g.UserId == userId && !g.IsCompleted)
            .OrderByDescending(g => g.CreatedAt)
            .Take(3)
            .Select(g => new
            {
                g.Id, g.Title, g.TargetValue, g.CurrentValue, g.Unit,
                ProgressPercentage = g.ProgressPercentage, g.Deadline
            })
            .ToListAsync();

        return new
        {
            user = new
            {
                username = user.UserName, firstName = user.FirstName,
                lastName = user.LastName, ecoScore = user.EcoScore,
                level = user.Level, experiencePoints = user.ExperiencePoints,
                currentStreak = user.CurrentStreak, longestStreak = user.LongestStreak,
                totalCO2Saved = user.TotalCO2Saved
            },
            today = new
            {
                score = todayScore?.Score ?? 0,
                co2Saved = todayScore?.CO2Saved ?? 0,
                co2Emitted = todayScore?.CO2Emitted ?? 0,
                steps = todayScore?.Steps ?? 0
            },
            weekly = new
            {
                co2Saved = weeklyStats?.TotalCO2Saved ?? 0,
                co2Emitted = weeklyStats?.TotalCO2Emitted ?? 0,
                steps = weeklyStats?.TotalSteps ?? 0
            },
            rank,
            recentActivities,
            activeGoals
        };
    }

    // ========== Password Reset & Email ==========

    public async Task<bool> ForgotPasswordAsync(string email)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if (user == null) return true; // Return true for security (don't reveal if user exists)

        return await _emailService.SendPasswordResetEmailAsync(user);
    }

    public async Task<(bool Success, string? Error)> ResetPasswordAsync(ResetPasswordDto dto)
    {
        if (dto.NewPassword != dto.NewPasswordConfirm)
            return (false, "Passwords do not match.");
        if (dto.NewPassword.Length < 6)
            return (false, "Password must be at least 6 characters long.");

        var user = await _emailService.VerifyPasswordResetTokenAsync(dto.Email, dto.Token);
        if (user == null)
            return (false, "Invalid or expired reset token.");

        var result = await _userManager.ResetPasswordAsync(user,
            await _userManager.GeneratePasswordResetTokenAsync(user), dto.NewPassword);

        if (!result.Succeeded)
            return (false, "Failed to reset password.");

        await _emailService.DeletePasswordResetTokenAsync(user.Id);
        return (true, null);
    }

    public async Task<bool> VerifyEmailAsync(string email, string token)
    {
        var user = await _emailService.VerifyEmailTokenAsync(email, token);
        return user != null;
    }

    public async Task<(bool Success, string? Error)> ResendVerificationEmailAsync(string email)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if (user == null)
            return (false, "No user found with this email address.");
        if (user.EmailVerified)
            return (false, "Email is already verified.");

        var success = await _emailService.SendEmailVerificationAsync(user);
        return (success, success ? null : "Failed to send verification email.");
    }

    // ========== Private Helpers ==========

    private async Task<(string AccessToken, string RefreshToken)> GenerateTokensAsync(User user)
    {
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Email, user.Email!),
            new Claim(ClaimTypes.Name, user.UserName!)
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
            _configuration["JWT:Secret"] ?? "your-secret-key-here-min-32-chars-long!"));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _configuration["JWT:ValidIssuer"],
            audience: _configuration["JWT:ValidAudience"],
            claims: claims,
            expires: DateTime.UtcNow.AddHours(24),
            signingCredentials: creds
        );

        var accessToken = new JwtSecurityTokenHandler().WriteToken(token);
        var refreshToken = Convert.ToBase64String(System.Security.Cryptography.RandomNumberGenerator.GetBytes(64));

        var refreshTokenEntity = new RefreshToken
        {
            UserId = user.Id,
            Token = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(7),
            CreatedAt = DateTime.UtcNow
        };

        _context.RefreshTokens.Add(refreshTokenEntity);
        await _context.SaveChangesAsync();

        return (accessToken, refreshToken);
    }

    private async Task<(byte[]? Data, string ContentType, string CacheControl)?> GetProfilePictureForUserAsync(User user)
    {
        try
        {
            var picturePath = user.ProfilePicture;
            bool isDefault = string.IsNullOrEmpty(picturePath) || picturePath == UserEntity.DefaultProfilePicture;

            string filePath;
            if (isDefault)
                filePath = Path.Combine(Directory.GetCurrentDirectory(), "media", UserEntity.DefaultProfilePicture);
            else
                filePath = Path.Combine(_encryptionService.GetMediaPath(), Path.GetFileName(picturePath));

            var decryptedBytes = await _encryptionService.ReadDecryptedFileAsync(filePath);

            if (decryptedBytes == null) return null;

            var cacheControl = isDefault
                ? "public, max-age=86400"
                : "private, max-age=3600";

            var contentType = DetectImageContentType(decryptedBytes);
            return (decryptedBytes, contentType, cacheControl);
        }
        catch
        {
            return null;
        }
    }

    private static string DetectImageContentType(byte[] data)
    {
        if (data.Length >= 8 && data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4E && data[3] == 0x47)
            return "image/png";
        if (data.Length >= 3 && data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF)
            return "image/jpeg";
        if (data.Length >= 4 && data[0] == 0x52 && data[1] == 0x49 && data[2] == 0x46 && data[3] == 0x46)
            return "image/webp";
        if (data.Length >= 6 && data[0] == 0x47 && data[1] == 0x49 && data[2] == 0x46)
            return "image/gif";
        return "image/png";
    }

    public UserDto MapToUserDto(User user)
    {
        return new UserDto
        {
            Id = user.Id,
            Email = user.Email!,
            Username = user.UserName!,
            FirstName = user.FirstName,
            LastName = user.LastName,
            ProfilePicture = $"/api/users/profile-picture/{user.Id}",
            Bio = user.Bio,
            EcoScore = user.EcoScore,
            TotalCO2Saved = user.TotalCO2Saved,
            CurrentStreak = user.CurrentStreak,
            LongestStreak = user.LongestStreak,
            Level = user.Level,
            ExperiencePoints = user.ExperiencePoints,
            Units = user.Units,
            NotificationsEnabled = user.NotificationsEnabled,
            DarkMode = user.DarkMode,
            EmailVerified = user.EmailConfirmed,
            CreatedAt = user.CreatedAt
        };
    }

    // ========== Google Sign-In ==========

    /// <summary>
    /// Verify a Google ID token and return app JWT tokens.
    /// Mirrors Django GoogleSignInView — finds/creates user by google_auth_id then email.
    /// Returns null if token cannot be verified.
    /// </summary>
    public async Task<(AuthResponseDto? Response, string? Error)> GoogleSignInAsync(string idTokenString)
    {
        // Validate the Google ID token using Google.Apis.Auth
        Google.Apis.Auth.GoogleJsonWebSignature.Payload payload;
        try
        {
            var googleClientId = _configuration["Authentication:Google:ClientId"];
            var validationSettings = string.IsNullOrEmpty(googleClientId)
                ? null
                : new Google.Apis.Auth.GoogleJsonWebSignature.ValidationSettings
                  { Audience = new[] { googleClientId } };

            payload = await Google.Apis.Auth.GoogleJsonWebSignature.ValidateAsync(idTokenString, validationSettings);
        }
        catch (Exception ex)
        {
            return (null, $"Invalid Google token: {ex.Message}");
        }

        var googleUserId = payload.Subject;
        var email = payload.Email ?? string.Empty;
        var firstName = payload.GivenName ?? string.Empty;
        var lastName = payload.FamilyName ?? string.Empty;
        var emailVerified = payload.EmailVerified;

        // Try to find user by google_auth_id, then by email
        User? user = await _context.Users.FirstOrDefaultAsync(u => u.GoogleAuthId == googleUserId);

        if (user == null)
        {
            user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user != null)
            {
                // Link Google account to existing user
                user.GoogleAuthId = googleUserId;
                if (!user.EmailVerified && emailVerified)
                    user.EmailVerified = true;
                await _context.SaveChangesAsync();
            }
        }

        if (user == null)
        {
            // Create new Google-only user
            var baseUsername = email.Split('@')[0].ToLower();
            var username = baseUsername;
            var counter = 1;
            while (await _userManager.FindByNameAsync(username) != null)
                username = $"{baseUsername}{counter++}";

            user = new User
            {
                UserName = username,
                Email = email,
                NormalizedEmail = email.ToUpper(),
                NormalizedUserName = username.ToUpper(),
                FirstName = firstName,
                LastName = lastName,
                GoogleAuthId = googleUserId,
                EmailVerified = emailVerified,
                ProfilePicture = User.DefaultProfilePicture
            };

            var result = await _userManager.CreateAsync(user);
            if (!result.Succeeded)
                return (null, result.Errors.FirstOrDefault()?.Description ?? "Failed to create user.");
        }

        var tokens = await GenerateTokensAsync(user);
        return (new AuthResponseDto
        {
            User = MapToUserDto(user),
            Access = tokens.AccessToken,
            Refresh = tokens.RefreshToken,
            EmailVerified = user.EmailConfirmed
        }, null);
    }

    // ========== Notification Preferences ==========

    public async Task<NotificationPreferenceDto?> GetNotificationPreferencesAsync(int userId)
    {
        var prefs = await _context.NotificationPreferences.FirstOrDefaultAsync(p => p.UserId == userId);
        if (prefs == null)
        {
            // Auto-create defaults (mirrors Django get_or_create)
            prefs = new NotificationPreference { UserId = userId };
            _context.NotificationPreferences.Add(prefs);
            await _context.SaveChangesAsync();
        }
        return MapToNotificationPreferenceDto(prefs);
    }

    public async Task<NotificationPreferenceDto?> UpdateNotificationPreferencesAsync(int userId, NotificationPreferenceDto dto)
    {
        var prefs = await _context.NotificationPreferences.FirstOrDefaultAsync(p => p.UserId == userId);
        if (prefs == null)
        {
            prefs = new NotificationPreference { UserId = userId };
            _context.NotificationPreferences.Add(prefs);
        }

        prefs.DailyReminders = dto.DailyReminders;
        prefs.AchievementAlerts = dto.AchievementAlerts;
        prefs.WeeklyReports = dto.WeeklyReports;
        prefs.TipsAndSuggestions = dto.TipsAndSuggestions;
        prefs.CommunityUpdates = dto.CommunityUpdates;

        await _context.SaveChangesAsync();
        return MapToNotificationPreferenceDto(prefs);
    }

    private static NotificationPreferenceDto MapToNotificationPreferenceDto(NotificationPreference prefs) =>
        new()
        {
            DailyReminders = prefs.DailyReminders,
            AchievementAlerts = prefs.AchievementAlerts,
            WeeklyReports = prefs.WeeklyReports,
            TipsAndSuggestions = prefs.TipsAndSuggestions,
            CommunityUpdates = prefs.CommunityUpdates
        };
}
