using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;
using Microsoft.EntityFrameworkCore;

namespace EcoBackend.API.Services;

public class GoalService
{
    private readonly EcoDbContext _context;

    public GoalService(EcoDbContext context)
    {
        _context = context;
    }

    public async Task<List<UserGoalDto>> GetGoalsAsync(int userId)
    {
        var goals = await _context.UserGoals
            .Where(g => g.UserId == userId)
            .OrderByDescending(g => g.CreatedAt)
            .ToListAsync();

        return goals.Select(MapToGoalDto).ToList();
    }

    public async Task<UserGoalDto> CreateGoalAsync(int userId, CreateUserGoalDto dto)
    {
        var goal = new UserGoal
        {
            UserId = userId,
            Title = dto.Title,
            Description = dto.Description,
            TargetValue = dto.TargetValue,
            Unit = dto.Unit,
            Deadline = dto.Deadline,
            CreatedAt = DateTime.UtcNow
        };

        _context.UserGoals.Add(goal);
        await _context.SaveChangesAsync();

        return MapToGoalDto(goal);
    }

    public async Task<UserGoalDto?> UpdateGoalAsync(int id, int userId, UpdateUserGoalDto dto)
    {
        var goal = await _context.UserGoals
            .FirstOrDefaultAsync(g => g.Id == id && g.UserId == userId);

        if (goal == null) return null;

        if (dto.Title != null) goal.Title = dto.Title;
        if (dto.Description != null) goal.Description = dto.Description;
        if (dto.TargetValue.HasValue) goal.TargetValue = dto.TargetValue.Value;
        if (dto.CurrentValue.HasValue) goal.CurrentValue = dto.CurrentValue.Value;
        if (dto.Unit != null) goal.Unit = dto.Unit;
        if (dto.IsCompleted.HasValue) goal.IsCompleted = dto.IsCompleted.Value;
        if (dto.Deadline.HasValue) goal.Deadline = dto.Deadline;

        await _context.SaveChangesAsync();

        return MapToGoalDto(goal);
    }

    public async Task<bool> DeleteGoalAsync(int id, int userId)
    {
        var goal = await _context.UserGoals
            .FirstOrDefaultAsync(g => g.Id == id && g.UserId == userId);

        if (goal == null) return false;

        _context.UserGoals.Remove(goal);
        await _context.SaveChangesAsync();
        return true;
    }

    private static UserGoalDto MapToGoalDto(UserGoal goal)
    {
        return new UserGoalDto
        {
            Id = goal.Id,
            Title = goal.Title,
            Description = goal.Description,
            TargetValue = goal.TargetValue,
            CurrentValue = goal.CurrentValue,
            Unit = goal.Unit,
            IsCompleted = goal.IsCompleted,
            Deadline = goal.Deadline,
            ProgressPercentage = goal.ProgressPercentage,
            CreatedAt = goal.CreatedAt
        };
    }
}
