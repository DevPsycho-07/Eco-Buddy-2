using EcoBackend.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EcoBackend.API.Services;

/// <summary>
/// Computes a user's CurrentStreak / LongestStreak / LastActivityDate from
/// their Activity history. The cron job is no longer authoritative — these
/// helpers run on activity create and on every read path that surfaces a streak,
/// so the value is always correct without depending on background jobs.
/// </summary>
public static class StreakCalculator
{
    /// <summary>
    /// Full recompute: walks the user's distinct activity dates and finds the
    /// longest run of consecutive days ending today or yesterday.
    /// Call after creating or deleting an activity.
    /// </summary>
    public static async Task RecomputeAsync(EcoDbContext context, int userId)
    {
        var user = await context.Users.FindAsync(userId);
        if (user == null) return;

        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        var dates = await context.Activities
            .Where(a => a.UserId == userId)
            .Select(a => a.ActivityDate)
            .Distinct()
            .ToListAsync();

        var distinctDays = dates
            .Select(d => DateOnly.FromDateTime(d))
            .Distinct()
            .OrderByDescending(d => d)
            .ToList();

        if (distinctDays.Count == 0)
        {
            user.CurrentStreak = 0;
            user.LastActivityDate = null;
            await context.SaveChangesAsync();
            return;
        }

        var mostRecent = distinctDays[0];
        var gapFromToday = today.DayNumber - mostRecent.DayNumber;

        int streak;
        if (gapFromToday > 1)
        {
            streak = 0;
        }
        else
        {
            streak = 1;
            for (int i = 1; i < distinctDays.Count; i++)
            {
                if (distinctDays[i - 1].DayNumber - distinctDays[i].DayNumber == 1)
                    streak++;
                else
                    break;
            }
        }

        user.CurrentStreak = streak;
        user.LastActivityDate = mostRecent;
        if (streak > user.LongestStreak)
            user.LongestStreak = streak;

        await context.SaveChangesAsync();
    }

    /// <summary>
    /// Cheap consistency check for read paths. Three cases:
    ///   1. LastActivityDate is set and gap > 1 → reset CurrentStreak to 0.
    ///   2. LastActivityDate is null but activities exist (data created before
    ///      this streak system, or via SQL/migration that bypassed ActivityService)
    ///      → trigger a full RecomputeAsync so the streak heals on next read.
    ///   3. LastActivityDate is null and no activities → ensure CurrentStreak is 0.
    /// </summary>
    public static async Task ReconcileAsync(EcoDbContext context, int userId)
    {
        var user = await context.Users.FindAsync(userId);
        if (user == null) return;

        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        if (user.LastActivityDate == null)
        {
            var hasActivity = await context.Activities.AnyAsync(a => a.UserId == userId);
            if (hasActivity)
            {
                await RecomputeAsync(context, userId);
                return;
            }

            if (user.CurrentStreak != 0)
            {
                user.CurrentStreak = 0;
                await context.SaveChangesAsync();
            }
            return;
        }

        var gap = today.DayNumber - user.LastActivityDate.Value.DayNumber;
        if (gap > 1 && user.CurrentStreak != 0)
        {
            user.CurrentStreak = 0;
            await context.SaveChangesAsync();
        }
    }
}
