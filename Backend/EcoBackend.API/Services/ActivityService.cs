using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;
using Microsoft.EntityFrameworkCore;

namespace EcoBackend.API.Services;

public class ActivityService
{
    private readonly EcoDbContext _context;

    public ActivityService(EcoDbContext context)
    {
        _context = context;
    }

    // ========== Categories ==========

    public async Task<List<ActivityCategoryDto>> GetCategoriesAsync()
    {
        var categories = await _context.ActivityCategories
            .Include(c => c.ActivityTypes)
            .ToListAsync();

        return categories.Select(c => new ActivityCategoryDto
        {
            Id = c.Id,
            Name = c.Name,
            Icon = c.Icon,
            Color = c.Color,
            Description = c.Description,
            ActivityTypes = c.ActivityTypes.Select(at => new ActivityTypeDto
            {
                Id = at.Id,
                CategoryId = at.CategoryId,
                Name = at.Name,
                Icon = at.Icon,
                CO2Impact = at.CO2Impact,
                ImpactUnit = at.ImpactUnit,
                IsEcoFriendly = at.IsEcoFriendly,
                Points = at.Points
            }).ToList()
        }).ToList();
    }

    public async Task<ActivityCategoryDto?> GetCategoryByIdAsync(int id)
    {
        var category = await _context.ActivityCategories
            .Include(c => c.ActivityTypes)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (category == null) return null;

        return new ActivityCategoryDto
        {
            Id = category.Id,
            Name = category.Name,
            Icon = category.Icon,
            Color = category.Color,
            Description = category.Description,
            ActivityTypes = category.ActivityTypes.Select(at => new ActivityTypeDto
            {
                Id = at.Id,
                CategoryId = at.CategoryId,
                Name = at.Name,
                Icon = at.Icon,
                CO2Impact = at.CO2Impact,
                ImpactUnit = at.ImpactUnit,
                IsEcoFriendly = at.IsEcoFriendly,
                Points = at.Points
            }).ToList()
        };
    }

    // ========== Activity Types ==========

    public async Task<List<ActivityTypeDto>> GetActivityTypesAsync(int? categoryId)
    {
        var query = _context.ActivityTypes.AsQueryable();

        if (categoryId.HasValue)
            query = query.Where(at => at.CategoryId == categoryId.Value);

        var types = await query.ToListAsync();

        return types.Select(at => new ActivityTypeDto
        {
            Id = at.Id,
            CategoryId = at.CategoryId,
            Name = at.Name,
            Icon = at.Icon,
            CO2Impact = at.CO2Impact,
            ImpactUnit = at.ImpactUnit,
            IsEcoFriendly = at.IsEcoFriendly,
            Points = at.Points
        }).ToList();
    }

    public async Task<ActivityTypeDto?> GetActivityTypeByIdAsync(int id)
    {
        var activityType = await _context.ActivityTypes
            .Include(at => at.Category)
            .FirstOrDefaultAsync(at => at.Id == id);

        if (activityType == null) return null;

        return new ActivityTypeDto
        {
            Id = activityType.Id,
            CategoryId = activityType.CategoryId,
            Name = activityType.Name,
            Icon = activityType.Icon,
            CO2Impact = activityType.CO2Impact,
            ImpactUnit = activityType.ImpactUnit,
            IsEcoFriendly = activityType.IsEcoFriendly,
            Points = activityType.Points
        };
    }

    // ========== Activities CRUD ==========

    public async Task<List<ActivityDto>> GetActivitiesAsync(int userId, DateTime? startDate, DateTime? endDate, int? category)
    {
        var query = _context.Activities
            .Include(a => a.ActivityType)
            .ThenInclude(at => at.Category)
            .Where(a => a.UserId == userId);

        if (startDate.HasValue)
            query = query.Where(a => a.ActivityDate >= startDate.Value);
        if (endDate.HasValue)
            query = query.Where(a => a.ActivityDate <= endDate.Value);
        if (category.HasValue)
            query = query.Where(a => a.ActivityType.CategoryId == category.Value);

        var activities = await query.OrderByDescending(a => a.ActivityDate).ToListAsync();

        return activities.Select(MapToActivityDto).ToList();
    }

    public async Task<ActivityDto?> GetActivityByIdAsync(int id, int userId)
    {
        var activity = await _context.Activities
            .Include(a => a.ActivityType)
            .ThenInclude(at => at.Category)
            .FirstOrDefaultAsync(a => a.Id == id && a.UserId == userId);

        if (activity == null) return null;

        return MapToActivityDto(activity);
    }

