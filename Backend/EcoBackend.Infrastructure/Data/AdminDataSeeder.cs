using EcoBackend.Core.Entities;
using Microsoft.EntityFrameworkCore;

namespace EcoBackend.Infrastructure.Data;

/// <summary>
/// Seeds additional comprehensive dummy data for the admin user
/// </summary>
public static class AdminDataSeeder
{
    public static async Task SeedAdminDummyDataAsync(EcoDbContext context)
    {
        var adminEmail = "admin@eco.com";
        var admin = await context.Users.FirstOrDefaultAsync(u => u.Email == adminEmail);

        if (admin == null)
        {
            Console.WriteLine($"❌ Admin user {adminEmail} not found. Please run the application first to create the admin user.");
            return;
        }

        Console.WriteLine($"📦 Seeding additional dummy data for {adminEmail}...");
        var userId = admin.Id;

        // Get activity types
        var activityTypes = await context.ActivityTypes.ToListAsync();
        if (activityTypes.Count == 0)
        {
            Console.WriteLine("❌ No activity types found. Please ensure the database is properly seeded.");
            return;
        }

        // Seed more activities (30 days of varied activities)
        await SeedActivitiesAsync(context, userId, activityTypes);

        // Seed more daily scores (30 days)
        await SeedDailyScoresAsync(context, userId);

        // Seed more goals
        await SeedGoalsAsync(context, userId);

        // Seed more trips
        await SeedTripsAsync(context, userId);

        // Seed user challenges
        await SeedUserChallengesAsync(context, userId);

        // Add more badges
        await SeedUserBadgesAsync(context, userId);

        // Update user profile with enhanced stats
        await UpdateUserProfileAsync(context, admin);

        Console.WriteLine($"✅ Successfully seeded comprehensive dummy data for {adminEmail}!");
    }

    private static async Task SeedActivitiesAsync(EcoDbContext context, int userId, List<ActivityType> activityTypes)
    {
        // Delete existing activities to avoid duplicates
        var existingActivities = context.Activities.Where(a => a.UserId == userId);
        context.Activities.RemoveRange(existingActivities);
        await context.SaveChangesAsync();

        var activities = new List<Activity>();
        var random = new Random(42); // Fixed seed for reproducibility

        var activityData = new[]
        {
            ("Walking", 3.0, 8.0, "Morning walk"),
            ("Cycling", 5.0, 15.0, "Bike commute"),
            ("Public Transit", 10.0, 20.0, "Bus ride"),
            ("Vegan Meal", 1.0, 1.0, "Plant-based meal"),
            ("Vegetarian Meal", 1.0, 1.0, "Veggie meal"),
            ("Local Produce", 1.0, 1.0, "Farmers market visit"),
            ("Recycling", 1.0, 1.0, "Recycled waste"),
            ("Composting", 1.0, 1.0, "Composted food scraps"),
            ("LED Lighting", 1.0, 5.0, "Used LED bulbs"),
            ("Cold Wash Laundry", 1.0, 1.0, "Cold water laundry"),
            ("Second-hand Purchase", 1.0, 1.0, "Bought second-hand"),
            ("Reusable Bags", 1.0, 1.0, "Used reusable bags"),
            ("Water Saving", 1.0, 5.0, "Saved water"),
            ("Electric Vehicle", 10.0, 30.0, "EV ride"),
            ("Carpool", 5.0, 15.0, "Shared ride")
        };

        // Generate 30 days of activities
        for (int day = 30; day >= 0; day--)
        {
            var date = DateTime.UtcNow.AddDays(-day);
            var activitiesPerDay = random.Next(3, 7); // 3-6 activities per day

            for (int i = 0; i < activitiesPerDay; i++)
            {
                var activityInfo = activityData[random.Next(activityData.Length)];
                var activityType = activityTypes.FirstOrDefault(at => at.Name == activityInfo.Item1);
                
                if (activityType != null)
                {
                    var quantity = activityInfo.Item2 + (random.NextDouble() * (activityInfo.Item3 - activityInfo.Item2));
                    var co2Impact = activityType.CO2Impact * quantity;
                    var points = (int)(activityType.Points * quantity);

                    activities.Add(new Activity
                    {
                        UserId = userId,
                        ActivityTypeId = activityType.Id,
                        Quantity = Math.Round(quantity, 2),
                        Unit = GetActivityUnit(activityType.Name),
                        Notes = $"{activityInfo.Item4} - Day {day}",
                        CO2Impact = co2Impact,
                        PointsEarned = points,
                        ActivityDate = date.Date,
                        ActivityTime = new TimeSpan(6 + i * 2, random.Next(60), 0),
                        CreatedAt = date,
                        IsAutoDetected = random.Next(100) < 30 // 30% auto-detected
                    });
                }
            }
        }

        context.Activities.AddRange(activities);
        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Added {activities.Count} activities for the past 30 days");
    }

