using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;
using Microsoft.EntityFrameworkCore;

namespace EcoBackend.API.Services;

public class DailyScoreService
{
    private readonly EcoDbContext _context;

    public DailyScoreService(EcoDbContext context)
    {
        _context = context;
    }

    public async Task<List<DailyScoreDto>> GetDailyScoresAsync(int userId, DateTime? startDate, DateTime? endDate)
    {
        var query = _context.DailyScores.Where(ds => ds.UserId == userId);

        if (startDate.HasValue)
            query = query.Where(ds => ds.Date >= startDate.Value.Date);
        if (endDate.HasValue)
            query = query.Where(ds => ds.Date <= endDate.Value.Date);

        var dailyScores = await query
            .OrderByDescending(ds => ds.Date)
            .ToListAsync();

        return dailyScores.Select(MapToDailyScoreDto).ToList();
    }

    public async Task<DailyScoreDto?> GetDailyScoreByDateAsync(int userId, DateTime date)
    {
        var dailyScore = await _context.DailyScores
            .FirstOrDefaultAsync(ds => ds.UserId == userId && ds.Date.Date == date.Date);

        if (dailyScore == null) return null;

        return MapToDailyScoreDto(dailyScore);
    }

    public async Task<DailyScoreDto> CreateOrUpdateDailyScoreAsync(int userId, CreateDailyScoreDto dto)
    {
        var existingScore = await _context.DailyScores
            .FirstOrDefaultAsync(ds => ds.UserId == userId && ds.Date.Date == dto.Date.Date);

        if (existingScore != null)
        {
            existingScore.Score = dto.Score;
            existingScore.CO2Emitted = dto.CO2Emitted;
            existingScore.CO2Saved = dto.CO2Saved;
            existingScore.Steps = dto.Steps;
        }
        else
        {
            var newScore = new DailyScore
            {
                UserId = userId,
                Date = dto.Date.Date,
                Score = dto.Score,
                CO2Emitted = dto.CO2Emitted,
                CO2Saved = dto.CO2Saved,
                Steps = dto.Steps
            };
            _context.DailyScores.Add(newScore);
        }

        await _context.SaveChangesAsync();

        var dailyScore = await _context.DailyScores
            .FirstAsync(ds => ds.UserId == userId && ds.Date.Date == dto.Date.Date);

        return MapToDailyScoreDto(dailyScore);
    }

    public async Task<DailyScoreDto?> UpdateDailyScoreAsync(int userId, DateTime date, UpdateDailyScoreDto dto)
    {
        var dailyScore = await _context.DailyScores
            .FirstOrDefaultAsync(ds => ds.UserId == userId && ds.Date.Date == date.Date);

        if (dailyScore == null) return null;

        if (dto.Score.HasValue) dailyScore.Score = dto.Score.Value;
        if (dto.CO2Emitted.HasValue) dailyScore.CO2Emitted = dto.CO2Emitted.Value;
        if (dto.CO2Saved.HasValue) dailyScore.CO2Saved = dto.CO2Saved.Value;
        if (dto.Steps.HasValue) dailyScore.Steps = dto.Steps.Value;

        await _context.SaveChangesAsync();

        return MapToDailyScoreDto(dailyScore);
    }

    public async Task<bool> DeleteDailyScoreAsync(int userId, DateTime date)
    {
        var dailyScore = await _context.DailyScores
            .FirstOrDefaultAsync(ds => ds.UserId == userId && ds.Date.Date == date.Date);

        if (dailyScore == null) return false;

        _context.DailyScores.Remove(dailyScore);
        await _context.SaveChangesAsync();
        return true;
    }

    private static DailyScoreDto MapToDailyScoreDto(DailyScore ds)
    {
        return new DailyScoreDto
        {
            Id = ds.Id,
            Date = ds.Date,
            Score = ds.Score,
            CO2Emitted = ds.CO2Emitted,
            CO2Saved = ds.CO2Saved,
            Steps = ds.Steps
        };
    }
}