    public async Task<ActivityDto> CreateActivityAsync(int userId, ActivityCreateDto dto)
    {
        var activityType = await _context.ActivityTypes.FindAsync(dto.ActivityTypeId);
        if (activityType == null)
            throw new ArgumentException("Invalid activity type");

        var activity = new Activity
        {
            UserId = userId,
            ActivityTypeId = dto.ActivityTypeId,
            Quantity = dto.Quantity,
            Unit = dto.Unit ?? "",
            Notes = dto.Notes ?? "",
            Latitude = dto.Latitude,
            Longitude = dto.Longitude,
            LocationName = dto.LocationName ?? "",
            ActivityDate = dto.ActivityDate,
            ActivityTime = dto.ActivityTime,
            CO2Impact = activityType.CO2Impact * dto.Quantity,
            PointsEarned = activityType.IsEcoFriendly ? (int)(activityType.Points * dto.Quantity) : 0
        };

        _context.Activities.Add(activity);
        await _context.SaveChangesAsync();

        // Update user stats
        await UpdateUserStatsAsync(userId, activity);

        activity = await _context.Activities
            .Include(a => a.ActivityType)
            .ThenInclude(at => at.Category)
            .FirstAsync(a => a.Id == activity.Id);

        return MapToActivityDto(activity);
    }

    public async Task<bool> DeleteActivityAsync(int id, int userId)
    {
        var activity = await _context.Activities
            .FirstOrDefaultAsync(a => a.Id == id && a.UserId == userId);

        if (activity == null) return false;

        _context.Activities.Remove(activity);
        await _context.SaveChangesAsync();
        return true;
    }

    // ========== Today & Summary ==========

    public async Task<List<ActivityDto>> GetTodayActivitiesAsync(int userId)
    {
        var today = DateTime.UtcNow.Date;

        var activities = await _context.Activities
            .Include(a => a.ActivityType)
            .ThenInclude(at => at.Category)
            .Where(a => a.UserId == userId && a.ActivityDate == today)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync();

        return activities.Select(MapToActivityDto).ToList();
    }

    public async Task<ActivitySummaryDto> GetSummaryAsync(int userId, int days)
    {
        var endDate = DateTime.UtcNow.Date;
        var startDate = days == 1 ? endDate : endDate.AddDays(-(days - 1));

        var activities = await _context.Activities
            .Include(a => a.ActivityType)
            .ThenInclude(at => at!.Category)
            .Where(a => a.UserId == userId && a.ActivityDate >= startDate && a.ActivityDate <= endDate)
            .ToListAsync();

        var totalActivities = activities.Count;
        var totalPoints = activities.Sum(a => a.PointsEarned);
        var totalCO2Saved = Math.Abs(activities.Where(a => a.CO2Impact < 0).Sum(a => a.CO2Impact));
        var totalCO2Emitted = activities.Where(a => a.CO2Impact > 0).Sum(a => a.CO2Impact);

        var byCategory = activities
            .Where(a => a.ActivityType?.Category != null)
            .GroupBy(a => a.ActivityType!.Category!.Name)
            .ToDictionary(
                g => g.Key,
                g => new CategoryStats
                {
                    Count = g.Count(),
                    CO2Impact = g.Sum(a => a.CO2Impact)
                }
            );

        return new ActivitySummaryDto
        {
            StartDate = startDate,
            EndDate = endDate,
            TotalActivities = totalActivities,
            TotalPoints = totalPoints,
            TotalCO2Saved = totalCO2Saved,
            TotalCO2Emitted = totalCO2Emitted,
            ByCategory = byCategory
        };
    }

    // ========== Tips ==========

    public async Task<List<TipDto>> GetTipsAsync(int? category)
    {
        var query = _context.Tips.Where(t => t.IsActive).AsQueryable();

        if (category.HasValue)
            query = query.Where(t => t.CategoryId == category.Value);

        var tips = await query.OrderByDescending(t => t.Priority).ToListAsync();

        return tips.Select(t => new TipDto
        {
            Id = t.Id,
            Title = t.Title,
            Content = t.Content,
            ImpactDescription = t.ImpactDescription,
            Priority = t.Priority
        }).ToList();
    }

    public async Task<TipDto?> GetTipByIdAsync(int id)
    {
        var tip = await _context.Tips.FirstOrDefaultAsync(t => t.Id == id);

        if (tip == null) return null;

        return new TipDto
        {
            Id = tip.Id,
            Title = tip.Title,
            Content = tip.Content,
            ImpactDescription = tip.ImpactDescription,
            Priority = tip.Priority
        };
    }

    public async Task<TipDto> GetDailyTipAsync()
    {
        var tips = await _context.Tips
            .Where(t => t.IsActive)
            .ToListAsync();

        if (!tips.Any())
        {
            return new TipDto
            {
                Id = 0,
                Title = "Keep Going!",
                Content = "Every small action counts towards a greener future.",
                ImpactDescription = "Your efforts make a difference!",
                Priority = 1
            };
        }

        var random = new Random();
        var tip = tips[random.Next(tips.Count)];

        return new TipDto
        {
            Id = tip.Id,
            Title = tip.Title,
            Content = tip.Content,
            ImpactDescription = tip.ImpactDescription,
            Priority = tip.Priority
        };
    }

