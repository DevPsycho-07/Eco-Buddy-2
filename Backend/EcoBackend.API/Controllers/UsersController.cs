using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using EcoBackend.Core.Entities;
using EcoBackend.API.DTOs;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/users")]
public class UsersController : ControllerBase
{
    private readonly UserManager<User> _userManager;
    private readonly SignInManager<User> _signInManager;
    private readonly IConfiguration _configuration;
    
    public UsersController(
        UserManager<User> userManager,
        SignInManager<User> signInManager,
        IConfiguration configuration)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _configuration = configuration;
    }
    
    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<IActionResult> Register([FromBody] UserRegistrationDto dto)
    {
        // Split full name into first and last names
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
            LastName = lastName
        };
        
        var result = await _userManager.CreateAsync(user, dto.Password);
        
        if (!result.Succeeded)
        {
            return BadRequest(new { errors = result.Errors.Select(e => e.Description) });
        }
        
        var tokens = GenerateTokens(user);
        
        return Ok(new AuthResponseDto
        {
            User = MapToUserDto(user),
            AccessToken = tokens.AccessToken,
            RefreshToken = tokens.RefreshToken
        });
    }
    
    [HttpGet("check-username/{username}")]
    [AllowAnonymous]
    public async Task<IActionResult> CheckUsername(string username)
    {
        var exists = await _userManager.Users.AnyAsync(u => u.UserName == username);
        return Ok(new { exists });
    }
    
    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var user = await _userManager.FindByEmailAsync(dto.Email);
        
        if (user == null)
        {
            return Unauthorized(new { error = "Invalid email or password" });
        }
        
        var result = await _signInManager.CheckPasswordSignInAsync(user, dto.Password, false);
        
        if (!result.Succeeded)
        {
            return Unauthorized(new { error = "Invalid email or password" });
        }
        
        var tokens = GenerateTokens(user);
        
        return Ok(new AuthResponseDto
        {
            User = MapToUserDto(user),
            AccessToken = tokens.AccessToken,
            RefreshToken = tokens.RefreshToken
        });
    }
    
    [HttpGet("profile")]
    [Authorize]
    public async Task<IActionResult> GetProfile()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var user = await _userManager.FindByIdAsync(userId!);
        
        if (user == null)
        {
            return NotFound();
        }
        
        return Ok(MapToUserDto(user));
    }
    
    [HttpPut("profile")]
    [Authorize]
    public async Task<IActionResult> UpdateProfile([FromBody] UserProfileUpdateDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var user = await _userManager.FindByIdAsync(userId!);
        
        if (user == null)
        {
            return NotFound();
        }
        
        if (!string.IsNullOrEmpty(dto.FirstName))
            user.FirstName = dto.FirstName;
        if (!string.IsNullOrEmpty(dto.LastName))
            user.LastName = dto.LastName;
        if (!string.IsNullOrEmpty(dto.Username))
            user.UserName = dto.Username;
        if (!string.IsNullOrEmpty(dto.Bio))
            user.Bio = dto.Bio;
        if (dto.ProfilePicture != null)
            user.ProfilePicture = dto.ProfilePicture;
        if (!string.IsNullOrEmpty(dto.Units))
            user.Units = dto.Units;
        if (dto.DarkMode.HasValue)
            user.DarkMode = dto.DarkMode.Value;
        
        user.UpdatedAt = DateTime.UtcNow;
        
        await _userManager.UpdateAsync(user);
        
        return Ok(MapToUserDto(user));
    }
    
    [HttpPost("upload-picture")]
    [Authorize]
    public async Task<IActionResult> UploadProfilePicture(IFormFile profile_picture)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var user = await _userManager.FindByIdAsync(userId!);
        
        if (user == null)
        {
            return NotFound();
        }
        
        if (profile_picture == null || profile_picture.Length == 0)
        {
            return BadRequest(new { error = "No file provided" });
        }
        
        // Validate file type
        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif" };
        var extension = Path.GetExtension(profile_picture.FileName).ToLower();
        if (!allowedExtensions.Contains(extension))
        {
            return BadRequest(new { error = "Invalid file type. Only jpg, jpeg, png, and gif are allowed." });
        }
        
        // Validate file size (max 5MB)
        if (profile_picture.Length > 5 * 1024 * 1024)
        {
            return BadRequest(new { error = "File size exceeds 5MB limit." });
        }
        
        try
        {
            // Create media directory if it doesn't exist
            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "media", "profile_pictures");
            Directory.CreateDirectory(uploadsFolder);
            
            // Generate unique filename
            var fileName = $"{userId}_{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(uploadsFolder, fileName);
            
            // Delete old profile picture if exists
            if (!string.IsNullOrEmpty(user.ProfilePicture))
            {
                var oldFilePath = Path.Combine(Directory.GetCurrentDirectory(), user.ProfilePicture.TrimStart('/'));
                if (System.IO.File.Exists(oldFilePath))
                {
                    System.IO.File.Delete(oldFilePath);
                }
            }
            
            // Save new file
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await profile_picture.CopyToAsync(stream);
            }
            
            // Update user profile picture path
            user.ProfilePicture = $"/media/profile_pictures/{fileName}";
            user.UpdatedAt = DateTime.UtcNow;
            await _userManager.UpdateAsync(user);
            
            return Ok(new { profile_picture = user.ProfilePicture });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { error = $"Failed to upload file: {ex.Message}" });
        }
    }
    
    [HttpGet("privacy-settings")]
    [Authorize]
    public async Task<IActionResult> GetPrivacySettings()
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var user = await _userManager.FindByIdAsync(userId!);
        
        if (user == null)
        {
            return NotFound();
        }
        
        return Ok(new UserPrivacySettingsDto
        {
            LocationTracking = user.LocationTracking,
            ActivityRecognition = user.ActivityRecognition,
            HealthDataSync = user.HealthDataSync,
            CalendarAccess = user.CalendarAccess
        });
    }
    
    [HttpPut("privacy-settings")]
    [Authorize]
    public async Task<IActionResult> UpdatePrivacySettings([FromBody] UserPrivacySettingsDto dto)
    {
        var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
        var user = await _userManager.FindByIdAsync(userId!);
        
        if (user == null)
        {
            return NotFound();
        }
        
        user.LocationTracking = dto.LocationTracking;
        user.ActivityRecognition = dto.ActivityRecognition;
        user.HealthDataSync = dto.HealthDataSync;
        user.CalendarAccess = dto.CalendarAccess;
        user.UpdatedAt = DateTime.UtcNow;
        
        await _userManager.UpdateAsync(user);
        
        return Ok(dto);
    }
    
    [HttpPost("logout")]
    [Authorize]
    public IActionResult Logout()
    {
        // In a real app, you'd invalidate the refresh token here
        return Ok(new { message = "Successfully logged out" });
    }
    
    [HttpGet("leaderboard")]
    [Authorize]
    public async Task<IActionResult> GetLeaderboard([FromQuery] int limit = 10)
    {
        var users = await _userManager.Users
            .OrderByDescending(u => u.EcoScore)
            .Take(limit)
            .ToListAsync();
        
        var leaderboard = users.Select((user, index) => new LeaderboardDto
        {
            Rank = index + 1,
            User = MapToUserDto(user)
        }).ToList();
        
        return Ok(leaderboard);
    }
    
    [HttpGet("my-rank")]
    [Authorize]
    public async Task<IActionResult> GetMyRank()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var user = await _userManager.FindByIdAsync(userId.ToString());
        
        if (user == null)
        {
            return NotFound(new { error = "User not found" });
        }
        
        // Get user's rank by counting users with higher eco score
        var rank = await _userManager.Users
            .CountAsync(u => u.EcoScore > user.EcoScore) + 1;
        
        var totalUsers = await _userManager.Users.CountAsync();
        
        return Ok(new
        {
            rank,
            totalUsers,
            ecoScore = user.EcoScore,
            percentile = totalUsers > 0 ? (1 - ((rank - 1) / (double)totalUsers)) * 100 : 100
        });
    }
    
    private (string AccessToken, string RefreshToken) GenerateTokens(User user)
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
        var refreshToken = Guid.NewGuid().ToString(); // Simplified - use proper refresh token in production
        
        return (accessToken, refreshToken);
    }
    
    private UserDto MapToUserDto(User user)
    {
        return new UserDto
        {
            Id = user.Id,
            Email = user.Email!,
            Username = user.UserName!,
            FirstName = user.FirstName,
            LastName = user.LastName,
            ProfilePicture = user.ProfilePicture,
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
            CreatedAt = user.CreatedAt
        };
    }
}
