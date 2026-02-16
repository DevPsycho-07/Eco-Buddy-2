using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace EcoBackend.API.Services;

public class AchievementService
{
    private readonly EcoDbContext _context;
    
    public AchievementService(EcoDbContext context)
    {
        _context = context;
    }

    // ========== Badge Query Methods ==========

    public async Task<List<BadgeDto>> GetBadgesAsync()
    {
        var badges = await _context.Badges
            .Where(b => b.IsActive)
            .OrderBy(b => b.BadgeType)
            .ThenBy(b => b.RequirementValue)
            .ToListAsync();

        return badges.Select(b => new BadgeDto
        {
            Id = b.Id, Name = b.Name, Description = b.Description,
            Icon = b.Icon, BadgeType = b.BadgeType, PointsReward = b.PointsReward
        }).ToList();
    }

    public async Task<BadgeDto?> GetBadgeByIdAsync(int id)
    {
        var badge = await _context.Badges.FindAsync(id);
        if (badge == null) return null;

        return new BadgeDto
        {
            Id = badge.Id, Name = badge.Name, Description = badge.Description,
            Icon = badge.Icon, BadgeType = badge.BadgeType, PointsReward = badge.PointsReward
        };
    }

    public async Task<List<UserBadgeDto>> GetMyBadgesAsync(int userId)
    {
        var userBadges = await _context.UserBadges
            .Include(ub => ub.Badge)
            .Where(ub => ub.UserId == userId)
            .OrderByDescending(ub => ub.EarnedAt)
            .ToListAsync();

        return userBadges.Select(ub => new UserBadgeDto
        {
            Id = ub.Id,
            Badge = new BadgeDto
            {
                Id = ub.Badge.Id, Name = ub.Badge.Name, Description = ub.Badge.Description,
                Icon = ub.Badge.Icon, BadgeType = ub.Badge.BadgeType, PointsReward = ub.Badge.PointsReward
            },
            EarnedAt = ub.EarnedAt
        }).ToList();
    }

    public async Task<UserBadgeDto?> GetMyBadgeByIdAsync(int id, int userId)
    {
        var userBadge = await _context.UserBadges
            .Include(ub => ub.Badge)
            .FirstOrDefaultAsync(ub => ub.Id == id && ub.UserId == userId);

        if (userBadge == null) return null;

        return new UserBadgeDto
        {
            Id = userBadge.Id,
            Badge = new BadgeDto
            {
                Id = userBadge.Badge.Id, Name = userBadge.Badge.Name,
                Description = userBadge.Badge.Description, Icon = userBadge.Badge.Icon,
                BadgeType = userBadge.Badge.BadgeType, PointsReward = userBadge.Badge.PointsReward
            },
            EarnedAt = userBadge.EarnedAt
        };
    }

    public async Task<object> GetMyBadgesSummaryAsync(int userId)
    {
        // Get all badges
        var allBadges = await _context.Badges
            .Where(b => b.IsActive)
            .ToListAsync();

        // Get user's earned badges
        var userBadgeIds = await _context.UserBadges
            .Where(ub => ub.UserId == userId)
            .Select(ub => ub.BadgeId)
            .ToListAsync();

        var userBadges = await _context.UserBadges
            .Where(ub => ub.UserId == userId)
            .Include(ub => ub.Badge)
            .ToListAsync();

        // Split into earned and not earned
        var earned = userBadges.Select(ub => new
        {
            id = ub.Badge.Id,
            name = ub.Badge.Name,
            description = ub.Badge.Description,
            icon = ub.Badge.Icon,
            badge_type = ub.Badge.BadgeType,
            points_reward = ub.Badge.PointsReward,
            requirement_type = ub.Badge.RequirementType,
            requirement_value = ub.Badge.RequirementValue,
            requirement_category = ub.Badge.RequirementCategory,
            earned_at = ub.EarnedAt
        }).ToList();

        var notEarned = allBadges
            .Where(b => !userBadgeIds.Contains(b.Id))
            .Select(b => new
            {
                id = b.Id,
                name = b.Name,
                description = b.Description,
                icon = b.Icon,
                badge_type = b.BadgeType,
                points_reward = b.PointsReward,
                requirement_type = b.RequirementType,
                requirement_value = b.RequirementValue,
                requirement_category = b.RequirementCategory
            })
            .ToList();

        return new
        {
            earned = earned,
            not_earned = notEarned,
            total_badges = earned.Count,
            total_points = userBadges.Sum(ub => ub.Badge.PointsReward)
        };
    }

