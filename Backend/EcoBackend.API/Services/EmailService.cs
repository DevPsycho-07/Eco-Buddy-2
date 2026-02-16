using System.Security.Cryptography;
using System.Text;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;
using Microsoft.EntityFrameworkCore;
using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;

namespace EcoBackend.API.Services;

/// <summary>
/// Email service for sending various emails (password reset, verification, welcome)
/// </summary>
public class EmailService
{
    private readonly IConfiguration _configuration;
    private readonly EcoDbContext _context;
    private readonly ILogger<EmailService> _logger;
    
    public EmailService(IConfiguration configuration, EcoDbContext context, ILogger<EmailService> logger)
    {
        _configuration = configuration;
        _context = context;
        _logger = logger;
    }
    
    /// <summary>
    /// Generate a secure random token (URL-safe base64)
    /// </summary>
    private string GenerateToken()
    {
        var bytes = new byte[32];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(bytes);
        return Convert.ToBase64String(bytes)
            .Replace("+", "-")
            .Replace("/", "_")
            .TrimEnd('=');
    }
    
    /// <summary>
    /// Send password reset email to user
    /// </summary>
    public async Task<bool> SendPasswordResetEmailAsync(User user, string? frontendUrl = null)
    {
        try
        {
            frontendUrl ??= _configuration["Email:PasswordResetUrl"] ?? "eco-daily-score://reset-password";
            
            // Generate or update reset token
            var tokenObj = await _context.PasswordResetTokens
                .FirstOrDefaultAsync(t => t.UserId == user.Id);
            
            if (tokenObj == null)
            {
                tokenObj = new PasswordResetToken
                {
                    UserId = user.Id,
                    Token = GenerateToken(),
                    CreatedAt = DateTime.UtcNow
                };
                _context.PasswordResetTokens.Add(tokenObj);
            }
            else
            {
                tokenObj.Token = GenerateToken();
                tokenObj.CreatedAt = DateTime.UtcNow;
            }
            
            await _context.SaveChangesAsync();
            
            // Create reset link
            var resetLink = $"{frontendUrl}?token={tokenObj.Token}&email={Uri.EscapeDataString(user.Email!)}";
            var timeoutHours = _configuration.GetValue<int>("Email:PasswordResetTimeout", 3600) / 3600;
            
            // Build email
            var emailBody = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #4CAF50; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; background-color: #f9f9f9; }}
        .button {{ display: inline-block; padding: 12px 24px; margin: 20px 0; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px; }}
        .footer {{ text-align: center; padding: 20px; font-size: 12px; color: #666; }}
    </style>
</head>
<body>
    <div class=""container"">
        <div class=""header"">
            <h1>🌱 Eco Daily Score</h1>
        </div>
        <div class=""content"">
            <h2>Password Reset Request</h2>
            <p>Hi {user.FirstName ?? user.UserName},</p>
            <p>We received a request to reset your password. Click the button below to reset it:</p>
            <a href=""{resetLink}"" class=""button"">Reset Password</a>
            <p>Or copy and paste this link into your browser:</p>
            <p style=""word-break: break-all; color: #666;"">{resetLink}</p>
            <p><strong>This link will expire in {timeoutHours} hour(s).</strong></p>
            <p>If you didn't request this, please ignore this email. Your password will remain unchanged.</p>
        </div>
        <div class=""footer"">
            <p>© 2026 Eco Daily Score. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
            
            await SendEmailAsync(
                user.Email!,
                "Reset Your Eco Daily Score Password",
                emailBody
            );
            
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send password reset email to {Email}", user.Email);
            return false;
        }
    }
    
    /// <summary>
    /// Send email verification email to user
    /// </summary>
    public async Task<bool> SendEmailVerificationAsync(User user, string? frontendUrl = null)
    {
        try
        {
            frontendUrl ??= _configuration["Email:EmailVerificationUrl"] ?? "eco-daily-score://verify-email";
            
            // Generate or update verification token
            var tokenObj = await _context.EmailVerificationTokens
                .FirstOrDefaultAsync(t => t.UserId == user.Id);
            
            if (tokenObj == null)
            {
                tokenObj = new EmailVerificationToken
                {
                    UserId = user.Id,
                    Token = GenerateToken(),
                    IsVerified = false,
                    CreatedAt = DateTime.UtcNow
                };
                _context.EmailVerificationTokens.Add(tokenObj);
            }
            else
            {
                tokenObj.Token = GenerateToken();
                tokenObj.IsVerified = false;
                tokenObj.CreatedAt = DateTime.UtcNow;
            }
            
            await _context.SaveChangesAsync();
            
            // Create verification link
            var verifyLink = $"{frontendUrl}?token={tokenObj.Token}&email={Uri.EscapeDataString(user.Email!)}";
            var timeoutHours = _configuration.GetValue<int>("Email:EmailVerificationTimeout", 86400) / 3600;
            
            // Build email
            var emailBody = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #4CAF50; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; background-color: #f9f9f9; }}
        .button {{ display: inline-block; padding: 12px 24px; margin: 20px 0; background-color: #4CAF50; color: white; text-decoration: none; border-radius: 5px; }}
        .footer {{ text-align: center; padding: 20px; font-size: 12px; color: #666; }}
    </style>
</head>
<body>
    <div class=""container"">
        <div class=""header"">
            <h1>🌱 Eco Daily Score</h1>
        </div>
        <div class=""content"">
            <h2>Verify Your Email Address</h2>
            <p>Hi {user.FirstName ?? user.UserName},</p>
            <p>Thank you for registering with Eco Daily Score! Please verify your email address by clicking the button below:</p>
            <a href=""{verifyLink}"" class=""button"">Verify Email</a>
            <p>Or copy and paste this link into your browser:</p>
            <p style=""word-break: break-all; color: #666;"">{verifyLink}</p>
            <p><strong>This link will expire in {timeoutHours} hour(s).</strong></p>
            <p>If you didn't create this account, please ignore this email.</p>
        </div>
        <div class=""footer"">
            <p>© 2026 Eco Daily Score. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
            
            await SendEmailAsync(
                user.Email!,
                "Verify Your Eco Daily Score Email",
                emailBody
            );
            
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send email verification to {Email}", user.Email);
            return false;
        }
    }
    
    /// <summary>
    /// Send welcome email to new user
    /// </summary>
    public async Task<bool> SendWelcomeEmailAsync(User user)
    {
        try
        {
            var emailBody = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
        .header {{ background-color: #4CAF50; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 20px; background-color: #f9f9f9; }}
        .feature {{ margin: 15px 0; padding: 10px; background-color: white; border-left: 4px solid #4CAF50; }}
        .footer {{ text-align: center; padding: 20px; font-size: 12px; color: #666; }}
    </style>
</head>
<body>
    <div class=""container"">
        <div class=""header"">
            <h1>🌱 Welcome to Eco Daily Score!</h1>
        </div>
        <div class=""content"">
            <h2>Hi {user.FirstName ?? user.UserName}!</h2>
            <p>Welcome to the Eco Daily Score community! We're excited to have you on board on your journey towards a more sustainable lifestyle.</p>
            
            <h3>🌟 Get Started:</h3>
            <div class=""feature"">
                <strong>📊 Track Your Activities</strong><br>
                Log your daily eco-friendly activities and watch your score grow!
            </div>
            <div class=""feature"">
                <strong>🏆 Earn Achievements</strong><br>
                Unlock badges and complete challenges as you progress.
            </div>
            <div class=""feature"">
                <strong>🌍 Reduce Your Carbon Footprint</strong><br>
                See the real environmental impact of your daily choices.
            </div>
            <div class=""feature"">
                <strong>📈 Compete & Connect</strong><br>
                Join the leaderboard and challenge yourself and others!
            </div>
            
            <p>Every small action counts towards making our planet greener. Let's make a difference together! 🌍💚</p>
        </div>
        <div class=""footer"">
            <p>© 2026 Eco Daily Score. All rights reserved.</p>
        </div>
    </div>
</body>
</html>";
            
            await SendEmailAsync(
                user.Email!,
                "Welcome to Eco Daily Score!",
                emailBody
            );
            
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send welcome email to {Email}", user.Email);
            return false;
        }
    }
    
    /// <summary>
    /// Verify password reset token
    /// </summary>
    public async Task<User?> VerifyPasswordResetTokenAsync(string email, string token)
    {
        try
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null) return null;
            
            var tokenObj = await _context.PasswordResetTokens
                .FirstOrDefaultAsync(t => t.UserId == user.Id && t.Token == token);
            
            if (tokenObj == null) return null;
            
            var timeout = _configuration.GetValue<int>("Email:PasswordResetTimeout", 3600);
            if (tokenObj.IsValid(timeout))
            {
                return user;
            }
            
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to verify password reset token for {Email}", email);
            return null;
        }
    }
    
    /// <summary>
    /// Verify email verification token and mark email as verified
    /// </summary>
    public async Task<User?> VerifyEmailTokenAsync(string email, string token)
    {
        try
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
            if (user == null) return null;
            
            var tokenObj = await _context.EmailVerificationTokens
                .FirstOrDefaultAsync(t => t.UserId == user.Id && t.Token == token);
            
            if (tokenObj == null) return null;
            
            var timeout = _configuration.GetValue<int>("Email:EmailVerificationTimeout", 86400);
            if (tokenObj.IsValid(timeout))
            {
                user.EmailVerified = true;
                tokenObj.IsVerified = true;
                await _context.SaveChangesAsync();
                return user;
            }
            
            return null;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to verify email token for {Email}", email);
            return null;
        }
    }
    
    /// <summary>
    /// Delete password reset token after use
    /// </summary>
    public async Task DeletePasswordResetTokenAsync(int userId)
    {
        var token = await _context.PasswordResetTokens.FirstOrDefaultAsync(t => t.UserId == userId);
        if (token != null)
        {
            _context.PasswordResetTokens.Remove(token);
            await _context.SaveChangesAsync();
        }
    }
    
    /// <summary>
    /// Core email sending method using MailKit
    /// </summary>
    private async Task SendEmailAsync(string toEmail, string subject, string htmlBody)
    {
        var smtpHost = _configuration["Email:SmtpHost"] ?? "smtp.gmail.com";
        var smtpPort = _configuration.GetValue<int>("Email:SmtpPort", 587);
        var smtpUser = _configuration["Email:SmtpUser"];
        var smtpPassword = _configuration["Email:SmtpPassword"];
        var fromEmail = _configuration["Email:FromEmail"] ?? "noreply@ecodailyscore.com";
        var fromName = _configuration["Email:FromName"] ?? "Eco Daily Score";
        
        if (string.IsNullOrEmpty(smtpUser) || string.IsNullOrEmpty(smtpPassword))
        {
            _logger.LogWarning("Email credentials not configured. Skipping email send.");
            return;
        }
        
        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(fromName, fromEmail));
        message.To.Add(new MailboxAddress("", toEmail));
        message.Subject = subject;
        
        var bodyBuilder = new BodyBuilder
        {
            HtmlBody = htmlBody,
            TextBody = StripHtml(htmlBody)
        };
        
        message.Body = bodyBuilder.ToMessageBody();
        
        using var client = new SmtpClient();
        await client.ConnectAsync(smtpHost, smtpPort, SecureSocketOptions.StartTls);
        await client.AuthenticateAsync(smtpUser, smtpPassword);
        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
    
    /// <summary>
    /// Strip HTML tags for plain text version
    /// </summary>
    private string StripHtml(string html)
    {
        return System.Text.RegularExpressions.Regex.Replace(html, "<.*?>", string.Empty)
            .Replace("&nbsp;", " ")
            .Trim();
    }
}
