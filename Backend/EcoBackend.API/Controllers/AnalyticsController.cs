using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EcoBackend.Infrastructure.Data;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/analytics")]
[Authorize]
public class AnalyticsController : ControllerBase
{
    private readonly EcoDbContext _context;
    
    public AnalyticsController(EcoDbContext context)
    {
        _context = context;
    }
    
    [HttpGet("weekly")]
    public async Task<IActionResult> GetWeeklyReport([FromQuery] DateTime? weekStart)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var targetWeekStart = weekStart ?? GetStartOfWeek(DateTime.UtcNow);
        
        var report = await _context.WeeklyReports
            .FirstOrDefaultAsync(wr => wr.UserId == userId && wr.WeekStart == targetWeekStart);
        
        if (report == null)
        {
            return NotFound(new { message = "No weekly report found for this date" });
        }
        
        return Ok(report);
    }
    
    [HttpGet("monthly")]
    public async Task<IActionResult> GetMonthlyReport([FromQuery] int? year, [FromQuery] int? month)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var targetYear = year ?? DateTime.UtcNow.Year;
        var targetMonth = month ?? DateTime.UtcNow.Month;
        
        var report = await _context.MonthlyReports
            .FirstOrDefaultAsync(mr => mr.UserId == userId && mr.Year == targetYear && mr.Month == targetMonth);
        
        if (report == null)
        {
            return NotFound(new { message = "No monthly report found for this period" });
        }
        
        return Ok(report);
    }
    
    [HttpGet("dashboard")]
    public async Task<IActionResult> GetDashboard()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var today = DateTime.UtcNow.Date;
        var weekStart = GetStartOfWeek(today);
        var monthStart = new DateTime(today.Year, today.Month, 1);
        
        // Today's stats
        var todayScore = await _context.DailyScores
            .FirstOrDefaultAsync(ds => ds.UserId == userId && ds.Date == today);
        
        // Week stats
        var weekActivities = await _context.Activities
            .Where(a => a.UserId == userId && a.ActivityDate >= weekStart && a.ActivityDate <= today)
            .ToListAsync();
        
        // Month stats
        var monthActivities = await _context.Activities
            .Where(a => a.UserId == userId && a.ActivityDate >= monthStart && a.ActivityDate <= today)
            .ToListAsync();
        
        var user = await _context.Users.FindAsync(userId);
        
        return Ok(new
        {
            today = new
            {
                score = todayScore?.Score ?? 0,
                co2Saved = todayScore?.CO2Saved ?? 0,
                co2Emitted = todayScore?.CO2Emitted ?? 0,
                steps = todayScore?.Steps ?? 0
            },
            week = new
            {
                totalActivities = weekActivities.Count,
                totalPoints = weekActivities.Sum(a => a.PointsEarned),
                totalCO2Saved = Math.Abs(weekActivities.Where(a => a.CO2Impact < 0).Sum(a => a.CO2Impact))
            },
            month = new
            {
                totalActivities = monthActivities.Count,
                totalPoints = monthActivities.Sum(a => a.PointsEarned),
                totalCO2Saved = Math.Abs(monthActivities.Where(a => a.CO2Impact < 0).Sum(a => a.CO2Impact))
            },
            user = new
            {
                level = user?.Level ?? 1,
                experiencePoints = user?.ExperiencePoints ?? 0,
                totalCO2Saved = user?.TotalCO2Saved ?? 0,
                currentStreak = user?.CurrentStreak ?? 0
            }
        });
    }
    
    private DateTime GetStartOfWeek(DateTime date)
    {
        int diff = (7 + (date.DayOfWeek - DayOfWeek.Monday)) % 7;
        return date.AddDays(-1 * diff).Date;
    }
    
    [HttpGet("stats")]
    public async Task<IActionResult> GetStats([FromQuery] string period = "week")
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var now = DateTime.UtcNow;
        var startDate = period switch
        {
            "today" => now.Date,
            "week" => now.AddDays(-7),
            "month" => now.AddMonths(-1),
            "year" => now.AddYears(-1),
            _ => now.AddDays(-7)
        };
        
        var activities = await _context.Activities
            .Where(a => a.UserId == userId && a.ActivityDate >= startDate.Date)
            .ToListAsync();
        
        var totalActivities = activities.Count;
        var totalPoints = activities.Sum(a => a.PointsEarned);
        var totalCO2Saved = Math.Abs(activities.Where(a => a.CO2Impact < 0).Sum(a => a.CO2Impact));
        var totalCO2Emitted = activities.Where(a => a.CO2Impact > 0).Sum(a => a.CO2Impact);
        
        return Ok(new
        {
            period,
            startDate,
            endDate = now,
            totalActivities,
            totalPoints,
            totalCO2Saved,
            totalCO2Emitted,
            netCO2Impact = totalCO2Emitted - totalCO2Saved
        });
    }
    
    [HttpGet("comparison")]
    public async Task<IActionResult> GetComparison()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var now = DateTime.UtcNow;
        
        // Current week vs previous week
        var thisWeekStart = now.AddDays(-7);
        var lastWeekStart = now.AddDays(-14);
        
        var thisWeekActivities = await _context.Activities
            .Where(a => a.UserId == userId && a.ActivityDate >= thisWeekStart.Date)
            .ToListAsync();
        
        var lastWeekActivities = await _context.Activities
            .Where(a => a.UserId == userId && a.ActivityDate >= lastWeekStart.Date && a.ActivityDate < thisWeekStart.Date)
            .ToListAsync();
        
        var thisWeekPoints = thisWeekActivities.Sum(a => a.PointsEarned);
        var lastWeekPoints = lastWeekActivities.Sum(a => a.PointsEarned);
        var pointsChange = lastWeekPoints > 0 ? ((thisWeekPoints - lastWeekPoints) / (double)lastWeekPoints * 100) : 0;
        
        var thisWeekCO2 = Math.Abs(thisWeekActivities.Where(a => a.CO2Impact < 0).Sum(a => a.CO2Impact));
        var lastWeekCO2 = Math.Abs(lastWeekActivities.Where(a => a.CO2Impact < 0).Sum(a => a.CO2Impact));
        var co2Change = lastWeekCO2 > 0 ? ((thisWeekCO2 - lastWeekCO2) / lastWeekCO2 * 100) : 0;
        
        return Ok(new
        {
            thisWeek = new
            {
                activities = thisWeekActivities.Count,
                points = thisWeekPoints,
                co2Saved = thisWeekCO2
            },
            lastWeek = new
            {
                activities = lastWeekActivities.Count,
                points = lastWeekPoints,
                co2Saved = lastWeekCO2
            },
            changes = new
            {
                activitiesChange = lastWeekActivities.Count > 0 ? ((thisWeekActivities.Count - lastWeekActivities.Count) / (double)lastWeekActivities.Count * 100) : 0,
                pointsChange,
                co2Change
            }
        });
    }
}
