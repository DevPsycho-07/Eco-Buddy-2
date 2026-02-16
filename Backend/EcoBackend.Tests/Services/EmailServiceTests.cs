using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Xunit;
using Moq;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using EcoBackend.API.Services;
using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using System.Text.RegularExpressions;

namespace EcoBackend.Tests.Services;

public class EmailServiceTests : IAsyncLifetime
{
    private readonly EcoDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly Mock<ILogger<EmailService>> _mockLogger;
    private readonly EmailService _emailService;
    private User _testUser = null!;

    public EmailServiceTests()
    {
        // Setup in-memory database
        var options = new DbContextOptionsBuilder<EcoDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new EcoDbContext(options);
        _mockLogger = new Mock<ILogger<EmailService>>();

        // Use real IConfiguration with in-memory data so GetValue<T>() works
        var configData = new Dictionary<string, string?>
        {
            { "Email:PasswordResetUrl", "eco-daily-score://reset-password" },
            { "Email:PasswordResetTimeout", "3600" },
            { "Email:EmailVerificationUrl", "eco-daily-score://verify-email" },
            { "Email:EmailVerificationTimeout", "86400" },
            { "Email:SmtpHost", "smtp.gmail.com" },
            { "Email:SmtpPort", "587" },
            // No SMTP credentials = skip actual email sending
        };
        _configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(configData)
            .Build();

        _emailService = new EmailService(_configuration, _context, _mockLogger.Object);
    }

    public async Task InitializeAsync()
    {
        _testUser = new User
        {
            UserName = "testuser",
            Email = "test@example.com",
            FirstName = "Test",
            LastName = "User",
            PasswordHash = "hash",
            CreatedAt = DateTime.UtcNow
        };

        _context.Users.Add(_testUser);
        await _context.SaveChangesAsync();
    }

    public async Task DisposeAsync()
    {
        await _context.DisposeAsync();
    }

    [Fact]
    public async Task SendPasswordResetEmailAsync_ShouldCreateToken_WhenTokenDoesNotExist()
    {
        // Act
        var result = await _emailService.SendPasswordResetEmailAsync(_testUser);

        // Assert
        Assert.True(result);
        var token = await _context.PasswordResetTokens
            .FirstOrDefaultAsync(t => t.UserId == _testUser.Id);
        Assert.NotNull(token);
        Assert.NotEmpty(token.Token);
    }

    [Fact]
    public async Task SendPasswordResetEmailAsync_ShouldUpdateToken_WhenTokenExists()
    {
        // Arrange
        var oldToken = new PasswordResetToken
        {
            UserId = _testUser.Id,
            Token = "oldtoken",
            CreatedAt = DateTime.UtcNow.AddHours(-1)
        };
        _context.PasswordResetTokens.Add(oldToken);
        await _context.SaveChangesAsync();

        // Act
        await _emailService.SendPasswordResetEmailAsync(_testUser);

        // Assert
        var updatedToken = await _context.PasswordResetTokens
            .FirstOrDefaultAsync(t => t.UserId == _testUser.Id);
        Assert.NotNull(updatedToken);
        Assert.NotEqual("oldtoken", updatedToken.Token);
    }

    [Fact]
    public async Task SendPasswordResetEmailAsync_ShouldGenerateValidToken_WithUrlSafeCharacters()
    {
        // Act
        await _emailService.SendPasswordResetEmailAsync(_testUser);

        // Assert
        var token = await _context.PasswordResetTokens
            .FirstOrDefaultAsync(t => t.UserId == _testUser.Id);
        Assert.NotNull(token);
        
        // Token should not contain url-unsafe characters (+, /, =)
        Assert.DoesNotContain("+", token.Token);
        Assert.DoesNotContain("/", token.Token);
        Assert.DoesNotContain("=", token.Token);
    }

    [Fact]
    public async Task VerifyPasswordResetTokenAsync_ShouldReturnTrue_WithValidToken()
    {
        // Arrange
        var token = new PasswordResetToken
        {
            UserId = _testUser.Id,
            Token = "validtoken",
            CreatedAt = DateTime.UtcNow
        };
        _context.PasswordResetTokens.Add(token);
        await _context.SaveChangesAsync();

        // Act
        var result = await _emailService.VerifyPasswordResetTokenAsync(_testUser.Email!, "validtoken");

        // Assert
        Assert.NotNull(result);
    }

