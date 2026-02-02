using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/achievements")]
[Authorize]
public class AchievementsController : ControllerBase
{
    private readonly EcoDbContext _context;
    
    public AchievementsController(EcoDbContext context)
    {
        _context = context;
    }
    
    [HttpGet("badges")]
    public async Task<IActionResult> GetBadges()
    {
        var badges = await _context.Badges
            .Where(b => b.IsActive)
            .OrderBy(b => b.BadgeType)
            .ThenBy(b => b.RequirementValue)
            .ToListAsync();
        
        var dtos = badges.Select(b => new BadgeDto
        {
            Id = b.Id,
            Name = b.Name,
            Description = b.Description,
            Icon = b.Icon,
            BadgeType = b.BadgeType,
            PointsReward = b.PointsReward
        }).ToList();
        
        return Ok(dtos);
    }
    
    [HttpGet("my-badges")]
    public async Task<IActionResult> GetMyBadges()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var userBadges = await _context.UserBadges
            .Include(ub => ub.Badge)
            .Where(ub => ub.UserId == userId)
            .OrderByDescending(ub => ub.EarnedAt)
            .ToListAsync();
        
        var dtos = userBadges.Select(ub => new UserBadgeDto
        {
            Id = ub.Id,
            Badge = new BadgeDto
            {
                Id = ub.Badge.Id,
                Name = ub.Badge.Name,
                Description = ub.Badge.Description,
                Icon = ub.Badge.Icon,
                BadgeType = ub.Badge.BadgeType,
                PointsReward = ub.Badge.PointsReward
            },
            EarnedAt = ub.EarnedAt
        }).ToList();
        
        return Ok(dtos);
    }
    
    [HttpGet("challenges")]
    public async Task<IActionResult> GetChallenges()
    {
        var now = DateTime.UtcNow;
        
        var challenges = await _context.Challenges
            .Where(c => c.IsActive && c.StartDate <= now && c.EndDate >= now)
            .OrderByDescending(c => c.StartDate)
            .ToListAsync();
        
        var dtos = challenges.Select(c => new ChallengeDto
        {
            Id = c.Id,
            Title = c.Title,
            Description = c.Description,
            ChallengeType = c.ChallengeType,
            TargetValue = c.TargetValue,
            TargetUnit = c.TargetUnit,
            PointsReward = c.PointsReward,
            StartDate = c.StartDate,
            EndDate = c.EndDate,
            IsActive = c.IsActive
        }).ToList();
        
        return Ok(dtos);
    }
    
    [HttpGet("my-challenges")]
    public async Task<IActionResult> GetMyChallenges()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var userChallenges = await _context.UserChallenges
            .Include(uc => uc.Challenge)
            .Where(uc => uc.UserId == userId)
            .OrderByDescending(uc => uc.JoinedAt)
            .ToListAsync();
        
        var dtos = userChallenges.Select(uc => new UserChallengeDto
        {
            Id = uc.Id,
            Challenge = new ChallengeDto
            {
                Id = uc.Challenge.Id,
                Title = uc.Challenge.Title,
                Description = uc.Challenge.Description,
                ChallengeType = uc.Challenge.ChallengeType,
                TargetValue = uc.Challenge.TargetValue,
                TargetUnit = uc.Challenge.TargetUnit,
                PointsReward = uc.Challenge.PointsReward,
                StartDate = uc.Challenge.StartDate,
                EndDate = uc.Challenge.EndDate,
                IsActive = uc.Challenge.IsActive
            },
            CurrentProgress = uc.CurrentProgress,
            IsCompleted = uc.IsCompleted,
            ProgressPercentage = uc.ProgressPercentage,
            JoinedAt = uc.JoinedAt,
            CompletedAt = uc.CompletedAt
        }).ToList();
        
        return Ok(dtos);
    }
    
    [HttpGet("challenges/active")]
    public async Task<IActionResult> GetActiveChallenges()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var now = DateTime.UtcNow;
        
        // Get active challenges that user hasn't completed
        var userCompletedChallengeIds = await _context.UserChallenges
            .Where(uc => uc.UserId == userId && uc.IsCompleted)
            .Select(uc => uc.ChallengeId)
            .ToListAsync();
        
        var activeChallenges = await _context.Challenges
            .Where(c => c.IsActive 
                && c.StartDate <= now 
                && c.EndDate >= now
                && !userCompletedChallengeIds.Contains(c.Id))
            .OrderBy(c => c.EndDate)
            .Take(5)
            .ToListAsync();
        
        var dtos = activeChallenges.Select(c => new ChallengeDto
        {
            Id = c.Id,
            Title = c.Title,
            Description = c.Description,
            ChallengeType = c.ChallengeType,
            TargetValue = c.TargetValue,
            TargetUnit = c.TargetUnit,
            PointsReward = c.PointsReward,
            StartDate = c.StartDate,
            EndDate = c.EndDate,
            IsActive = c.IsActive
        }).ToList();
        
        return Ok(dtos);
    }
    
    [HttpPost("challenges/{id}/join")]
    public async Task<IActionResult> JoinChallenge(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var challenge = await _context.Challenges.FindAsync(id);
        if (challenge == null || !challenge.IsActive)
        {
            return NotFound();
        }
        
        var existing = await _context.UserChallenges
            .FirstOrDefaultAsync(uc => uc.UserId == userId && uc.ChallengeId == id);
        
        if (existing != null)
        {
            return BadRequest(new { error = "Already joined this challenge" });
        }
        
        var userChallenge = new UserChallenge
        {
            UserId = userId,
            ChallengeId = id
        };
        
        _context.UserChallenges.Add(userChallenge);
        await _context.SaveChangesAsync();
        
        return Ok(new { message = "Successfully joined challenge" });
    }
    
    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var totalBadges = await _context.UserBadges.CountAsync(ub => ub.UserId == userId);
        var totalChallenges = await _context.UserChallenges.CountAsync(uc => uc.UserId == userId);
        var completedChallenges = await _context.UserChallenges
            .CountAsync(uc => uc.UserId == userId && uc.IsCompleted);
        var activeChallenges = totalChallenges - completedChallenges;
        
        var recentBadges = await _context.UserBadges
            .Where(ub => ub.UserId == userId)
            .OrderByDescending(ub => ub.EarnedAt)
            .Take(3)
            .Include(ub => ub.Badge)
            .Select(ub => new
            {
                id = ub.Badge.Id,
                name = ub.Badge.Name,
                icon = ub.Badge.Icon,
                earnedAt = ub.EarnedAt
            })
            .ToListAsync();
        
        return Ok(new
        {
            totalBadges,
            totalChallenges,
            completedChallenges,
            activeChallenges,
            recentBadges
        });
    }
    
    [HttpGet("my-badges/summary")]
    public async Task<IActionResult> GetMyBadgesSummary()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var userBadges = await _context.UserBadges
            .Where(ub => ub.UserId == userId)
            .Include(ub => ub.Badge)
            .ToListAsync();
        
        var grouped = userBadges
            .GroupBy(ub => ub.Badge.BadgeType)
            .Select(g => new
            {
                badgeType = g.Key,
                count = g.Count(),
                totalPoints = g.Sum(ub => ub.Badge.PointsReward),
                badges = g.Select(ub => new
                {
                    id = ub.Badge.Id,
                    name = ub.Badge.Name,
                    icon = ub.Badge.Icon,
                    earnedAt = ub.EarnedAt
                }).ToList()
            })
            .ToList();
        
        return Ok(new
        {
            totalBadges = userBadges.Count,
            totalPoints = userBadges.Sum(ub => ub.Badge.PointsReward),
            byType = grouped
        });
    }
}
