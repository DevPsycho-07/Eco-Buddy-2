using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using EcoBackend.API.DTOs;
using EcoBackend.API.Services;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/activities")]
[Authorize]
public class ActivitiesController : ControllerBase
{
    private readonly ActivityService _activityService;

    public ActivitiesController(ActivityService activityService)
    {
        _activityService = activityService;
    }

    [HttpGet("categories")]
    public async Task<IActionResult> GetCategories()
    {
        var categories = await _activityService.GetCategoriesAsync();
        return Ok(categories);
    }

    [HttpGet("categories/{id}")]
    public async Task<IActionResult> GetCategoryById(int id)
    {
        var category = await _activityService.GetCategoryByIdAsync(id);
        if (category == null) return NotFound();
        return Ok(category);
    }

    [HttpGet("types")]
    public async Task<IActionResult> GetActivityTypes([FromQuery] int? category)
    {
        var types = await _activityService.GetActivityTypesAsync(category);
        return Ok(types);
    }

    [HttpGet("types/{id}")]
    public async Task<IActionResult> GetActivityTypeById(int id)
    {
        var activityType = await _activityService.GetActivityTypeByIdAsync(id);
        if (activityType == null) return NotFound(new { error = "Activity type not found" });
        return Ok(activityType);
    }

    [HttpGet]
    public async Task<IActionResult> GetActivities(
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate,
        [FromQuery] int? category)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var activities = await _activityService.GetActivitiesAsync(userId, startDate, endDate, category);
        return Ok(activities);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetActivity(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var activity = await _activityService.GetActivityByIdAsync(id, userId);
        if (activity == null) return NotFound();
        return Ok(activity);
    }

    [HttpPost]
    public async Task<IActionResult> CreateActivity([FromBody] ActivityCreateDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        try
        {
            var activity = await _activityService.CreateActivityAsync(userId, dto);
            return CreatedAtAction(nameof(GetActivity), new { id = activity.Id }, activity);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("today")]
    public async Task<IActionResult> GetTodayActivities()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var activities = await _activityService.GetTodayActivitiesAsync(userId);
        return Ok(activities);
    }

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary([FromQuery] int days = 7)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var summary = await _activityService.GetSummaryAsync(userId, days);
        return Ok(summary);
    }

    [HttpGet("tips")]
    public async Task<IActionResult> GetTips([FromQuery] int? category)
    {
        var tips = await _activityService.GetTipsAsync(category);
        return Ok(tips);
    }

    [HttpGet("tips/{id}")]
    public async Task<IActionResult> GetTipById(int id)
    {
        var tip = await _activityService.GetTipByIdAsync(id);
        if (tip == null) return NotFound(new { error = "Tip not found" });
        return Ok(tip);
    }

    // Alternative routes for frontend compatibility
    [HttpGet("log/today")]
    public Task<IActionResult> GetTodayActivitiesAlt() => GetTodayActivities();

    [HttpGet("log/summary")]
    public Task<IActionResult> GetSummaryAlt([FromQuery] int days = 7) => GetSummary(days);

    [HttpGet("log/history")]
    public async Task<IActionResult> GetActivityHistory([FromQuery] int days = 30)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var history = await _activityService.GetActivityHistoryAsync(userId, days);
        return Ok(history);
    }

    [HttpGet("tips/daily")]
    public async Task<IActionResult> GetDailyTip()
    {
        var tip = await _activityService.GetDailyTipAsync();
        return Ok(tip);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteActivity(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var deleted = await _activityService.DeleteActivityAsync(id, userId);
        if (!deleted) return NotFound();
        return NoContent();
    }
}
