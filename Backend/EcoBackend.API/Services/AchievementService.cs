using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EcoBackend.API.Services;

public class AchievementService
{
    private readonly EcoDbContext _context;
    
    public AchievementService(EcoDbContext context)
    {
        _context = context;
    }
    
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
