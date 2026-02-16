using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using EcoBackend.API.Services;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/analytics")]
[Authorize]
public class AnalyticsController : ControllerBase
{
    private readonly AnalyticsService _analyticsService;

    public AnalyticsController(AnalyticsService analyticsService)
    {
        _analyticsService = analyticsService;
    }

    [HttpGet("weekly")]
    public async Task<IActionResult> GetWeeklyReport([FromQuery] DateTime? weekStart)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var report = await _analyticsService.GetWeeklyReportAsync(userId, weekStart);
        if (report == null) return NotFound(new { message = "No weekly report found for this date" });
        return Ok(report);
    }

    [HttpGet("monthly")]
    public async Task<IActionResult> GetMonthlyReport([FromQuery] int? year, [FromQuery] int? month)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var report = await _analyticsService.GetMonthlyReportAsync(userId, year, month);
        if (report == null) return NotFound(new { message = "No monthly report found for this period" });
        return Ok(report);
    }

    [HttpGet("dashboard")]
    public async Task<IActionResult> GetDashboard()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var dashboard = await _analyticsService.GetDashboardAsync(userId);
        return Ok(dashboard);
    }

    [HttpGet("stats")]
    public async Task<IActionResult> GetStats([FromQuery] string period = "week")
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var stats = await _analyticsService.GetStatsAsync(userId, period);
        return Ok(stats);
    }

    [HttpGet("comparison")]
    public async Task<IActionResult> GetComparison()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var comparison = await _analyticsService.GetComparisonAsync(userId);
        return Ok(comparison);
    }

    [HttpGet("export/csv")]
    public async Task<IActionResult> ExportToCsv([FromQuery] string period = "month")
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var (content, fileName) = await _analyticsService.ExportToCsvAsync(userId, period);
        return File(content, "text/csv", fileName);
    }
}