    private static async Task SeedDailyScoresAsync(EcoDbContext context, int userId)
    {
        // Delete existing daily scores to avoid duplicates
        var existingScores = context.DailyScores.Where(ds => ds.UserId == userId);
        context.DailyScores.RemoveRange(existingScores);
        await context.SaveChangesAsync();

        var dailyScores = new List<DailyScore>();
        var random = new Random(42);

        for (int day = 30; day >= 0; day--)
        {
            var date = DateTime.UtcNow.AddDays(-day).Date;
            var baseScore = 70 + random.Next(30); // 70-100 score
            var co2Emitted = 3.0 + (random.NextDouble() * 5.0); // 3-8 kg
            var co2Saved = 2.0 + (random.NextDouble() * 6.0); // 2-8 kg
            var steps = 5000 + random.Next(10000); // 5000-15000 steps

            dailyScores.Add(new DailyScore
            {
                UserId = userId,
                Date = date,
                Score = baseScore,
                CO2Emitted = Math.Round(co2Emitted, 2),
                CO2Saved = Math.Round(co2Saved, 2),
                Steps = steps
            });
        }

        context.DailyScores.AddRange(dailyScores);
        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Added {dailyScores.Count} daily scores for the past 30 days");
    }

    private static async Task SeedGoalsAsync(EcoDbContext context, int userId)
    {
        // Delete existing goals
        var existingGoals = context.UserGoals.Where(g => g.UserId == userId);
        context.UserGoals.RemoveRange(existingGoals);
        await context.SaveChangesAsync();

        var goals = new List<UserGoal>
        {
            new()
            {
                UserId = userId,
                Title = "Walk 100 km This Month",
                Description = "Complete 100 kilometers of walking activities",
                TargetValue = 100,
                CurrentValue = 65.5,
                Unit = "km",
                IsCompleted = false,
                Deadline = DateTime.UtcNow.AddDays(30),
                CreatedAt = DateTime.UtcNow.AddDays(-30)
            },
            new()
            {
                UserId = userId,
                Title = "30 Vegan Meals",
                Description = "Eat 30 vegan meals this month",
                TargetValue = 30,
                CurrentValue = 22,
                Unit = "meals",
                IsCompleted = false,
                Deadline = DateTime.UtcNow.AddDays(15),
                CreatedAt = DateTime.UtcNow.AddDays(-45)
            },
            new()
            {
                UserId = userId,
                Title = "Save 200 kg CO2",
                Description = "Reduce carbon emissions by 200 kg",
                TargetValue = 200,
                CurrentValue = 145.8,
                Unit = "kg CO2",
                IsCompleted = false,
                Deadline = DateTime.UtcNow.AddDays(60),
                CreatedAt = DateTime.UtcNow.AddDays(-60)
            },
            new()
            {
                UserId = userId,
                Title = "Daily Recycling Habit",
                Description = "Recycle at least once every day for 30 days",
                TargetValue = 30,
                CurrentValue = 18,
                Unit = "days",
                IsCompleted = false,
                Deadline = DateTime.UtcNow.AddDays(45),
                CreatedAt = DateTime.UtcNow.AddDays(-30)
            },
            new()
            {
                UserId = userId,
                Title = "Zero Car Days",
                Description = "Avoid car travel for 20 days",
                TargetValue = 20,
                CurrentValue = 14,
                Unit = "days",
                IsCompleted = false,
                Deadline = DateTime.UtcNow.AddDays(30),
                CreatedAt = DateTime.UtcNow.AddDays(-15)
            },
            new()
            {
                UserId = userId,
                Title = "Plant 10 Trees",
                Description = "Participate in tree planting activities",
                TargetValue = 10,
                CurrentValue = 3,
                Unit = "trees",
                IsCompleted = false,
                Deadline = DateTime.UtcNow.AddDays(90),
                CreatedAt = DateTime.UtcNow.AddDays(-20)
            }
        };

        context.UserGoals.AddRange(goals);
        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Added {goals.Count} goals");
    }