    // ========== Activity History ==========

    public async Task<Dictionary<string, List<object>>> GetActivityHistoryAsync(int userId, int days)
    {
        var startDate = DateTime.UtcNow.Date.AddDays(-days);

        var activities = await _context.Activities
            .Where(a => a.UserId == userId && a.ActivityDate >= startDate)
            .Include(a => a.ActivityType)
            .ThenInclude(at => at.Category)
            .OrderByDescending(a => a.ActivityDate)
            .ThenByDescending(a => a.CreatedAt)
            .ToListAsync();

        return activities
            .GroupBy(a => a.ActivityDate.ToString("yyyy-MM-dd"))
            .ToDictionary(
                g => g.Key,
                g => g.Select(a => (object)new
                {
                    a.Id,
                    ActivityTypeId = a.ActivityTypeId,
                    ActivityTypeName = a.ActivityType.Name,
                    CategoryName = a.ActivityType.Category?.Name ?? "",
                    a.Quantity,
                    a.Unit,
                    a.Notes,
                    CO2Impact = a.CO2Impact,
                    PointsEarned = a.PointsEarned,
                    a.Latitude,
                    a.Longitude,
                    a.LocationName,
                    ActivityDate = a.ActivityDate.ToString("yyyy-MM-dd"),
                    a.ActivityTime,
                    a.IsAutoDetected,
                    a.CreatedAt
                }).ToList()
            );
    }

    // ========== Private Helpers ==========

    private async Task UpdateUserStatsAsync(int userId, Activity activity)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null) return;

        var dailyScore = await _context.DailyScores
            .FirstOrDefaultAsync(ds => ds.UserId == userId && ds.Date == activity.ActivityDate);

        if (dailyScore == null)
        {
            dailyScore = new DailyScore
            {
                UserId = userId,
                Date = activity.ActivityDate
            };
            _context.DailyScores.Add(dailyScore);
        }

        var dailyActivities = await _context.Activities
            .Where(a => a.UserId == userId && a.ActivityDate == activity.ActivityDate)
            .ToListAsync();

        var co2Saved = Math.Abs(dailyActivities.Where(a => a.CO2Impact < 0).Sum(a => a.CO2Impact));
        var co2Emitted = dailyActivities.Where(a => a.CO2Impact > 0).Sum(a => a.CO2Impact);

        dailyScore.CO2Saved = co2Saved;
        dailyScore.CO2Emitted = co2Emitted;
        dailyScore.Score = dailyActivities.Sum(a => a.PointsEarned);

        var totalSaved = Math.Abs(await _context.Activities
            .Where(a => a.UserId == userId && a.CO2Impact < 0)
            .SumAsync(a => a.CO2Impact));

        user.TotalCO2Saved = totalSaved;
        user.ExperiencePoints += activity.PointsEarned;
        user.CalculateLevel();

        await _context.SaveChangesAsync();
    }

    private ActivityDto MapToActivityDto(Activity activity)
    {
        return new ActivityDto
        {
            Id = activity.Id,
            UserId = activity.UserId,
            ActivityTypeId = activity.ActivityTypeId,
            Quantity = activity.Quantity,
            Unit = activity.Unit,
            Notes = activity.Notes,
            CO2Impact = activity.CO2Impact,
            PointsEarned = activity.PointsEarned,
            Latitude = activity.Latitude,
            Longitude = activity.Longitude,
            LocationName = activity.LocationName,
            ActivityDate = activity.ActivityDate,
            ActivityTime = activity.ActivityTime,
            IsAutoDetected = activity.IsAutoDetected,
            ActivityType = activity.ActivityType == null ? null! : new ActivityTypeDto
            {
                Id = activity.ActivityType.Id,
                CategoryId = activity.ActivityType.CategoryId,
                Name = activity.ActivityType.Name,
                Icon = activity.ActivityType.Icon,
                CO2Impact = activity.ActivityType.CO2Impact,
                ImpactUnit = activity.ActivityType.ImpactUnit,
                IsEcoFriendly = activity.ActivityType.IsEcoFriendly,
                Points = activity.ActivityType.Points,
                Category = activity.ActivityType.Category == null ? null! : new ActivityCategoryDto
                {
                    Id = activity.ActivityType.Category.Id,
                    Name = activity.ActivityType.Category.Name,
                    Icon = activity.ActivityType.Category.Icon,
                    Color = activity.ActivityType.Category.Color,
                    Description = activity.ActivityType.Category.Description
                }
            }
        };
    }
}