    // ========== Challenge Query Methods ==========

    public async Task<List<ChallengeDto>> GetChallengesAsync()
    {
        var now = DateTime.UtcNow;
        var challenges = await _context.Challenges
            .Where(c => c.IsActive && c.StartDate <= now && c.EndDate >= now)
            .OrderByDescending(c => c.StartDate)
            .ToListAsync();

        return challenges.Select(MapToChallengeDto).ToList();
    }

    public async Task<ChallengeDto?> GetChallengeByIdAsync(int id)
    {
        var challenge = await _context.Challenges.FindAsync(id);
        if (challenge == null) return null;
        return MapToChallengeDto(challenge);
    }

    public async Task<List<ChallengeDto>> GetActiveChallengesAsync(int userId)
    {
        var now = DateTime.UtcNow;
        var completedIds = await _context.UserChallenges
            .Where(uc => uc.UserId == userId && uc.IsCompleted)
            .Select(uc => uc.ChallengeId)
            .ToListAsync();

        var challenges = await _context.Challenges
            .Where(c => c.IsActive && c.StartDate <= now && c.EndDate >= now && !completedIds.Contains(c.Id))
            .OrderBy(c => c.EndDate)
            .Take(5)
            .ToListAsync();

        return challenges.Select(MapToChallengeDto).ToList();
    }

    // ========== User Challenge Methods ==========

    public async Task<List<UserChallengeDto>> GetMyChallengesAsync(int userId)
    {
        var userChallenges = await _context.UserChallenges
            .Include(uc => uc.Challenge)
            .Where(uc => uc.UserId == userId)
            .OrderByDescending(uc => uc.JoinedAt)
            .ToListAsync();

        return userChallenges.Select(MapToUserChallengeDto).ToList();
    }

    public async Task<UserChallengeDto?> GetMyChallengeByIdAsync(int id, int userId)
    {
        var uc = await _context.UserChallenges
            .Include(uc => uc.Challenge)
            .FirstOrDefaultAsync(uc => uc.Id == id && uc.UserId == userId);

        if (uc == null) return null;
        return MapToUserChallengeDto(uc);
    }

    public async Task<List<UserChallengeDto>> GetMyActiveChallengesAsync(int userId)
    {
        return await _context.UserChallenges
            .Include(uc => uc.Challenge)
            .Where(uc => uc.UserId == userId && !uc.IsCompleted)
            .Select(uc => MapToUserChallengeDtoStatic(uc))
            .ToListAsync();
    }

    public async Task<List<UserChallengeDto>> GetCompletedChallengesAsync(int userId)
    {
        return await _context.UserChallenges
            .Include(uc => uc.Challenge)
            .Where(uc => uc.UserId == userId && uc.IsCompleted)
            .Select(uc => MapToUserChallengeDtoStatic(uc))
            .ToListAsync();
    }

    public async Task<(bool Success, string? Error)> JoinChallengeAsync(int challengeId, int userId)
    {
        var challenge = await _context.Challenges.FindAsync(challengeId);
        if (challenge == null || !challenge.IsActive)
            return (false, "not_found");

        var existing = await _context.UserChallenges
            .FirstOrDefaultAsync(uc => uc.UserId == userId && uc.ChallengeId == challengeId);
        if (existing != null)
            return (false, "already_joined");

        _context.UserChallenges.Add(new UserChallenge { UserId = userId, ChallengeId = challengeId });
        await _context.SaveChangesAsync();
        return (true, null);
    }