    private static async Task SeedTripsAsync(EcoDbContext context, int userId)
    {
        // Delete existing trips
        var existingTrips = context.Trips.Where(t => t.UserId == userId);
        context.Trips.RemoveRange(existingTrips);
        await context.SaveChangesAsync();

        var trips = new List<Trip>();
        var random = new Random(42);
        var transportModes = new[] { "walking", "cycling", "bus", "train", "car", "carpool" };
        var locations = new[]
        {
            ("Home", 40.7128, -74.0060),
            ("Office", 40.7580, -73.9855),
            ("Gym", 40.7489, -73.9680),
            ("Grocery Store", 40.7614, -73.9776),
            ("Park", 40.7829, -73.9654),
            ("Library", 40.7539, -73.9841)
        };

        // Generate 20 trips over the past 2 weeks
        for (int day = 14; day >= 0; day--)
        {
            var date = DateTime.UtcNow.AddDays(-day);
            var tripsPerDay = random.Next(1, 4); // 1-3 trips per day

            for (int i = 0; i < tripsPerDay; i++)
            {
                var mode = transportModes[random.Next(transportModes.Length)];
                var distanceKm = 2.0 + (random.NextDouble() * 18.0); // 2-20 km
                var duration = (int)(distanceKm * (5 + random.Next(10))); // Variable speed
                
                var startLoc = locations[random.Next(locations.Length)];
                var endLoc = locations[random.Next(locations.Length)];
                
                var co2Emitted = Trip.CO2PerKm.ContainsKey(mode) ? Trip.CO2PerKm[mode] * distanceKm : 0;
                var co2Saved = mode == "walking" || mode == "cycling" ? 0.21 * distanceKm : 0; // Saved vs. car

                trips.Add(new Trip
                {
                    UserId = userId,
                    TransportMode = mode,
                    DistanceKm = Math.Round(distanceKm, 2),
                    DurationMinutes = duration,
                    StartLocation = startLoc.Item1,
                    StartLatitude = startLoc.Item2 + (random.NextDouble() - 0.5) * 0.01,
                    StartLongitude = startLoc.Item3 + (random.NextDouble() - 0.5) * 0.01,
                    EndLocation = endLoc.Item1,
                    EndLatitude = endLoc.Item2 + (random.NextDouble() - 0.5) * 0.01,
                    EndLongitude = endLoc.Item3 + (random.NextDouble() - 0.5) * 0.01,
                    CO2Emitted = Math.Round(co2Emitted, 2),
                    CO2Saved = Math.Round(co2Saved, 2),
                    TripDate = date.Date,
                    StartTime = new TimeSpan(7 + i * 3, random.Next(60), 0),
                    EndTime = new TimeSpan(7 + i * 3, random.Next(60) + duration, 0),
                    IsAutoDetected = random.Next(100) < 40, // 40% auto-detected
                    ConfidenceScore = 0.7 + (random.NextDouble() * 0.3),
                    CreatedAt = date
                });
            }
        }

        context.Trips.AddRange(trips);
        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Added {trips.Count} trips for the past 2 weeks");
    }

