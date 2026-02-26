using EcoBackend.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EcoBackend.API.Services;

public class AnalyticsService
{
    private readonly EcoDbContext _context;

    public AnalyticsService(EcoDbContext context)
    {
        _context = context;
    }

    public async Task<object?> GetWeeklyReportAsync(int userId, DateTime? weekStart)
    {
        var targetWeekStart = weekStart ?? GetStartOfWeek(DateTime.UtcNow);

        var report = await _context.WeeklyReports
            .FirstOrDefaultAsync(wr => wr.UserId == userId && wr.WeekStart == targetWeekStart);

        return report;
    }

    public async Task<object?> GetMonthlyReportAsync(int userId, int? year, int? month)
    {
        var targetYear = year ?? DateTime.UtcNow.Year;
        var targetMonth = month ?? DateTime.UtcNow.Month;

        var report = await _context.MonthlyReports
            .FirstOrDefaultAsync(mr => mr.UserId == userId && mr.Year == targetYear && mr.Month == targetMonth);

        return report;
    }

    public async Task<object> GetDashboardAsync(int userId)
    {
        var today = DateTime.UtcNow.Date;
        var weekStart = GetStartOfWeek(today);
        var monthStart = new DateTime(today.Year, today.Month, 1);

        var todayScore = await _context.DailyScores
            .FirstOrDefaultAsync(ds => ds.UserId == userId && ds.Date == today);

        var weekActivities = await _context.Activities
            .Where(a => a.UserId == userId && a.ActivityDate >= weekStart && a.ActivityDate <= today)
            .ToListAsync();

        var monthActivities = await _context.Activities
            .Where(a => a.UserId == userId && a.ActivityDate >= monthStart && a.ActivityDate <= today)
            .ToListAsync();

        var user = await _context.Users.FindAsync(userId);

        return new
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
        };
    }

    public async Task<object> GetStatsAsync(int userId, string period)
    {
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
            .Include(a => a.ActivityType)
            .ThenInclude(at => at!.Category)
            .Where(a => a.UserId == userId && a.ActivityDate >= startDate.Date)
            .ToListAsync();

        var totalActivities = activities.Count;
        var totalPoints = activities.Sum(a => a.PointsEarned);
        var totalCO2Saved = Math.Abs(activities.Where(a => a.CO2Impact < 0).Sum(a => a.CO2Impact));
        var totalCO2Emitted = activities.Where(a => a.CO2Impact > 0).Sum(a => a.CO2Impact);

        // Build by_category breakdown
        var byCategory = activities
            .GroupBy(a => a.ActivityType?.Category?.Name ?? "Other")
            .ToDictionary(
                g => g.Key,
                g => new
                {
                    count = g.Count(),
                    co2Impact = g.Sum(a => a.CO2Impact),
                    percentage = totalActivities > 0 ? Math.Round(g.Count() / (double)totalActivities * 100, 1) : 0
                });

        // Build daily trend
        var trend = activities
            .GroupBy(a => a.ActivityDate.ToString("yyyy-MM-dd"))
            .OrderBy(g => g.Key)
            .Select(g => new
            {
                date = g.Key,
                co2Impact = g.Sum(a => a.CO2Impact),
                activities = g.Count()
            })
            .ToList();

        return new
        {
            period,
            startDate = startDate.ToString("yyyy-MM-dd"),
            endDate = now.ToString("yyyy-MM-dd"),
            totalActivities,
            totalPoints,
            totalCO2Saved = totalCO2Saved,
            totalCO2Emitted = totalCO2Emitted,
            netImpact = totalCO2Emitted - totalCO2Saved,
            byCategory,
            trend
        };
    }

    public async Task<object> GetComparisonAsync(int userId)
    {
        // Get user's data
        var user = await _context.Users.FindAsync(userId);
        var userEcoScore = user?.EcoScore ?? 0;
        var userCO2Saved = user?.TotalCO2Saved ?? 0;

        // Get average stats across all users
        var allUsers = await _context.Users.ToListAsync();
        var avgEcoScore = allUsers.Any() ? allUsers.Average(u => u.EcoScore) : 0;
        var avgCO2Saved = allUsers.Any() ? allUsers.Average(u => u.TotalCO2Saved) : 0;

        // Calculate percentile
        var usersBelow = allUsers.Count(u => u.EcoScore < userEcoScore);
        var percentile = allUsers.Count > 0 ? Math.Round(usersBelow / (double)allUsers.Count * 100, 1) : 50;

        return new
        {
            user = new
            {
                ecoScore = userEcoScore,
                totalCO2Saved = userCO2Saved
            },
            average = new
            {
                ecoScore = avgEcoScore,
                totalCO2Saved = avgCO2Saved
            },
            percentile,
            comparison = new
            {
                scoreDiff = userEcoScore - avgEcoScore,
                co2Diff = userCO2Saved - avgCO2Saved
            }
        };
    }

    public async Task<(byte[] Content, string FileName)> ExportToCsvAsync(int userId, string period)
    {
        var now = DateTime.UtcNow;
        var startDate = period switch
        {
            "today" => now.Date,
            "week" => now.AddDays(-7),
            "month" => now.AddMonths(-1),
            "year" => now.AddYears(-1),
            "all" => DateTime.MinValue,
            _ => now.AddMonths(-1)
        };

        var activities = await _context.Activities
            .Include(a => a.ActivityType)
            .ThenInclude(at => at!.Category)
            .Where(a => a.UserId == userId && a.ActivityDate >= startDate.Date)
            .OrderByDescending(a => a.ActivityDate)
            .ThenByDescending(a => a.CreatedAt)
            .ToListAsync();

        var csv = new System.Text.StringBuilder();
        csv.AppendLine("Date,Activity Type,Category,Quantity,CO2 Impact (kg),Points Earned,Notes");

        foreach (var activity in activities)
        {
            var line = $"{activity.ActivityDate:yyyy-MM-dd}," +
                      $"\"{activity.ActivityType?.Name ?? "N/A"}\"," +
                      $"\"{activity.ActivityType?.Category?.Name ?? "N/A"}\"," +
                      $"{activity.Quantity}," +
                      $"{activity.CO2Impact:F2}," +
                      $"{activity.PointsEarned}," +
                      $"\"{activity.Notes?.Replace("\"", "\"\"") ?? ""}\"";
            csv.AppendLine(line);
        }

        var bytes = System.Text.Encoding.UTF8.GetBytes(csv.ToString());
        var fileName = $"eco_activities_{period}_{now:yyyyMMdd}.csv";

        return (bytes, fileName);
    }

    private DateTime GetStartOfWeek(DateTime date)
    {
        int diff = (7 + (date.DayOfWeek - DayOfWeek.Monday)) % 7;
        return date.AddDays(-1 * diff).Date;
    }
}