    public async Task<UserChallengeDto?> UpdateMyChallengeAsync(int id, int userId, UpdateUserChallengeDto dto)
    {
        var uc = await _context.UserChallenges
            .Include(uc => uc.Challenge)
            .FirstOrDefaultAsync(uc => uc.Id == id && uc.UserId == userId);
        if (uc == null) return null;

        uc.CurrentProgress = dto.CurrentProgress;
        if (uc.CurrentProgress >= uc.Challenge.TargetValue && !uc.IsCompleted)
        {
            uc.IsCompleted = true;
            uc.CompletedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
        return MapToUserChallengeDto(uc);
    }

    public async Task<UserChallengeDto?> PartialUpdateMyChallengeAsync(int id, int userId, JsonElement updates)
    {
        var uc = await _context.UserChallenges
            .Include(uc => uc.Challenge)
            .FirstOrDefaultAsync(uc => uc.Id == id && uc.UserId == userId);
        if (uc == null) return null;

        if (updates.TryGetProperty("current_progress", out var progressElement))
        {
            uc.CurrentProgress = (double)progressElement.GetDecimal();
            if (uc.CurrentProgress >= uc.Challenge.TargetValue && !uc.IsCompleted)
            {
                uc.IsCompleted = true;
                uc.CompletedAt = DateTime.UtcNow;
            }
        }

        await _context.SaveChangesAsync();
        return MapToUserChallengeDto(uc);
    }

    public async Task<bool> LeaveChallengeAsync(int id, int userId)
    {
        var uc = await _context.UserChallenges
            .FirstOrDefaultAsync(uc => uc.Id == id && uc.UserId == userId);
        if (uc == null) return false;

        _context.UserChallenges.Remove(uc);
        await _context.SaveChangesAsync();
        return true;
    }

    // ========== Summary ==========

    public async Task<object> GetSummaryAsync(int userId)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null) return new { error = "User not found" };

        var totalBadges = await _context.UserBadges.CountAsync(ub => ub.UserId == userId);
        var totalChallenges = await _context.UserChallenges.CountAsync(uc => uc.UserId == userId);
        var completedChallenges = await _context.UserChallenges
            .CountAsync(uc => uc.UserId == userId && uc.IsCompleted);

        var recentBadges = await _context.UserBadges
            .Where(ub => ub.UserId == userId)
            .OrderByDescending(ub => ub.EarnedAt)
            .Take(3)
            .Include(ub => ub.Badge)
            .Select(ub => new
            {
                id = ub.Badge.Id, name = ub.Badge.Name,
                icon = ub.Badge.Icon, earnedAt = ub.EarnedAt
            })
            .ToListAsync();