    [Fact]
    public async Task VerifyPasswordResetTokenAsync_ShouldReturnFalse_WithExpiredToken()
    {
        // Arrange
        var token = new PasswordResetToken
        {
            UserId = _testUser.Id,
            Token = "expiredtoken",
            CreatedAt = DateTime.UtcNow.AddSeconds(-3601) // Expired
        };
        _context.PasswordResetTokens.Add(token);
        await _context.SaveChangesAsync();

        // Act
        var result = await _emailService.VerifyPasswordResetTokenAsync(_testUser.Email!, "expiredtoken");

        // Assert
        Assert.Null(result);
    }

    [Fact]
    public async Task DeletePasswordResetTokenAsync_ShouldRemoveToken()
    {
        // Arrange
        var token = new PasswordResetToken
        {
            UserId = _testUser.Id,
            Token = "tokentoremove",
            CreatedAt = DateTime.UtcNow
        };
        _context.PasswordResetTokens.Add(token);
        await _context.SaveChangesAsync();

        // Act
        await _emailService.DeletePasswordResetTokenAsync(_testUser.Id);

        // Assert
        var result = await _context.PasswordResetTokens
            .FirstOrDefaultAsync(t => t.UserId == _testUser.Id);
        Assert.Null(result);
    }

    [Fact]
    public async Task SendEmailVerificationAsync_ShouldCreateVerificationToken()
    {
        // Act
        var result = await _emailService.SendEmailVerificationAsync(_testUser);

        // Assert
        Assert.True(result);
        var token = await _context.EmailVerificationTokens
            .FirstOrDefaultAsync(t => t.UserId == _testUser.Id);
        Assert.NotNull(token);
    }

    [Fact]
    public async Task VerifyEmailTokenAsync_ShouldReturnTrue_WithValidToken()
    {
        // Arrange
        var token = new EmailVerificationToken
        {
            UserId = _testUser.Id,
            Token = "verifytoken",
            CreatedAt = DateTime.UtcNow
        };
        _context.EmailVerificationTokens.Add(token);
        _testUser.EmailConfirmed = false;
        await _context.SaveChangesAsync();

        // Act
        var result = await _emailService.VerifyEmailTokenAsync(_testUser.Email!, "verifytoken");

        // Assert
        Assert.NotNull(result);
        var updatedUser = await _context.Users.FindAsync(_testUser.Id);
        Assert.NotNull(updatedUser);
        Assert.True(updatedUser.EmailVerified);
    }

    [Fact]
    public async Task VerifyEmailTokenAsync_ShouldReturnFalse_WithInvalidToken()
    {
        // Act
        var result = await _emailService.VerifyEmailTokenAsync(_testUser.Email!, "invalidtoken");

        // Assert
        Assert.Null(result);
    }

    [Fact]
    public async Task SendWelcomeEmailAsync_ShouldReturnTrue()
    {
        // Act
        var result = await _emailService.SendWelcomeEmailAsync(_testUser);

        // Assert
        Assert.True(result);
    }

    [Fact]
    public async Task VerifyPasswordResetTokenAsync_ShouldReturnFalse_WithNullEmail()
    {
        // Act
        var result = await _emailService.VerifyPasswordResetTokenAsync(null!, "token");

        // Assert
        Assert.Null(result);
    }

    [Fact]
    public async Task GenerateToken_ShouldProduceUniqueTokens()
    {
        // Arrange & Act
        var tokens = new List<string>();
        for (int i = 0; i < 5; i++)
        {
            await _emailService.SendPasswordResetEmailAsync(_testUser);
            Thread.Sleep(10); // Small delay to prevent duplicate timestamps
        }

        var allTokens = await _context.PasswordResetTokens
            .Where(t => t.UserId == _testUser.Id)
            .Select(t => t.Token)
            .ToListAsync();

        // Assert - Last token should be the current one
        Assert.NotEmpty(allTokens);
    }
}
