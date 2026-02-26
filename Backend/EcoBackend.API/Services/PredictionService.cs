using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace EcoBackend.API.Services;

public class PredictionService
{
    private readonly EcoDbContext _context;
    private readonly EcoScorePredictorService _predictor;

    public PredictionService(EcoDbContext context, EcoScorePredictorService predictor)
    {
        _context = context;
        _predictor = predictor;
    }

    // ==================== User Profile ====================

    public async Task<UserEcoProfile?> GetProfileAsync(int userId)
    {
        return await _context.UserEcoProfiles
            .FirstOrDefaultAsync(p => p.UserId == userId);
    }

    public async Task CreateOrUpdateProfileAsync(int userId, UserEcoProfileDto profileDto)
    {
        var existing = await _context.UserEcoProfiles
            .FirstOrDefaultAsync(p => p.UserId == userId);

        if (existing == null)
        {
            var profile = new UserEcoProfile
            {
                UserId = userId,
                HouseholdSize = profileDto.HouseholdSize,
                AgeGroup = profileDto.AgeGroup,
                LifestyleType = profileDto.LifestyleType,
                LocationType = profileDto.LocationType,
                VehicleType = profileDto.VehicleType,
                CarFuelType = profileDto.CarFuelType,
                DietType = profileDto.DietType,
                UsesSolarPanels = profileDto.UsesSolarPanels,
                SmartThermostat = profileDto.SmartThermostat,
                RenewableEnergyPercent = profileDto.RenewableEnergyPercent,
                RecyclingPracticed = profileDto.RecyclingPracticed,
                CompostingPracticed = profileDto.CompostingPracticed,
                WasteBagSize = profileDto.WasteBagSize,
                SocialActivity = profileDto.SocialActivity
            };

            _context.UserEcoProfiles.Add(profile);
        }
        else
        {
            existing.HouseholdSize = profileDto.HouseholdSize;
            existing.AgeGroup = profileDto.AgeGroup;
            existing.LifestyleType = profileDto.LifestyleType;
            existing.LocationType = profileDto.LocationType;
            existing.VehicleType = profileDto.VehicleType;
            existing.CarFuelType = profileDto.CarFuelType;
            existing.DietType = profileDto.DietType;
            existing.UsesSolarPanels = profileDto.UsesSolarPanels;
            existing.SmartThermostat = profileDto.SmartThermostat;
            existing.RenewableEnergyPercent = profileDto.RenewableEnergyPercent;
            existing.RecyclingPracticed = profileDto.RecyclingPracticed;
            existing.CompostingPracticed = profileDto.CompostingPracticed;
            existing.WasteBagSize = profileDto.WasteBagSize;
            existing.SocialActivity = profileDto.SocialActivity;
            existing.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
    }

    // ==================== Daily Logs ====================

    public async Task<List<DailyLog>> GetDailyLogsAsync(int userId, DateTime? startDate, DateTime? endDate)
    {
        var query = _context.DailyLogs.Where(dl => dl.UserId == userId);
        if (startDate.HasValue) query = query.Where(dl => dl.Date >= startDate.Value);
        if (endDate.HasValue) query = query.Where(dl => dl.Date <= endDate.Value);
        return await query.OrderByDescending(dl => dl.Date).ToListAsync();
    }

    /// <summary>Get today's daily log (mirrors Django DailyLogView.get).</summary>
    public async Task<DailyLogDto?> GetTodaysDailyLogAsync(int userId)
    {
        var today = DateTime.UtcNow.Date;
        var log = await _context.DailyLogs
            .FirstOrDefaultAsync(dl => dl.UserId == userId && dl.Date == today);
        return log == null ? null : MapToDailyLogDto(log, userId);
    }

    /// <summary>Create or update today's daily log (mirrors Django DailyLogView.post).</summary>
    public async Task<(DailyLogDto Dto, bool Created)> CreateOrUpdateDailyLogAsync(int userId, DailyLogInputDto input)
    {
        var today = DateTime.UtcNow.Date;
        var log = await _context.DailyLogs
            .FirstOrDefaultAsync(dl => dl.UserId == userId && dl.Date == today);

        bool created = log == null;
        if (created)
        {
            log = new DailyLog { UserId = userId, Date = today };
            _context.DailyLogs.Add(log);
        }

        // Partial update – only set fields that were provided
        if (input.CarKm.HasValue) log!.CarKm = input.CarKm.Value;
        if (input.BusKm.HasValue) log!.BusKm = input.BusKm.Value;
        if (input.TrainMetroKm.HasValue) log!.TrainMetroKm = input.TrainMetroKm.Value;
        if (input.BikeKm.HasValue) log!.BikeKm = input.BikeKm.Value;
        if (input.WalkKm.HasValue) log!.WalkKm = input.WalkKm.Value;
        if (input.ElectricityKwh.HasValue) log!.ElectricityKwh = input.ElectricityKwh.Value;
        if (input.NaturalGasTherms.HasValue) log!.NaturalGasTherms = input.NaturalGasTherms.Value;
        if (input.AcHours.HasValue) log!.AcHours = input.AcHours.Value;
        if (input.HeatingHours.HasValue) log!.HeatingHours = input.HeatingHours.Value;
        if (input.WaterUsageLiters.HasValue) log!.WaterUsageLiters = input.WaterUsageLiters.Value;
        if (input.RedMeatMeals.HasValue) log!.RedMeatMeals = input.RedMeatMeals.Value;
        if (input.PoultryMeals.HasValue) log!.PoultryMeals = input.PoultryMeals.Value;
        if (input.FishMeals.HasValue) log!.FishMeals = input.FishMeals.Value;
        if (input.VegetarianMeals.HasValue) log!.VegetarianMeals = input.VegetarianMeals.Value;
        if (input.VeganMeals.HasValue) log!.VeganMeals = input.VeganMeals.Value;
        if (input.FoodWasteKg.HasValue) log!.FoodWasteKg = input.FoodWasteKg.Value;
        if (input.ShowerFrequency.HasValue) log!.ShowerFrequency = input.ShowerFrequency.Value;
        if (input.TvPcHours.HasValue) log!.TvPcHours = input.TvPcHours.Value;
        if (input.InternetHours.HasValue) log!.InternetHours = input.InternetHours.Value;

        log!.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        return (MapToDailyLogDto(log, userId), created);
    }

    /// <summary>Get daily log history (mirrors Django DailyLogHistoryView).</summary>
    public async Task<List<DailyLogDto>> GetDailyLogHistoryAsync(int userId, int days = 7)
    {
        days = Math.Min(days, 30);
        var since = DateTime.UtcNow.Date.AddDays(-days);
        var logs = await _context.DailyLogs
            .Where(dl => dl.UserId == userId && dl.Date >= since)
            .OrderByDescending(dl => dl.Date)
            .ToListAsync();

        return logs.Select(l => MapToDailyLogDto(l, userId)).ToList();
    }

    // ==================== Prediction Trips ====================

    /// <summary>Log a GPS trip (mirrors Django TripView.post).</summary>
    public async Task<PredictionTripDto> LogTripAsync(int userId, PredictionTripCreateDto dto)
    {
        var tripDate = dto.Date?.Date ?? DateTime.UtcNow.Date;
        var distance = PredictionTrip.CalculateDistance(
            dto.StartLatitude, dto.StartLongitude,
            dto.EndLatitude, dto.EndLongitude);

        var trip = new PredictionTrip
        {
            UserId = userId,
            TransportMode = dto.TransportMode,
            StartLatitude = dto.StartLatitude,
            StartLongitude = dto.StartLongitude,
            EndLatitude = dto.EndLatitude,
            EndLongitude = dto.EndLongitude,
            DistanceKm = Math.Round(distance, 2),
            StartTime = dto.StartTime,
            EndTime = dto.EndTime,
            Date = tripDate
        };

        _context.PredictionTrips.Add(trip);
        await _context.SaveChangesAsync();

        // Update today's daily log with aggregated trip distances
        await UpdateDailyLogFromTripsAsync(userId, tripDate);

        return MapToTripDto(trip);
    }

    /// <summary>Get today's trips (mirrors Django TripView.get).</summary>
    public async Task<(List<PredictionTripDto> Trips, double TotalDistanceKm, int TripCount)> GetTodaysTripsAsync(int userId)
    {
        var today = DateTime.UtcNow.Date;
        var trips = await _context.PredictionTrips
            .Where(t => t.UserId == userId && t.Date == today)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();

        var totalDist = trips.Sum(t => t.DistanceKm);
        return (trips.Select(MapToTripDto).ToList(), Math.Round(totalDist, 2), trips.Count);
    }

    /// <summary>Get trip history (mirrors Django TripHistoryView).</summary>
    public async Task<List<PredictionTripDto>> GetTripHistoryAsync(int userId, int days = 7)
    {
        days = Math.Min(days, 30);
        var since = DateTime.UtcNow.AddDays(-days);
        var trips = await _context.PredictionTrips
            .Where(t => t.UserId == userId && t.CreatedAt >= since)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();
        return trips.Select(MapToTripDto).ToList();
    }

    /// <summary>Aggregate trip distances into the daily log (mirrors Django DailyLog.update_travel_from_trips).</summary>
    private async Task UpdateDailyLogFromTripsAsync(int userId, DateTime date)
    {
        var dayTrips = await _context.PredictionTrips
            .Where(t => t.UserId == userId && t.Date == date)
            .ToListAsync();

        var log = await _context.DailyLogs
            .FirstOrDefaultAsync(dl => dl.UserId == userId && dl.Date == date);

        if (log == null)
        {
            log = new DailyLog { UserId = userId, Date = date };
            _context.DailyLogs.Add(log);
        }

        log.CarKm = dayTrips.Where(t => t.TransportMode is "car" or "electric_car").Sum(t => t.DistanceKm);
        log.BusKm = dayTrips.Where(t => t.TransportMode == "bus").Sum(t => t.DistanceKm);
        log.TrainMetroKm = dayTrips.Where(t => t.TransportMode == "train").Sum(t => t.DistanceKm);
        log.BikeKm = dayTrips.Where(t => t.TransportMode == "bike").Sum(t => t.DistanceKm);
        log.WalkKm = dayTrips.Where(t => t.TransportMode == "walk").Sum(t => t.DistanceKm);
        log.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
    }

    // ==================== Eco Score Prediction ====================

    /// <summary>Predict eco score for authenticated user (mirrors Django PredictEcoScoreView).</summary>
    public async Task<PredictionOutputDto> PredictEcoScoreAsync(int userId)
    {
        if (!_predictor.IsLoaded)
            throw new InvalidOperationException("ML model is not available. Please contact administrator.");

        var inputData = new Dictionary<string, object>();
        var today = DateTime.UtcNow.Date;

        // 1. User profile
        var profile = await _context.UserEcoProfiles.FirstOrDefaultAsync(p => p.UserId == userId);
        if (profile == null)
            throw new InvalidOperationException("Please set up your eco profile first at /api/predictions/profile/");

        inputData["household_size"] = profile.HouseholdSize;
        inputData["age_group"] = profile.AgeGroup;
        inputData["lifestyle_type"] = profile.LifestyleType;
        inputData["location_type"] = profile.LocationType;
        inputData["vehicle_type"] = profile.VehicleType;
        inputData["car_fuel_type"] = profile.CarFuelType;
        inputData["diet_type"] = profile.DietType;
        inputData["uses_solar_panels"] = profile.UsesSolarPanels;
        inputData["smart_thermostat"] = profile.SmartThermostat;
        inputData["renewable_energy_percent"] = profile.RenewableEnergyPercent;

        // 2. Today's daily log
        bool hasDailyLog = false;
        var dailyLog = await _context.DailyLogs.FirstOrDefaultAsync(dl => dl.UserId == userId && dl.Date == today);
        if (dailyLog != null)
        {
            hasDailyLog = true;
            // Update travel from trips first
            await UpdateDailyLogFromTripsAsync(userId, today);
            dailyLog = await _context.DailyLogs.FirstOrDefaultAsync(dl => dl.UserId == userId && dl.Date == today);

            inputData["car_km"] = dailyLog!.CarKm;
            inputData["bus_km"] = dailyLog.BusKm;
            inputData["train_metro_km"] = dailyLog.TrainMetroKm;
            inputData["bike_km"] = dailyLog.BikeKm;
            inputData["walk_km"] = dailyLog.WalkKm;
            inputData["electricity_kwh"] = dailyLog.ElectricityKwh;
            inputData["ac_hours"] = dailyLog.AcHours;
            inputData["heating_hours"] = dailyLog.HeatingHours;
            inputData["red_meat_meals"] = dailyLog.RedMeatMeals;
            inputData["poultry_meals"] = dailyLog.PoultryMeals;
            inputData["fish_meals"] = dailyLog.FishMeals;
            inputData["vegetarian_meals"] = dailyLog.VegetarianMeals;
            inputData["vegan_meals"] = dailyLog.VeganMeals;
            inputData["food_waste_kg"] = dailyLog.FoodWasteKg;
            inputData["recycling_practiced"] = dailyLog.RecycledToday;
            inputData["shower_frequency"] = dailyLog.ShowerFrequency;
            inputData["tv_pc_hours"] = dailyLog.TvPcHours;
            inputData["internet_hours"] = dailyLog.InternetHours;
        }

        // 2b. Augment from today's Activity records
        var todayActivities = await _context.Activities
            .Include(a => a.ActivityType)
            .Where(a => a.UserId == userId && a.ActivityDate.Date == today)
            .ToListAsync();
        bool hasActivities = todayActivities.Count > 0;

        var activityFieldMap = new Dictionary<string, (string Field, string Op)>
        {
            ["Walking"] = ("walk_km", "add"),
            ["Cycling"] = ("bike_km", "add"),
            ["Public Transit"] = ("bus_km", "add"),
            ["Car (alone)"] = ("car_km", "add"),
            ["Electric Vehicle"] = ("car_km", "add"),
            ["Carpool"] = ("car_km", "add"),
            ["Vegan Meal"] = ("vegan_meals", "add"),
            ["Vegetarian Meal"] = ("vegetarian_meals", "add"),
            ["Chicken Meal"] = ("poultry_meals", "add"),
            ["Beef Meal"] = ("red_meat_meals", "add"),
            ["AC Usage (1hr)"] = ("ac_hours", "add"),
            ["Heating (1hr)"] = ("heating_hours", "add"),
            ["Recycling"] = ("recycling_practiced", "flag"),
            ["New Clothes"] = ("new_clothes_monthly", "add"),
        };

        foreach (var act in todayActivities)
        {
            if (activityFieldMap.TryGetValue(act.ActivityType.Name, out var mapping))
            {
                if (mapping.Op == "add")
                {
                    var current = inputData.TryGetValue(mapping.Field, out var v) ? Convert.ToDouble(v) : 0;
                    inputData[mapping.Field] = current + act.Quantity;
                }
                else if (mapping.Op == "flag")
                {
                    inputData[mapping.Field] = true;
                }
            }
        }

        // 3. Weekly log
        var weekStart = today.AddDays(-(int)today.DayOfWeek + (int)DayOfWeek.Monday);
        if (today.DayOfWeek == DayOfWeek.Sunday) weekStart = weekStart.AddDays(-7);
        var weekStartOnly = DateOnly.FromDateTime(weekStart);
        var weeklyLog = await _context.WeeklyLogs
            .FirstOrDefaultAsync(w => w.UserId == userId && w.WeekStartDate == weekStartOnly);
        bool hasWeeklyLog = weeklyLog != null;
        if (weeklyLog != null)
        {
            inputData["waste_bag_count"] = weeklyLog.WasteBagCount;
            inputData["grocery_bill"] = weeklyLog.GroceryBill;
            inputData["new_clothes_monthly"] = weeklyLog.NewClothesMonthly;
            inputData["general_waste_kg"] = weeklyLog.GeneralWasteKg;
            inputData["recycled_waste_kg"] = weeklyLog.RecycledWasteKg;
        }

        // 4. Predict
        var (score, category, recommendations) = _predictor.Predict(inputData);

        // 5. Log prediction
        var tripsToday = await _context.PredictionTrips.CountAsync(t => t.UserId == userId && t.Date == today);
        _context.PredictionLogs.Add(new PredictionLog
        {
            UserId = userId,
            InputData = JsonSerializer.Serialize(inputData),
            PredictedScore = score,
            ModelVersion = "v1.0"
        });
        await _context.SaveChangesAsync();

        // Previous day score
        var yesterday = today.AddDays(-1);
        var prevScore = await _context.PredictionLogs
            .Where(p => p.UserId == userId && p.CreatedAt.Date == yesterday)
            .OrderByDescending(p => p.CreatedAt)
            .Select(p => (double?)p.PredictedScore)
            .FirstOrDefaultAsync();

        return new PredictionOutputDto
        {
            PredictedScore = score,
            ScoreCategory = category,
            Recommendations = recommendations,
            DataSources = new Dictionary<string, object>
            {
                ["profile"] = true,
                ["daily_log"] = hasDailyLog,
                ["activities_today"] = hasActivities,
                ["weekly_log"] = hasWeeklyLog,
                ["trips_today"] = tripsToday
            },
            PreviousScore = prevScore
        };
    }

    /// <summary>Quick predict with manual input (mirrors Django QuickPredictView). AllowAnonymous.</summary>
    public async Task<PredictionOutputDto> QuickPredictAsync(PredictionInputDto dto, int? userId)
    {
        if (!_predictor.IsLoaded)
            throw new InvalidOperationException("ML model is not available.");

        var inputData = BuildInputDataFromDto(dto);
        var (score, category, recommendations) = _predictor.Predict(inputData);

        // Log if authenticated
        if (userId.HasValue)
        {
            _context.PredictionLogs.Add(new PredictionLog
            {
                UserId = userId.Value,
                InputData = JsonSerializer.Serialize(inputData),
                PredictedScore = score,
                ModelVersion = "v1.0"
            });
            await _context.SaveChangesAsync();
        }

        return new PredictionOutputDto
        {
            PredictedScore = score,
            ScoreCategory = category,
            Recommendations = recommendations.Take(3).ToList()
        };
    }

    // ==================== Prediction History ====================

    /// <summary>Get prediction history (mirrors Django PredictionHistoryView).</summary>
    public async Task<(List<PredictionLogDto> Predictions, double AvgScore, int Total)> GetPredictionHistoryAsync(int userId, int limit = 10)
    {
        limit = Math.Min(limit, 100);

        var predictions = await _context.PredictionLogs
            .Include(p => p.User)
            .Where(p => p.UserId == userId)
            .OrderByDescending(p => p.CreatedAt)
            .Take(limit)
            .ToListAsync();

        var stats = await _context.PredictionLogs
            .Where(p => p.UserId == userId)
            .GroupBy(_ => 1)
            .Select(g => new { Avg = g.Average(p => p.PredictedScore), Count = g.Count() })
            .FirstOrDefaultAsync();

        var dtos = predictions.Select(p => new PredictionLogDto
        {
            Id = p.Id,
            Username = p.User?.UserName,
            InputData = p.InputData,
            PredictedScore = p.PredictedScore,
            Confidence = p.Confidence,
            ModelVersion = p.ModelVersion,
            CreatedAt = p.CreatedAt
        }).ToList();

        return (dtos, Math.Round(stats?.Avg ?? 0, 2), stats?.Count ?? 0);
    }

    // ==================== Model Info ====================

    /// <summary>Get model info (mirrors Django ModelInfoView).</summary>
    public ModelInfoDto GetModelInfo()
    {
        return new ModelInfoDto
        {
            ModelLoaded = _predictor.IsLoaded,
            ModelVersion = "v1.0",
            ModelType = "RandomForestRegressor",
            FeaturesCount = _predictor.FeaturesCount,
            CategoricalOptions = EcoScorePredictorService.CategoricalMappings,
            ScoreCategories = new()
            {
                new() { Min = 80, Max = 100, Label = "Excellent" },
                new() { Min = 60, Max = 79, Label = "Good" },
                new() { Min = 40, Max = 59, Label = "Average" },
                new() { Min = 20, Max = 39, Label = "Below Average" },
                new() { Min = 0, Max = 19, Label = "Needs Improvement" },
            }
        };
    }

    // ==================== Dashboard ====================

    /// <summary>Get prediction dashboard (mirrors Django DashboardView).</summary>
    public async Task<PredictionDashboardDto> GetDashboardAsync(int userId)
    {
        var today = DateTime.UtcNow.Date;
        var hasProfile = await _context.UserEcoProfiles.AnyAsync(p => p.UserId == userId);

        // Today's summary
        DashboardTodaySummary? todaySummary = null;
        var dailyLog = await _context.DailyLogs.FirstOrDefaultAsync(dl => dl.UserId == userId && dl.Date == today);
        if (dailyLog != null)
        {
            await UpdateDailyLogFromTripsAsync(userId, today);
            dailyLog = await _context.DailyLogs.FirstOrDefaultAsync(dl => dl.UserId == userId && dl.Date == today);
            todaySummary = new DashboardTodaySummary
            {
                TotalDistance = Math.Round(dailyLog!.CarKm + dailyLog.BusKm + dailyLog.TrainMetroKm + dailyLog.BikeKm + dailyLog.WalkKm, 2),
                MealsLogged = dailyLog.RedMeatMeals + dailyLog.PoultryMeals + dailyLog.FishMeals + dailyLog.VegetarianMeals + dailyLog.VeganMeals,
                Recycled = dailyLog.RecycledToday
            };
        }

        // Latest score
        var latestPrediction = await _context.PredictionLogs
            .Where(p => p.UserId == userId)
            .OrderByDescending(p => p.CreatedAt)
            .FirstOrDefaultAsync();

        // 7-day trend
        var since = DateTime.UtcNow.AddDays(-7);
        var weekTrend = await _context.PredictionLogs
            .Where(p => p.UserId == userId && p.CreatedAt >= since)
            .GroupBy(p => p.CreatedAt.Date)
            .Select(g => new DashboardWeekTrend { Date = g.Key, AvgScore = Math.Round(g.Average(p => p.PredictedScore), 2) })
            .OrderBy(x => x.Date)
            .ToListAsync();

        var tripsToday = await _context.PredictionTrips.CountAsync(t => t.UserId == userId && t.Date == today);
        var totalPredictions = await _context.PredictionLogs.CountAsync(p => p.UserId == userId);

        return new PredictionDashboardDto
        {
            ProfileComplete = hasProfile,
            LatestScore = latestPrediction != null ? Math.Round(latestPrediction.PredictedScore, 2) : null,
            TodaySummary = todaySummary,
            WeekTrend = weekTrend,
            TotalPredictions = totalPredictions,
            TripsToday = tripsToday
        };
    }

    // ==================== Weekly Logs ====================

    public async Task<WeeklyLogDto?> GetWeeklyLogAsync(int userId, DateOnly? weekStartDate = null)
    {
        WeeklyLog? log;
        if (weekStartDate.HasValue)
            log = await _context.WeeklyLogs.FirstOrDefaultAsync(w => w.UserId == userId && w.WeekStartDate == weekStartDate.Value);
        else
            log = await _context.WeeklyLogs.Where(w => w.UserId == userId).OrderByDescending(w => w.WeekStartDate).FirstOrDefaultAsync();

        return log == null ? null : MapToWeeklyLogDto(log);
    }

    public async Task<List<WeeklyLogDto>> GetWeeklyLogsAsync(int userId, DateOnly? from = null, DateOnly? to = null)
    {
        var q = _context.WeeklyLogs.Where(w => w.UserId == userId);
        if (from.HasValue) q = q.Where(w => w.WeekStartDate >= from.Value);
        if (to.HasValue) q = q.Where(w => w.WeekStartDate <= to.Value);
        return await q.OrderByDescending(w => w.WeekStartDate).Select(w => MapToWeeklyLogDto(w)).ToListAsync();
    }

    public async Task<WeeklyLogDto> CreateOrUpdateWeeklyLogAsync(int userId, WeeklyLogDto dto)
    {
        var existing = await _context.WeeklyLogs
            .FirstOrDefaultAsync(w => w.UserId == userId && w.WeekStartDate == dto.WeekStartDate);

        if (existing == null)
        {
            var log = new WeeklyLog
            {
                UserId = userId,
                WeekStartDate = dto.WeekStartDate,
                WasteBagCount = dto.WasteBagCount,
                GeneralWasteKg = dto.GeneralWasteKg,
                RecycledWasteKg = dto.RecycledWasteKg,
                GroceryBill = dto.GroceryBill,
                NewClothesMonthly = dto.NewClothesMonthly
            };
            _context.WeeklyLogs.Add(log);
            await _context.SaveChangesAsync();
            return MapToWeeklyLogDto(log);
        }

        existing.WasteBagCount = dto.WasteBagCount;
        existing.GeneralWasteKg = dto.GeneralWasteKg;
        existing.RecycledWasteKg = dto.RecycledWasteKg;
        existing.GroceryBill = dto.GroceryBill;
        existing.NewClothesMonthly = dto.NewClothesMonthly;
        existing.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return MapToWeeklyLogDto(existing);
    }

    // ==================== Mappers ====================

    private DailyLogDto MapToDailyLogDto(DailyLog dl, int userId)
    {
        var numTrips = _context.PredictionTrips.Count(t => t.UserId == userId && t.Date == dl.Date);
        return new DailyLogDto
        {
            Id = dl.Id,
            Date = dl.Date,
            CarKm = dl.CarKm,
            BusKm = dl.BusKm,
            TrainMetroKm = dl.TrainMetroKm,
            BikeKm = dl.BikeKm,
            WalkKm = dl.WalkKm,
            TotalDistanceKm = Math.Round(dl.CarKm + dl.BusKm + dl.TrainMetroKm + dl.BikeKm + dl.WalkKm, 2),
            NumTrips = numTrips,
            ElectricityKwh = dl.ElectricityKwh,
            NaturalGasTherms = dl.NaturalGasTherms,
            AcHours = dl.AcHours,
            HeatingHours = dl.HeatingHours,
            WaterUsageLiters = dl.WaterUsageLiters,
            RedMeatMeals = dl.RedMeatMeals,
            PoultryMeals = dl.PoultryMeals,
            FishMeals = dl.FishMeals,
            VegetarianMeals = dl.VegetarianMeals,
            VeganMeals = dl.VeganMeals,
            FoodWasteKg = dl.FoodWasteKg,
            ShowerFrequency = dl.ShowerFrequency,
            TvPcHours = dl.TvPcHours,
            InternetHours = dl.InternetHours,
            EcoScore = dl.EcoScore,
            ScoreCategory = dl.ScoreCategory,
            CreatedAt = dl.CreatedAt,
            UpdatedAt = dl.UpdatedAt
        };
    }

    private static PredictionTripDto MapToTripDto(PredictionTrip t) => new()
    {
        Id = t.Id,
        TransportMode = t.TransportMode,
        DistanceKm = t.DistanceKm,
        StartLatitude = t.StartLatitude,
        StartLongitude = t.StartLongitude,
        EndLatitude = t.EndLatitude,
        EndLongitude = t.EndLongitude,
        StartTime = t.StartTime,
        EndTime = t.EndTime,
        Date = t.Date,
        CreatedAt = t.CreatedAt
    };

    private static WeeklyLogDto MapToWeeklyLogDto(WeeklyLog w) => new()
    {
        Id = w.Id,
        WeekStartDate = w.WeekStartDate,
        WasteBagCount = w.WasteBagCount,
        GeneralWasteKg = w.GeneralWasteKg,
        RecycledWasteKg = w.RecycledWasteKg,
        GroceryBill = w.GroceryBill,
        NewClothesMonthly = w.NewClothesMonthly,
        CreatedAt = w.CreatedAt,
        UpdatedAt = w.UpdatedAt
    };

    private static Dictionary<string, object> BuildInputDataFromDto(PredictionInputDto dto)
    {
        var d = new Dictionary<string, object>();
        if (dto.HouseholdSize.HasValue) d["household_size"] = dto.HouseholdSize.Value;
        if (dto.CarKm.HasValue) d["car_km"] = dto.CarKm.Value;
        if (dto.BusKm.HasValue) d["bus_km"] = dto.BusKm.Value;
        if (dto.TrainMetroKm.HasValue) d["train_metro_km"] = dto.TrainMetroKm.Value;
        if (dto.BikeKm.HasValue) d["bike_km"] = dto.BikeKm.Value;
        if (dto.WalkKm.HasValue) d["walk_km"] = dto.WalkKm.Value;
        if (dto.ElectricityKwh.HasValue) d["electricity_kwh"] = dto.ElectricityKwh.Value;
        if (dto.NaturalGasTherms.HasValue) d["natural_gas_therms"] = dto.NaturalGasTherms.Value;
        if (dto.AcHours.HasValue) d["ac_hours"] = dto.AcHours.Value;
        if (dto.HeatingHours.HasValue) d["heating_hours"] = dto.HeatingHours.Value;
        if (dto.WaterUsageLiters.HasValue) d["water_usage_liters"] = dto.WaterUsageLiters.Value;
        if (dto.RenewableEnergyPercent.HasValue) d["renewable_energy_percent"] = dto.RenewableEnergyPercent.Value;
        if (dto.RedMeatMeals.HasValue) d["red_meat_meals"] = dto.RedMeatMeals.Value;
        if (dto.PoultryMeals.HasValue) d["poultry_meals"] = dto.PoultryMeals.Value;
        if (dto.FishMeals.HasValue) d["fish_meals"] = dto.FishMeals.Value;
        if (dto.VegetarianMeals.HasValue) d["vegetarian_meals"] = dto.VegetarianMeals.Value;
        if (dto.VeganMeals.HasValue) d["vegan_meals"] = dto.VeganMeals.Value;
        if (dto.GroceryBill.HasValue) d["grocery_bill"] = dto.GroceryBill.Value;
        if (dto.FoodWasteKg.HasValue) d["food_waste_kg"] = dto.FoodWasteKg.Value;
        if (dto.WasteBagCount.HasValue) d["waste_bag_count"] = dto.WasteBagCount.Value;
        if (dto.GeneralWasteKg.HasValue) d["general_waste_kg"] = dto.GeneralWasteKg.Value;
        if (dto.RecyclingPracticed.HasValue) d["recycling_practiced"] = dto.RecyclingPracticed.Value;
        if (dto.RecycledWasteKg.HasValue) d["recycled_waste_kg"] = dto.RecycledWasteKg.Value;
        if (dto.CompostingPracticed.HasValue) d["composting_practiced"] = dto.CompostingPracticed.Value;
        if (dto.NewClothesMonthly.HasValue) d["new_clothes_monthly"] = dto.NewClothesMonthly.Value;
        if (dto.ShowerFrequency.HasValue) d["shower_frequency"] = dto.ShowerFrequency.Value;
        if (dto.TvPcHours.HasValue) d["tv_pc_hours"] = dto.TvPcHours.Value;
        if (dto.InternetHours.HasValue) d["internet_hours"] = dto.InternetHours.Value;
        if (dto.UsesSolarPanels.HasValue) d["uses_solar_panels"] = dto.UsesSolarPanels.Value;
        if (dto.SmartThermostat.HasValue) d["smart_thermostat"] = dto.SmartThermostat.Value;
        if (dto.AgeGroup != null) d["age_group"] = dto.AgeGroup;
        if (dto.LifestyleType != null) d["lifestyle_type"] = dto.LifestyleType;
        if (dto.LocationType != null) d["location_type"] = dto.LocationType;
        if (dto.VehicleType != null) d["vehicle_type"] = dto.VehicleType;
        if (dto.CarFuelType != null) d["car_fuel_type"] = dto.CarFuelType;
        if (dto.DietType != null) d["diet_type"] = dto.DietType;
        if (dto.WasteBagSize != null) d["waste_bag_size"] = dto.WasteBagSize;
        if (dto.SocialActivity != null) d["social_activity"] = dto.SocialActivity;
        return d;
    }
}