        return new
        {
            total_badges = totalBadges,
            total_challenges = totalChallenges,
            completed_challenges = completedChallenges,
            active_challenges = totalChallenges - completedChallenges,
            recent_badges = recentBadges,
            // User stats (snake_case for frontend compatibility)
            eco_score = user.EcoScore,
            current_streak = user.CurrentStreak,
            longest_streak = user.LongestStreak,
            total_co2_saved = user.TotalCO2Saved,
            level = user.Level,
            experience_points = user.ExperiencePoints,
            total_points = user.ExperiencePoints // Alias for frontend
        };
    }

    // ========== Mapping Helpers ==========

    private static ChallengeDto MapToChallengeDto(Challenge c) => new()
    {
        Id = c.Id, Title = c.Title, Description = c.Description,
        ChallengeType = c.ChallengeType, TargetValue = c.TargetValue,
        TargetUnit = c.TargetUnit, PointsReward = c.PointsReward,
        StartDate = c.StartDate, EndDate = c.EndDate, IsActive = c.IsActive
    };

    private static UserChallengeDto MapToUserChallengeDto(UserChallenge uc) => new()
    {
        Id = uc.Id,
        Challenge = MapToChallengeDto(uc.Challenge),
        CurrentProgress = uc.CurrentProgress,
        IsCompleted = uc.IsCompleted,
        ProgressPercentage = uc.ProgressPercentage,
        JoinedAt = uc.JoinedAt,
        CompletedAt = uc.CompletedAt
    };

    // EF-translatable version for LINQ projections
    private static UserChallengeDto MapToUserChallengeDtoStatic(UserChallenge uc) => new()
    {
        Id = uc.Id,
        Challenge = new ChallengeDto
        {
            Id = uc.Challenge.Id, Title = uc.Challenge.Title,
            Description = uc.Challenge.Description, ChallengeType = uc.Challenge.ChallengeType,
            TargetValue = uc.Challenge.TargetValue, TargetUnit = uc.Challenge.TargetUnit,
            PointsReward = uc.Challenge.PointsReward, StartDate = uc.Challenge.StartDate,
            EndDate = uc.Challenge.EndDate, IsActive = uc.Challenge.IsActive
        },
        CurrentProgress = uc.CurrentProgress,
        IsCompleted = uc.IsCompleted,
        CompletedAt = uc.CompletedAt,
        JoinedAt = uc.JoinedAt
    };

    // ========== Badge Award Logic ==========
    
    public async Task CheckAndAwardBadgesAsync(int userId)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null) return;
        
        var allBadges = await _context.Badges.Where(b => b.IsActive).ToListAsync();
        var earnedBadgeIds = await _context.UserBadges
            .Where(ub => ub.UserId == userId)
            .Select(ub => ub.BadgeId)
            .ToListAsync();
        
        foreach (var badge in allBadges)
        {
            if (earnedBadgeIds.Contains(badge.Id))
                continue;
            
            bool earned = badge.RequirementType switch
            {
                "activities_count" => await CheckActivitiesCount(userId, badge),
                "co2_saved" => await CheckCO2Saved(userId, badge),
                "streak" => CheckStreak(user, badge),
                "level" => CheckLevel(user, badge),
                _ => false
            };
            
            if (earned)
            {
                var userBadge = new UserBadge
                {
                    UserId = userId,
                    BadgeId = badge.Id
                };
                
                _context.UserBadges.Add(userBadge);
                user.ExperiencePoints += badge.PointsReward;
            }
        }
        
        await _context.SaveChangesAsync();
    }
    
    public async Task UpdateChallengeProgressAsync(int userId)
    {
        var activeChallenges = await _context.UserChallenges
            .Include(uc => uc.Challenge)
            .Where(uc => uc.UserId == userId && !uc.IsCompleted)
            .ToListAsync();
        
        foreach (var userChallenge in activeChallenges)
        {
            var challenge = userChallenge.Challenge;
            
            // Calculate progress based on challenge type
            double progress = await CalculateChallengeProgress(userId, challenge);
            
            userChallenge.CurrentProgress = progress;
            
            if (progress >= challenge.TargetValue && !userChallenge.IsCompleted)
            {
                userChallenge.IsCompleted = true;
                userChallenge.CompletedAt = DateTime.UtcNow;
                
                var user = await _context.Users.FindAsync(userId);
                if (user != null)
                {
                    user.ExperiencePoints += challenge.PointsReward;
                }
            }
        }
        
        await _context.SaveChangesAsync();
    }
    
    private async Task<bool> CheckActivitiesCount(int userId, Badge badge)
    {
        var count = await _context.Activities
            .Where(a => a.UserId == userId)
            .CountAsync();
        
        return count >= badge.RequirementValue;
    }
    
    private async Task<bool> CheckCO2Saved(int userId, Badge badge)
    {
        var totalSaved = Math.Abs(await _context.Activities
            .Where(a => a.UserId == userId && a.CO2Impact < 0)
            .SumAsync(a => a.CO2Impact));
        
        return totalSaved >= badge.RequirementValue;
    }
    
    private bool CheckStreak(User user, Badge badge)
    {
        return user.CurrentStreak >= badge.RequirementValue;
    }
    
    private bool CheckLevel(User user, Badge badge)
    {
        return user.Level >= badge.RequirementValue;
    }
    
    private async Task<double> CalculateChallengeProgress(int userId, Challenge challenge)
    {
        var query = _context.Activities.Where(a => 
            a.UserId == userId && 
            a.ActivityDate >= challenge.StartDate && 
            a.ActivityDate <= challenge.EndDate);
        
        if (challenge.TargetActivityTypeId.HasValue)
        {
            query = query.Where(a => a.ActivityTypeId == challenge.TargetActivityTypeId.Value);
        }
        
        if (challenge.TargetCategoryId.HasValue)
        {
            query = query.Where(a => a.ActivityType.CategoryId == challenge.TargetCategoryId.Value);
        }
        
        return challenge.TargetUnit.ToLower() switch
        {
            "activities" => await query.CountAsync(),
            "km" => await query.SumAsync(a => a.Quantity),
            "kg co2" => Math.Abs(await query.Where(a => a.CO2Impact < 0).SumAsync(a => a.CO2Impact)),
            _ => 0
        };
    }
}
