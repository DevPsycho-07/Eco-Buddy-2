using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace EcoBackend.Infrastructure.Data;

public static class DbInitializer
{
    public static async Task SeedAsync(EcoDbContext context)
    {
        // Ensure database is created
        await context.Database.EnsureCreatedAsync();

        // Check if already seeded
        if (await context.ActivityCategories.AnyAsync())
        {
            return; // Database already seeded
        }

        Console.WriteLine("Seeding database...");

        // Seed Activity Categories
        var categories = new Dictionary<string, ActivityCategory>();
        var categoriesData = new[]
        {
            new { Name = "Transport", Icon = "directions_car", Color = "#2196F3" },
            new { Name = "Food", Icon = "restaurant", Color = "#FF9800" },
            new { Name = "Energy", Icon = "bolt", Color = "#FFC107" },
            new { Name = "Shopping", Icon = "shopping_bag", Color = "#9C27B0" },
            new { Name = "Home", Icon = "home", Color = "#009688" }
        };

        foreach (var catData in categoriesData)
        {
            var category = new ActivityCategory
            {
                Name = catData.Name,
                Icon = catData.Icon,
                Color = catData.Color
            };
            context.ActivityCategories.Add(category);
            categories[catData.Name] = category;
            Console.WriteLine($"  Created category: {catData.Name}");
        }

        await context.SaveChangesAsync();

        // Seed Activity Types
        var activityTypesData = new[]
        {
            // Transport
            new { Category = "Transport", Name = "Walking", Icon = "directions_walk", CO2Impact = -0.21, IsEcoFriendly = true, Points = 15 },
            new { Category = "Transport", Name = "Cycling", Icon = "directions_bike", CO2Impact = -0.21, IsEcoFriendly = true, Points = 15 },
            new { Category = "Transport", Name = "Public Transit", Icon = "directions_bus", CO2Impact = -0.12, IsEcoFriendly = true, Points = 10 },
            new { Category = "Transport", Name = "Car (alone)", Icon = "directions_car", CO2Impact = 0.21, IsEcoFriendly = false, Points = 0 },
            new { Category = "Transport", Name = "Carpool", Icon = "people", CO2Impact = -0.10, IsEcoFriendly = true, Points = 8 },
            new { Category = "Transport", Name = "Electric Vehicle", Icon = "electric_car", CO2Impact = -0.15, IsEcoFriendly = true, Points = 10 },
            
            // Food
            new { Category = "Food", Name = "Vegan Meal", Icon = "eco", CO2Impact = -0.5, IsEcoFriendly = true, Points = 20 },
            new { Category = "Food", Name = "Vegetarian Meal", Icon = "grass", CO2Impact = -0.3, IsEcoFriendly = true, Points = 15 },
            new { Category = "Food", Name = "Chicken Meal", Icon = "restaurant", CO2Impact = 0.5, IsEcoFriendly = false, Points = 0 },
            new { Category = "Food", Name = "Beef Meal", Icon = "lunch_dining", CO2Impact = 3.5, IsEcoFriendly = false, Points = 0 },
            new { Category = "Food", Name = "Local Produce", Icon = "store", CO2Impact = -0.2, IsEcoFriendly = true, Points = 10 },
            
            // Energy
            new { Category = "Energy", Name = "LED Lighting", Icon = "lightbulb", CO2Impact = -0.1, IsEcoFriendly = true, Points = 5 },
            new { Category = "Energy", Name = "Cold Wash Laundry", Icon = "local_laundry_service", CO2Impact = -0.3, IsEcoFriendly = true, Points = 10 },
            new { Category = "Energy", Name = "AC Usage (1hr)", Icon = "ac_unit", CO2Impact = 0.5, IsEcoFriendly = false, Points = 0 },
            new { Category = "Energy", Name = "Heating (1hr)", Icon = "whatshot", CO2Impact = 0.8, IsEcoFriendly = false, Points = 0 },
            new { Category = "Energy", Name = "Solar Power", Icon = "solar_power", CO2Impact = -1.0, IsEcoFriendly = true, Points = 25 },
            
            // Shopping
            new { Category = "Shopping", Name = "Second-hand Purchase", Icon = "recycling", CO2Impact = -0.5, IsEcoFriendly = true, Points = 15 },
            new { Category = "Shopping", Name = "Local Products", Icon = "store", CO2Impact = -0.3, IsEcoFriendly = true, Points = 10 },
            new { Category = "Shopping", Name = "Online Order", Icon = "local_shipping", CO2Impact = 0.5, IsEcoFriendly = false, Points = 0 },
            new { Category = "Shopping", Name = "New Clothes", Icon = "checkroom", CO2Impact = 2.0, IsEcoFriendly = false, Points = 0 },
            new { Category = "Shopping", Name = "Reusable Bags", Icon = "shopping_bag", CO2Impact = -0.1, IsEcoFriendly = true, Points = 5 },
            
            // Home
            new { Category = "Home", Name = "Composting", Icon = "compost", CO2Impact = -0.2, IsEcoFriendly = true, Points = 10 },
            new { Category = "Home", Name = "Recycling", Icon = "delete_outline", CO2Impact = -0.3, IsEcoFriendly = true, Points = 10 },
            new { Category = "Home", Name = "Water Saving", Icon = "water_drop", CO2Impact = -0.1, IsEcoFriendly = true, Points = 5 },
            new { Category = "Home", Name = "Plant a Tree", Icon = "park", CO2Impact = -5.0, IsEcoFriendly = true, Points = 50 }
        };

        foreach (var atData in activityTypesData)
        {
            var activityType = new ActivityType
            {
                Category = categories[atData.Category],
                Name = atData.Name,
                Icon = atData.Icon,
                CO2Impact = atData.CO2Impact,
                IsEcoFriendly = atData.IsEcoFriendly,
                Points = atData.Points,
                ImpactUnit = "per instance"
            };
            context.ActivityTypes.Add(activityType);
            Console.WriteLine($"  Created activity type: {atData.Name}");
        }

        await context.SaveChangesAsync();

        // Seed Tips
        var tipsData = new[]
        {
            new { Category = "Transport", Title = "Walk Short Distances", Content = "For trips under 2km, consider walking instead of driving. You'll save about 0.4kg of CO2 per trip.", ImpactDescription = "Save 0.4kg CO2" },
            new { Category = "Transport", Title = "Take Public Transit", Content = "Using buses or trains instead of driving can reduce your carbon footprint by up to 65%.", ImpactDescription = "Reduce emissions by 65%" },
            new { Category = "Food", Title = "Try Meatless Mondays", Content = "Skipping meat just one day a week can save up to 3.5kg of CO2 weekly.", ImpactDescription = "Save 3.5kg CO2/week" },
            new { Category = "Food", Title = "Buy Local Produce", Content = "Local food travels less distance, reducing transportation emissions significantly.", ImpactDescription = "Reduce food miles" },
            new { Category = "Energy", Title = "Switch to LED Bulbs", Content = "LED bulbs use 75% less energy than traditional incandescent bulbs.", ImpactDescription = "Save 75% energy" },
            new { Category = "Energy", Title = "Unplug Devices", Content = "Standby power can account for 10% of household energy use. Unplug when not in use.", ImpactDescription = "Save 10% energy" },
            new { Category = "Shopping", Title = "Choose Second-hand", Content = "Buying used items prevents new manufacturing emissions and extends product life.", ImpactDescription = "Prevent manufacturing emissions" },
            new { Category = "Shopping", Title = "Bring Reusable Bags", Content = "A single reusable bag can replace hundreds of plastic bags over its lifetime.", ImpactDescription = "Eliminate plastic waste" },
            new { Category = "Home", Title = "Start Composting", Content = "Composting food scraps reduces methane emissions from landfills.", ImpactDescription = "Reduce methane emissions" },
            new { Category = "Home", Title = "Fix Leaky Faucets", Content = "A dripping faucet can waste over 3,000 gallons of water per year.", ImpactDescription = "Save 3,000 gallons/year" }
        };

        foreach (var tipData in tipsData)
        {
            var tip = new Tip
            {
                Category = categories[tipData.Category],
                Title = tipData.Title,
                Content = tipData.Content,
                ImpactDescription = tipData.ImpactDescription,
                IsActive = true,
                Priority = 0
            };
            context.Tips.Add(tip);
            Console.WriteLine($"  Created tip: {tipData.Title}");
        }

        await context.SaveChangesAsync();

        // Seed Badges
        var badgesData = new[]
        {
            // Transport badges
            new { Name = "First Steps", Description = "Log your first walking activity", Icon = "🚶", BadgeType = "transport", RequirementType = "activities_count", RequirementValue = 1.0, RequirementCategory = "walking", PointsReward = 25 },
            new { Name = "Walker", Description = "Walk a total of 10 km", Icon = "🚶", BadgeType = "transport", RequirementType = "distance", RequirementValue = 10.0, RequirementCategory = "walking", PointsReward = 50 },
            new { Name = "Cyclist", Description = "Cycle a total of 20 km", Icon = "🚴", BadgeType = "transport", RequirementType = "distance", RequirementValue = 20.0, RequirementCategory = "cycling", PointsReward = 75 },
            new { Name = "Transit Pro", Description = "Use public transit 20 times", Icon = "🚌", BadgeType = "transport", RequirementType = "activities_count", RequirementValue = 20.0, RequirementCategory = "public_transit", PointsReward = 100 },
            
            // Food badges
            new { Name = "Vegan Day", Description = "Eat vegan for a whole day", Icon = "🌱", BadgeType = "food", RequirementType = "activities_count", RequirementValue = 3.0, RequirementCategory = "vegan", PointsReward = 50 },
            new { Name = "Vegan Week", Description = "Eat vegan for 7 consecutive days", Icon = "🌱", BadgeType = "food", RequirementType = "streak", RequirementValue = 7.0, RequirementCategory = "vegan", PointsReward = 200 },
            new { Name = "Local Hero", Description = "Buy local produce 10 times", Icon = "🏪", BadgeType = "food", RequirementType = "activities_count", RequirementValue = 10.0, RequirementCategory = "local", PointsReward = 75 },
            
            // Energy badges
            new { Name = "Energy Saver", Description = "Log 10 energy-saving activities", Icon = "💡", BadgeType = "energy", RequirementType = "activities_count", RequirementValue = 10.0, RequirementCategory = "energy", PointsReward = 75 },
            new { Name = "Solar Champion", Description = "Use solar power for 30 days", Icon = "☀️", BadgeType = "energy", RequirementType = "activities_count", RequirementValue = 30.0, RequirementCategory = "solar", PointsReward = 150 },
            
            // General badges
            new { Name = "Recycler", Description = "Recycle 20 times", Icon = "♻️", BadgeType = "general", RequirementType = "activities_count", RequirementValue = 20.0, RequirementCategory = "recycling", PointsReward = 75 },
            new { Name = "Tree Planter", Description = "Plant your first tree", Icon = "🌳", BadgeType = "general", RequirementType = "activities_count", RequirementValue = 1.0, RequirementCategory = "tree", PointsReward = 100 },
            
            // Streak badges
            new { Name = "Week Warrior", Description = "Maintain a 7-day streak", Icon = "🔥", BadgeType = "streak", RequirementType = "streak", RequirementValue = 7.0, RequirementCategory = "", PointsReward = 75 },
            new { Name = "Month Master", Description = "Maintain a 30-day streak", Icon = "🔥", BadgeType = "streak", RequirementType = "streak", RequirementValue = 30.0, RequirementCategory = "", PointsReward = 200 },
            new { Name = "Century Streak", Description = "Maintain a 100-day streak", Icon = "💯", BadgeType = "streak", RequirementType = "streak", RequirementValue = 100.0, RequirementCategory = "", PointsReward = 500 },
            
            // Milestone badges
            new { Name = "Carbon Cutter", Description = "Save 10 kg of CO2", Icon = "🌍", BadgeType = "milestone", RequirementType = "co2_saved", RequirementValue = 10.0, RequirementCategory = "", PointsReward = 100 },
            new { Name = "Earth Hero", Description = "Save 100 kg of CO2", Icon = "🌍", BadgeType = "milestone", RequirementType = "co2_saved", RequirementValue = 100.0, RequirementCategory = "", PointsReward = 300 },
            new { Name = "Climate Champion", Description = "Save 500 kg of CO2", Icon = "🏆", BadgeType = "milestone", RequirementType = "co2_saved", RequirementValue = 500.0, RequirementCategory = "", PointsReward = 750 },
            new { Name = "Perfect Week", Description = "Get a score of 100 for 7 days", Icon = "⭐", BadgeType = "milestone", RequirementType = "perfect_days", RequirementValue = 7.0, RequirementCategory = "", PointsReward = 250 }
        };

        foreach (var badgeData in badgesData)
        {
            var badge = new Badge
            {
                Name = badgeData.Name,
                Description = badgeData.Description,
                Icon = badgeData.Icon,
                BadgeType = badgeData.BadgeType,
                RequirementType = badgeData.RequirementType,
                RequirementValue = badgeData.RequirementValue,
                RequirementCategory = badgeData.RequirementCategory,
                PointsReward = badgeData.PointsReward,
                IsActive = true
            };
            context.Badges.Add(badge);
            Console.WriteLine($"  Created badge: {badgeData.Name}");
        }

        await context.SaveChangesAsync();

        // Seed Challenges
        var now = DateTime.UtcNow;
        var challengesData = new[]
        {
            new { Title = "Weekly Warrior", Description = "Log activities for 7 consecutive days", ChallengeType = "weekly", TargetValue = 7.0, TargetUnit = "days", PointsReward = 100 },
            new { Title = "Carbon Crusher", Description = "Save 50 kg of CO₂ this month", ChallengeType = "monthly", TargetValue = 50.0, TargetUnit = "kg CO₂", PointsReward = 200 },
            new { Title = "Activity Master", Description = "Log 30 eco-friendly activities", ChallengeType = "monthly", TargetValue = 30.0, TargetUnit = "activities", PointsReward = 150 },
            new { Title = "Green Commuter", Description = "Use public transport or bike 20 times", ChallengeType = "monthly", TargetValue = 20.0, TargetUnit = "trips", PointsReward = 175 },
            new { Title = "Plant-Based Pioneer", Description = "Have 15 vegan meals", ChallengeType = "monthly", TargetValue = 15.0, TargetUnit = "meals", PointsReward = 125 },
            new { Title = "Local Hero Challenge", Description = "Buy locally sourced products 25 times", ChallengeType = "monthly", TargetValue = 25.0, TargetUnit = "purchases", PointsReward = 150 },
            new { Title = "Energy Saver Quest", Description = "Log 40 energy-saving activities", ChallengeType = "monthly", TargetValue = 40.0, TargetUnit = "activities", PointsReward = 180 }
        };

        foreach (var challengeData in challengesData)
        {
            var challenge = new Challenge
            {
                Title = challengeData.Title,
                Description = challengeData.Description,
                ChallengeType = challengeData.ChallengeType,
                TargetValue = challengeData.TargetValue,
                TargetUnit = challengeData.TargetUnit,
                PointsReward = challengeData.PointsReward,
                StartDate = now,
                EndDate = now.AddDays(30),
                IsActive = true
            };
            context.Challenges.Add(challenge);
            Console.WriteLine($"  Created challenge: {challengeData.Title}");
        }

        await context.SaveChangesAsync();

        // Seed Admin User
        await SeedAdminUserAsync(context);

        Console.WriteLine("✅ Database seeded successfully!");
    }

