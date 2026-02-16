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

    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var profile = await _predictionService.GetProfileAsync(userId);
        return Ok(profile);
    }

    [HttpPost("profile")]
    public async Task<IActionResult> CreateOrUpdateProfile([FromBody] UserEcoProfileDto profileDto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await _predictionService.CreateOrUpdateProfileAsync(userId, profileDto);
        return Ok(new { message = "Profile updated successfully" });
    }

    [HttpGet("daily-logs")]
    public async Task<IActionResult> GetDailyLogs([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var logs = await _predictionService.GetDailyLogsAsync(userId, startDate, endDate);
        return Ok(logs);
    }

    // Prediction stub endpoints - feature coming soon

    [HttpPost("predict")]
    public IActionResult Predict([FromBody] object data)
        => Ok(new { message = "Feature coming soon", status = "not_implemented" });

    [HttpPost("predict/quick")]
    public IActionResult QuickPredict([FromBody] object data)
        => Ok(new { message = "Feature coming soon", status = "not_implemented" });

    [HttpGet("history")]
    public IActionResult GetPredictionHistory()
        => Ok(new { message = "Feature coming soon", status = "not_implemented", data = new List<object>() });

    [HttpPost("trips")]
    public IActionResult PredictTrips([FromBody] object data)
        => Ok(new { message = "Feature coming soon", status = "not_implemented" });

    [HttpGet("trips")]
    public IActionResult GetTripPredictions()
        => Ok(new { message = "Feature coming soon", status = "not_implemented", data = new List<object>() });

    [HttpPost("daily")]
    public IActionResult PredictDaily([FromBody] object data)
        => Ok(new { message = "Feature coming soon", status = "not_implemented" });

    [HttpGet("daily")]
    public IActionResult GetDailyPredictions()
        => Ok(new { message = "Feature coming soon", status = "not_implemented", data = new List<object>() });

    [HttpGet("weekly")]
    public IActionResult GetWeeklyPredictions()
        => Ok(new { message = "Feature coming soon", status = "not_implemented", data = new List<object>() });

    [HttpPost("weekly")]
    public IActionResult PredictWeekly([FromBody] object data)
        => Ok(new { message = "Feature coming soon", status = "not_implemented" });

    [HttpGet("model-info")]
    public IActionResult GetModelInfo()
        => Ok(new {
            message = "Feature coming soon",
            status = "not_implemented",
            model = new { name = "Eco Prediction Model", version = "1.0.0", status = "in_development" }
        });

    [HttpGet("dashboard")]
    public IActionResult GetPredictionDashboard()
        => Ok(new { message = "Feature coming soon", status = "not_implemented" });

    [HttpPut("profile")]
    public IActionResult UpdateProfile([FromBody] object data)
        => Ok(new { message = "Feature coming soon", status = "not_implemented" });
}
