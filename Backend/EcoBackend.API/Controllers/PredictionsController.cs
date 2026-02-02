using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/predictions")]
[Authorize]
public class PredictionsController : ControllerBase
{
    private readonly EcoDbContext _context;
    
    public PredictionsController(EcoDbContext context)
    {
        _context = context;
    }
    
    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var profile = await _context.UserEcoProfiles
            .FirstOrDefaultAsync(p => p.UserId == userId);
        
        return Ok(profile);
    }
    
    [HttpPost("profile")]
    public async Task<IActionResult> CreateOrUpdateProfile([FromBody] UserEcoProfileDto profileDto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
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
        
        return Ok(new { message = "Profile updated successfully" });
    }
    
    [HttpGet("daily-logs")]
    public async Task<IActionResult> GetDailyLogs([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var query = _context.DailyLogs.Where(dl => dl.UserId == userId);
        
        if (startDate.HasValue)
            query = query.Where(dl => dl.Date >= startDate.Value);
        if (endDate.HasValue)
            query = query.Where(dl => dl.Date <= endDate.Value);
        
        var logs = await query.OrderByDescending(dl => dl.Date).ToListAsync();
        
        return Ok(logs);
    }
}
