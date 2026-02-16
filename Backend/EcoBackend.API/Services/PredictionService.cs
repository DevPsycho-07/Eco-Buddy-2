using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;
using Microsoft.EntityFrameworkCore;

namespace EcoBackend.API.Services;

public class PredictionService
{
    private readonly EcoDbContext _context;

    public PredictionService(EcoDbContext context)
    {
        _context = context;
    }

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

    public async Task<List<DailyLog>> GetDailyLogsAsync(int userId, DateTime? startDate, DateTime? endDate)
    {
        var query = _context.DailyLogs.Where(dl => dl.UserId == userId);

        if (startDate.HasValue)
            query = query.Where(dl => dl.Date >= startDate.Value);
        if (endDate.HasValue)
            query = query.Where(dl => dl.Date <= endDate.Value);

        return await query.OrderByDescending(dl => dl.Date).ToListAsync();
    }
}
