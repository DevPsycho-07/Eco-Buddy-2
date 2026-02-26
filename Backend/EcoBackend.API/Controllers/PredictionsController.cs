using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using EcoBackend.API.DTOs;
using EcoBackend.API.Services;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/predictions")]
[Authorize]
public class PredictionsController : ControllerBase
{
    private readonly PredictionService _predictionService;

    public PredictionsController(PredictionService predictionService)
    {
        _predictionService = predictionService;
    }

    private int GetUserId() => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    // ==================== Profile ====================

    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        var profile = await _predictionService.GetProfileAsync(GetUserId());
        return Ok(profile);
    }

    [HttpPost("profile")]
    public async Task<IActionResult> CreateOrUpdateProfile([FromBody] UserEcoProfileDto profileDto)
    {
        await _predictionService.CreateOrUpdateProfileAsync(GetUserId(), profileDto);
        return Ok(new { message = "Profile updated successfully" });
    }

    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile([FromBody] UserEcoProfileDto profileDto)
    {
        await _predictionService.CreateOrUpdateProfileAsync(GetUserId(), profileDto);
        return Ok(new { message = "Profile updated successfully" });
    }

    // ==================== Daily Logs ====================

    [HttpGet("daily-logs")]
    public async Task<IActionResult> GetDailyLogs([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
    {
        var logs = await _predictionService.GetDailyLogsAsync(GetUserId(), startDate, endDate);
        return Ok(logs);
    }

    [HttpGet("daily")]
    public async Task<IActionResult> GetTodaysDailyLog()
    {
        var log = await _predictionService.GetTodaysDailyLogAsync(GetUserId());
        if (log == null)
            return Ok(new { message = "No daily log yet for today. Start logging your activities!" });
        return Ok(log);
    }

    [HttpPost("daily")]
    public async Task<IActionResult> CreateOrUpdateDailyLog([FromBody] DailyLogInputDto input)
    {
        var (dto, created) = await _predictionService.CreateOrUpdateDailyLogAsync(GetUserId(), input);
        return Ok(new
        {
            message = created ? "Daily log created" : "Daily log updated",
            daily_log = dto
        });
    }

    [HttpGet("daily/history")]
    public async Task<IActionResult> GetDailyLogHistory([FromQuery] int days = 7)
    {
        var logs = await _predictionService.GetDailyLogHistoryAsync(GetUserId(), days);
        return Ok(new { count = logs.Count, results = logs });
    }

    // ==================== Trips ====================

    [HttpPost("trips")]
    public async Task<IActionResult> LogTrip([FromBody] PredictionTripCreateDto dto)
    {
        try
        {
            var trip = await _predictionService.LogTripAsync(GetUserId(), dto);
            return StatusCode(201, new { message = "Trip logged successfully", trip });
        }
        catch (Exception ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("trips")]
    public async Task<IActionResult> GetTodaysTrips()
    {
        var (trips, totalDistance, tripCount) = await _predictionService.GetTodaysTripsAsync(GetUserId());
        return Ok(new
        {
            count = tripCount,
            total_distance_km = totalDistance,
            trips
        });
    }

    [HttpGet("trips/history")]
    public async Task<IActionResult> GetTripHistory([FromQuery] int days = 7)
    {
        var trips = await _predictionService.GetTripHistoryAsync(GetUserId(), days);
        return Ok(new { count = trips.Count, trips });
    }

    // ==================== Predictions ====================

    [HttpPost("predict")]
    public async Task<IActionResult> Predict()
    {
        try
        {
            var result = await _predictionService.PredictEcoScoreAsync(GetUserId());
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpPost("predict/quick")]
    [AllowAnonymous]
    public async Task<IActionResult> QuickPredict([FromBody] PredictionInputDto dto)
    {
        try
        {
            int? userId = User.Identity?.IsAuthenticated == true
                ? int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!)
                : null;

            var result = await _predictionService.QuickPredictAsync(dto, userId);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { error = ex.Message });
        }
    }

    [HttpGet("history")]
    public async Task<IActionResult> GetPredictionHistory([FromQuery] int limit = 10)
    {
        var (predictions, avgScore, total) = await _predictionService.GetPredictionHistoryAsync(GetUserId(), limit);
        return Ok(new
        {
            count = predictions.Count,
            total_predictions = total,
            average_score = avgScore,
            predictions
        });
    }

    // ==================== Weekly Logs ====================

    [HttpGet("weekly")]
    public async Task<IActionResult> GetWeeklyLog([FromQuery] DateOnly? weekStartDate)
    {
        var log = await _predictionService.GetWeeklyLogAsync(GetUserId(), weekStartDate);
        if (log == null)
            return NotFound(new { error = "No weekly log found." });
        return Ok(log);
    }

    [HttpPost("weekly")]
    public async Task<IActionResult> CreateOrUpdateWeeklyLog([FromBody] WeeklyLogDto dto)
    {
        var log = await _predictionService.CreateOrUpdateWeeklyLogAsync(GetUserId(), dto);
        return Ok(log);
    }

    // ==================== Model Info & Dashboard ====================

    [HttpGet("model-info")]
    [AllowAnonymous]
    public IActionResult GetModelInfo()
    {
        var info = _predictionService.GetModelInfo();
        return Ok(info);
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> GetDashboard()
    {
        var dashboard = await _predictionService.GetDashboardAsync(GetUserId());
        return Ok(dashboard);
    }
}
