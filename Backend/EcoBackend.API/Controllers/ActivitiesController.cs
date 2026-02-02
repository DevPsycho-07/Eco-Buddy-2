using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/activities")]
[Authorize]
public class ActivitiesController : ControllerBase
{
    private readonly EcoDbContext _context;
    
    public ActivitiesController(EcoDbContext context)
    {
        _context = context;
    }
    
    [HttpGet("categories")]
    public async Task<IActionResult> GetCategories()
    {
        var categories = await _context.ActivityCategories
            .Include(c => c.ActivityTypes)
            .ToListAsync();
        
        var dtos = categories.Select(c => new ActivityCategoryDto
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
        
        return Ok(dtos);
    }
    
    [HttpGet("types")]
    public async Task<IActionResult> GetActivityTypes([FromQuery] int? category)
    {
        var query = _context.ActivityTypes.Include(at => at.Category).AsQueryable();
        
        if (category.HasValue)
        {
            query = query.Where(at => at.CategoryId == category.Value);
        }
        
        var types = await query.ToListAsync();
        
        var dtos = types.Select(at => new ActivityTypeDto
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
        
        return Ok(dtos);
    }
    
    [HttpGet]
    public async Task<IActionResult> GetActivities(
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate,
        [FromQuery] int? category)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
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
        
        var dtos = activities.Select(MapToActivityDto).ToList();
        
        return Ok(dtos);
    }
    
    [HttpGet("{id}")]
    public async Task<IActionResult> GetActivity(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var activity = await _context.Activities
            .Include(a => a.ActivityType)
            .ThenInclude(at => at.Category)
            .FirstOrDefaultAsync(a => a.Id == id && a.UserId == userId);
        
        if (activity == null)
        {
            return NotFound();
        }
        
        return Ok(MapToActivityDto(activity));
    }
    
    [HttpPost]
    public async Task<IActionResult> CreateActivity([FromBody] ActivityCreateDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var activityType = await _context.ActivityTypes.FindAsync(dto.ActivityTypeId);
        if (activityType == null)
        {
            return BadRequest(new { error = "Invalid activity type" });
        }
        
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
        await UpdateUserStats(userId, activity);
        
        activity = await _context.Activities
            .Include(a => a.ActivityType)
            .ThenInclude(at => at.Category)
            .FirstAsync(a => a.Id == activity.Id);
        
        return CreatedAtAction(nameof(GetActivity), new { id = activity.Id }, MapToActivityDto(activity));
    }
    
    [HttpGet("today")]
    public async Task<IActionResult> GetTodayActivities()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var today = DateTime.UtcNow.Date;
        
        var activities = await _context.Activities
            .Include(a => a.ActivityType)
            .ThenInclude(at => at.Category)
            .Where(a => a.UserId == userId && a.ActivityDate == today)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync();
        
        var dtos = activities.Select(MapToActivityDto).ToList();
        
        return Ok(dtos);
    }
    
    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary([FromQuery] int days = 7)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
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
        
        return Ok(new ActivitySummaryDto
        {
            StartDate = startDate,
            EndDate = endDate,
            TotalActivities = totalActivities,
            TotalPoints = totalPoints,
            TotalCO2Saved = totalCO2Saved,
            TotalCO2Emitted = totalCO2Emitted,
            ByCategory = byCategory
        });
    }
    
    [HttpGet("tips")]
    public async Task<IActionResult> GetTips([FromQuery] int? category)
    {
        var query = _context.Tips.Where(t => t.IsActive).AsQueryable();
        
        if (category.HasValue)
        {
            query = query.Where(t => t.CategoryId == category.Value);
        }
        
        var tips = await query.OrderByDescending(t => t.Priority).ToListAsync();
        
        var dtos = tips.Select(t => new TipDto
        {
            Id = t.Id,
            Title = t.Title,
            Content = t.Content,
            ImpactDescription = t.ImpactDescription,
            Priority = t.Priority
        }).ToList();
        
        return Ok(dtos);
    }
    
    // Alternative routes with /log/ and /tips/daily/ prefixes for frontend compatibility
    [HttpGet("log/today")]
    public Task<IActionResult> GetTodayActivitiesAlt() => GetTodayActivities();
    
    [HttpGet("log/summary")]
    public Task<IActionResult> GetSummaryAlt([FromQuery] int days = 7) => GetSummary(days);
    
    [HttpGet("tips/daily")]
    public async Task<IActionResult> GetDailyTip()
    {
        var tips = await _context.Tips
            .Where(t => t.IsActive)
            .ToListAsync();
        
        if (!tips.Any())
        {
            return Ok(new TipDto
            {
                Id = 0,
                Title = "Keep Going!",
                Content = "Every small action counts towards a greener future.",
                ImpactDescription = "Your efforts make a difference!",
                Priority = 1
            });
        }
        
        // Select random tip in memory
        var random = new Random();
        var tip = tips[random.Next(tips.Count)];
        
        return Ok(new TipDto
        {
            Id = tip.Id,
            Title = tip.Title,
            Content = tip.Content,
            ImpactDescription = tip.ImpactDescription,
            Priority = tip.Priority
        });
    }
    
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteActivity(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var activity = await _context.Activities
            .FirstOrDefaultAsync(a => a.Id == id && a.UserId == userId);
        
        if (activity == null)
        {
            return NotFound();
        }
        
        _context.Activities.Remove(activity);
        await _context.SaveChangesAsync();
        
        return NoContent();
    }
    
    private async Task UpdateUserStats(int userId, Activity activity)
    {
        var user = await _context.Users.FindAsync(userId);
        if (user == null) return;
        
        // Get or create daily score
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
        
        // Recalculate daily stats
        var dailyActivities = await _context.Activities
            .Where(a => a.UserId == userId && a.ActivityDate == activity.ActivityDate)
            .ToListAsync();
        
        var co2Saved = Math.Abs(dailyActivities.Where(a => a.CO2Impact < 0).Sum(a => a.CO2Impact));
        var co2Emitted = dailyActivities.Where(a => a.CO2Impact > 0).Sum(a => a.CO2Impact);
        
        dailyScore.CO2Saved = co2Saved;
        dailyScore.CO2Emitted = co2Emitted;
        dailyScore.Score = dailyActivities.Sum(a => a.PointsEarned);
        
        // Update user's total stats
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