    private static async Task SeedUserChallengesAsync(EcoDbContext context, int userId)
    {
        // Get available challenges
        var challenges = await context.Challenges.Take(5).ToListAsync();
        
        if (challenges.Count == 0)
        {
            Console.WriteLine("⚠ No challenges found to join");
            return;
        }

        // Delete existing user challenges
        var existingChallenges = context.UserChallenges.Where(uc => uc.UserId == userId);
        context.UserChallenges.RemoveRange(existingChallenges);
        await context.SaveChangesAsync();

        var userChallenges = new List<UserChallenge>();
        var random = new Random(42);

        foreach (var challenge in challenges)
        {
            var progress = challenge.TargetValue * (0.3 + random.NextDouble() * 0.6); // 30-90% progress
            var isCompleted = random.Next(100) < 20; // 20% completed

            userChallenges.Add(new UserChallenge
            {
                UserId = userId,
                ChallengeId = challenge.Id,
                CurrentProgress = Math.Round(progress, 2),
                IsCompleted = isCompleted,
                CompletedAt = isCompleted ? DateTime.UtcNow.AddDays(-random.Next(15)) : null,
                JoinedAt = DateTime.UtcNow.AddDays(-random.Next(30, 60))
            });
        }

        context.UserChallenges.AddRange(userChallenges);
        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Added {userChallenges.Count} user challenges");
    }

    private static async Task SeedUserBadgesAsync(EcoDbContext context, int userId)
    {
        var badges = await context.Badges.ToListAsync();
        
        if (badges.Count == 0)
        {
            Console.WriteLine("⚠ No badges found");
            return;
        }

        // Delete existing user badges to avoid duplicates
        var existingBadges = context.UserBadges.Where(ub => ub.UserId == userId);
        context.UserBadges.RemoveRange(existingBadges);
        await context.SaveChangesAsync();

        var userBadges = new List<UserBadge>();
        var random = new Random(42);

        // Award random 8-12 badges
        var badgesToAward = random.Next(8, Math.Min(13, badges.Count + 1));
        var selectedBadges = badges.OrderBy(x => random.Next()).Take(badgesToAward);

        foreach (var badge in selectedBadges)
        {
            userBadges.Add(new UserBadge
            {
                UserId = userId,
                BadgeId = badge.Id,
                EarnedAt = DateTime.UtcNow.AddDays(-random.Next(1, 90))
            });
        }

        context.UserBadges.AddRange(userBadges);
        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Added {userBadges.Count} badges");
    }

    private static async Task UpdateUserProfileAsync(EcoDbContext context, User admin)
    {
        // Calculate totals from activities and daily scores
        var totalCO2Saved = await context.DailyScores
            .Where(ds => ds.UserId == admin.Id)
            .SumAsync(ds => ds.CO2Saved);

        var totalScore = await context.DailyScores
            .Where(ds => ds.UserId == admin.Id)
            .AverageAsync(ds => (double?)ds.Score) ?? 0;

        var totalActivities = await context.Activities
            .Where(a => a.UserId == admin.Id)
            .CountAsync();

        var totalPoints = await context.Activities
            .Where(a => a.UserId == admin.Id)
            .SumAsync(a => a.PointsEarned);

        // Update user profile
        admin.EcoScore = (int)totalScore;
        admin.TotalCO2Saved = Math.Round(totalCO2Saved, 2);
        admin.CurrentStreak = 25; // Assume an active streak
        admin.LongestStreak = 45;
        admin.ExperiencePoints = totalPoints;
        admin.Level = (totalPoints / 100) + 1;
        admin.UpdatedAt = DateTime.UtcNow;

        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Updated user profile:");
        Console.WriteLine($"  - Eco Score: {admin.EcoScore}");
        Console.WriteLine($"  - Total CO2 Saved: {admin.TotalCO2Saved} kg");
        Console.WriteLine($"  - Level: {admin.Level}");
        Console.WriteLine($"  - XP: {admin.ExperiencePoints}");
        Console.WriteLine($"  - Current Streak: {admin.CurrentStreak} days");
    }

    private static string GetActivityUnit(string activityName)
    {
        return activityName switch
        {
            "Walking" or "Cycling" or "Public Transit" or "Electric Vehicle" or "Carpool" => "km",
            "Vegan Meal" or "Vegetarian Meal" or "Chicken Meal" or "Beef Meal" => "meal",
            "Local Produce" or "Second-hand Purchase" => "purchase",
            "LED Lighting" or "Water Saving" => "hours",
            "Cold Wash Laundry" => "load",
            "Recycling" or "Composting" or "Reusable Bags" => "instance",
            "Plant a Tree" => "tree",
            _ => "instance"
        };
    }
}