    private static async Task SeedAdminUserAsync(EcoDbContext context)
    {
        var adminEmail = "admin@eco.com";
        var existingAdmin = await context.Users.FirstOrDefaultAsync(u => u.Email == adminEmail);

        if (existingAdmin != null)
        {
            Console.WriteLine($"Admin user {adminEmail} already exists, skipping...");
            return;
        }

        var admin = new User
        {
            UserName = adminEmail,
            Email = adminEmail,
            EmailConfirmed = true,
            FirstName = "Admin",
            LastName = "User",
            Bio = "🌍 Eco warrior and sustainability enthusiast",
            EcoScore = 850,
            TotalCO2Saved = 125.5,
            CurrentStreak = 15,
            LongestStreak = 45,
            Level = 8,
            ExperiencePoints = 6500,
            Units = "metric",
            NotificationsEnabled = true,
            DarkMode = false,
            LocationTracking = true,
            ActivityRecognition = true,
            EmailVerified = true,
            CreatedAt = DateTime.UtcNow.AddDays(-90),
            UpdatedAt = DateTime.UtcNow
        };

        var userStore = new Microsoft.AspNetCore.Identity.EntityFrameworkCore.UserStore<User, IdentityRole<int>, EcoDbContext, int>(context);
        var hasher = new PasswordHasher<User>();
        admin.PasswordHash = hasher.HashPassword(admin, "Admin@123");

        await userStore.CreateAsync(admin);
        await context.SaveChangesAsync();

        var userId = admin.Id;
        Console.WriteLine($"✓ Created admin user: {adminEmail}");

        // Add goals
        var goals = new List<UserGoal>
        {
            new()
            {
                UserId = userId,
                Title = "Walk 100 km",
                Description = "Complete 100 km of walking activities",
                TargetValue = 100,
                CurrentValue = 65,
                Unit = "km",
                IsCompleted = false,
                Deadline = DateTime.UtcNow.AddMonths(1),
                CreatedAt = DateTime.UtcNow.AddDays(-30)
            },
            new()
            {
                UserId = userId,
                Title = "Eat Vegan 20 Days",
                Description = "Log vegan meals for 20 days",
                TargetValue = 20,
                CurrentValue = 12,
                Unit = "days",
                IsCompleted = false,
                Deadline = DateTime.UtcNow.AddMonths(1),
                CreatedAt = DateTime.UtcNow.AddDays(-30)
            },
            new()
            {
                UserId = userId,
                Title = "Save 500 kg CO2",
                Description = "Reduce carbon emissions by 500 kg",
                TargetValue = 500,
                CurrentValue = 350,
                Unit = "kg",
                IsCompleted = false,
                Deadline = DateTime.UtcNow.AddMonths(2),
                CreatedAt = DateTime.UtcNow.AddDays(-60)
            }
        };
        context.UserGoals.AddRange(goals);
        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Added 3 goals for admin user");

        // Add daily scores for the past 15 days
        var dailyScores = new List<DailyScore>();
        for (int i = 15; i > 0; i--)
        {
            var scoreDate = DateTime.UtcNow.AddDays(-i).Date;
            dailyScores.Add(new DailyScore
            {
                UserId = userId,
                Date = scoreDate,
                Score = 75 + (i % 30),
                CO2Emitted = 5.5 - (i % 3),
                CO2Saved = 2.5 + (i % 4),
                Steps = 8000 + (i * 200)
            });
        }
        context.DailyScores.AddRange(dailyScores);
        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Added 15 daily scores for admin user");

        // Add activities
        var categories = await context.ActivityCategories.ToListAsync();
        var activityTypes = await context.ActivityTypes.ToListAsync();

        var activities = new List<Activity>();
        if (activityTypes.Count > 0)
        {
            activities = new List<Activity>
            {
                new()
                {
                    UserId = userId,
                    ActivityTypeId = activityTypes.FirstOrDefault(at => at.Name == "Walking")?.Id ?? activityTypes.First().Id,
                    Quantity = 5,
                    Unit = "km",
                    Notes = "Morning walk in the park",
                    CO2Impact = 0,
                    PointsEarned = 50,
                    LocationName = "Central Park",
                    ActivityDate = DateTime.UtcNow.AddDays(-1),
                    ActivityTime = new TimeSpan(6, 30, 0),
                    CreatedAt = DateTime.UtcNow.AddDays(-1)
                },
                new()
                {
                    UserId = userId,
                    ActivityTypeId = activityTypes.FirstOrDefault(at => at.Name == "Cycling")?.Id ?? activityTypes.First().Id,
                    Quantity = 10,
                    Unit = "km",
                    Notes = "Commute to work by bike",
                    CO2Impact = 0,
                    PointsEarned = 150,
                    LocationName = "Downtown",
                    ActivityDate = DateTime.UtcNow.AddDays(-1),
                    ActivityTime = new TimeSpan(8, 0, 0),
                    CreatedAt = DateTime.UtcNow.AddDays(-1)
                },
                new()
                {
                    UserId = userId,
                    ActivityTypeId = activityTypes.FirstOrDefault(at => at.Name == "Vegan Meal")?.Id ?? activityTypes.First().Id,
                    Quantity = 1,
                    Unit = "meal",
                    Notes = "Delicious buddha bowl",
                    CO2Impact = -2,
                    PointsEarned = 25,
                    ActivityDate = DateTime.UtcNow.AddDays(-1),
                    ActivityTime = new TimeSpan(12, 0, 0),
                    CreatedAt = DateTime.UtcNow.AddDays(-1)
                },
                new()
                {
                    UserId = userId,
                    ActivityTypeId = activityTypes.FirstOrDefault(at => at.Name == "Local Produce")?.Id ?? activityTypes.First().Id,
                    Quantity = 1,
                    Unit = "purchase",
                    Notes = "Bought organic local vegetables",
                    CO2Impact = -1.5,
                    PointsEarned = 20,
                    LocationName = "Farmers Market",
                    ActivityDate = DateTime.UtcNow.AddDays(-2),
                    ActivityTime = new TimeSpan(9, 0, 0),
                    CreatedAt = DateTime.UtcNow.AddDays(-2)
                },
                new()
                {
                    UserId = userId,
                    ActivityTypeId = activityTypes.FirstOrDefault(at => at.Name == "Public Transit")?.Id ?? activityTypes.First().Id,
                    Quantity = 15,
                    Unit = "km",
                    Notes = "Bus ride to downtown",
                    CO2Impact = 0.089 * 15,
                    PointsEarned = 180,
                    ActivityDate = DateTime.UtcNow.AddDays(-3),
                    ActivityTime = new TimeSpan(17, 30, 0),
                    CreatedAt = DateTime.UtcNow.AddDays(-3)
                }
            };
            context.Activities.AddRange(activities);
            await context.SaveChangesAsync();
            Console.WriteLine($"✓ Added 5 activities for admin user");
        }

        // Add badges
        var badges = await context.Badges.ToListAsync();
        if (badges.Count >= 5)
        {
            var userBadges = new List<UserBadge>
            {
                new() { UserId = userId, BadgeId = badges.FirstOrDefault(b => b.Name == "First Steps")?.Id ?? badges[0].Id, EarnedAt = DateTime.UtcNow.AddDays(-80) },
                new() { UserId = userId, BadgeId = badges.FirstOrDefault(b => b.Name == "Walker")?.Id ?? badges[1].Id, EarnedAt = DateTime.UtcNow.AddDays(-60) },
                new() { UserId = userId, BadgeId = badges.FirstOrDefault(b => b.Name == "Cyclist")?.Id ?? badges[2].Id, EarnedAt = DateTime.UtcNow.AddDays(-50) },
                new() { UserId = userId, BadgeId = badges.FirstOrDefault(b => b.Name == "Vegan Day")?.Id ?? badges[3].Id, EarnedAt = DateTime.UtcNow.AddDays(-40) },
                new() { UserId = userId, BadgeId = badges.FirstOrDefault(b => b.Name == "Recycler")?.Id ?? badges[4].Id, EarnedAt = DateTime.UtcNow.AddDays(-30) }
            };
            context.UserBadges.AddRange(userBadges);
            await context.SaveChangesAsync();
            Console.WriteLine($"✓ Added 5 badges for admin user");
        }

        // Add trips
        var trips = new List<Trip>
        {
            new()
            {
                UserId = userId,
                TransportMode = "cycling",
                DistanceKm = 12,
                DurationMinutes = 45,
                StartLocation = "Home",
                StartLatitude = 40.7128,
                StartLongitude = -74.0060,
                EndLocation = "Office",
                EndLatitude = 40.7580,
                EndLongitude = -73.9855,
                CO2Emitted = 0,
                CO2Saved = 2.52,
                TripDate = DateTime.UtcNow.AddDays(-1),
                StartTime = new TimeSpan(8, 0, 0),
                EndTime = new TimeSpan(8, 45, 0),
                IsAutoDetected = false,
                ConfidenceScore = 1.0,
                CreatedAt = DateTime.UtcNow.AddDays(-1)
            },
            new()
            {
                UserId = userId,
                TransportMode = "walking",
                DistanceKm = 2,
                DurationMinutes = 25,
                StartLocation = "Office",
                StartLatitude = 40.7580,
                StartLongitude = -73.9855,
                EndLocation = "Cafe",
                EndLatitude = 40.7614,
                EndLongitude = -73.9776,
                CO2Emitted = 0,
                CO2Saved = 0.42,
                TripDate = DateTime.UtcNow.AddDays(-1),
                StartTime = new TimeSpan(12, 30, 0),
                EndTime = new TimeSpan(12, 55, 0),
                IsAutoDetected = false,
                ConfidenceScore = 1.0,
                CreatedAt = DateTime.UtcNow.AddDays(-1)
            }
        };
        context.Trips.AddRange(trips);
        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Added 2 trips for admin user");

        // Add travel summary
        var travelSummary = new TravelSummary
        {
            UserId = userId,
            Date = DateTime.UtcNow.Date,
            WalkingKm = 5,
            CyclingKm = 12,
            PublicTransitKm = 0,
            CarKm = 0,
            OtherKm = 0,
            TotalKm = 17,
            TotalTrips = 3,
            TotalCO2Emitted = 0,
            TotalCO2Saved = 3.5,
            Steps = 8500
        };
        context.TravelSummaries.Add(travelSummary);
        await context.SaveChangesAsync();
        Console.WriteLine($"✓ Added travel summary for admin user");

        Console.WriteLine($"✅ Admin user {adminEmail} seeded successfully with dummy data!");
    }
}
