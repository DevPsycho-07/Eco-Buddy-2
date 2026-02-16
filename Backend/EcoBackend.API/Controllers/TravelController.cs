using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text.Json;
using EcoBackend.API.DTOs;
using EcoBackend.API.Services;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/travel")]
[Authorize]
public class TravelController : ControllerBase
{
    private readonly TravelService _travelService;

    public TravelController(TravelService travelService)
    {
        _travelService = travelService;
    }

    #region Trip Endpoints

    [HttpGet("trips")]
    public async Task<IActionResult> GetTrips(
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate,
        [FromQuery] string? mode)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var trips = await _travelService.GetTripsAsync(userId, startDate, endDate, mode);
        return Ok(trips);
    }

    [HttpGet("trips/today")]
    public async Task<IActionResult> GetTodaysTrips()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var trips = await _travelService.GetTodaysTripsAsync(userId);
        return Ok(trips);
    }

    [HttpGet("trips/stats")]
    public async Task<IActionResult> GetTripStats([FromQuery] int days = 7)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var stats = await _travelService.GetTripStatsAsync(userId, days);
        return Ok(stats);
    }

    [HttpPost("trips")]
    public async Task<IActionResult> CreateTrip([FromBody] CreateTripDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var trip = await _travelService.CreateTripAsync(userId, dto);
        return CreatedAtAction(nameof(GetTrips), new { }, trip);
    }

    [HttpPut("trips/{id}")]
    public async Task<IActionResult> UpdateTrip(int id, [FromBody] UpdateTripDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var trip = await _travelService.UpdateTripAsync(id, userId, dto);
        if (trip == null) return NotFound(new { error = "Trip not found" });
        return Ok(trip);
    }

    [HttpDelete("trips/{id}")]
    public async Task<IActionResult> DeleteTrip(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var deleted = await _travelService.DeleteTripAsync(id, userId);
        if (!deleted) return NotFound(new { error = "Trip not found" });
        return Ok(new { message = "Trip deleted successfully" });
    }

    [HttpGet("trips/{id}")]
    public async Task<IActionResult> GetTripById(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var trip = await _travelService.GetTripByIdAsync(id, userId);
        if (trip == null) return NotFound(new { error = "Trip not found" });
        return Ok(trip);
    }

    [HttpPatch("trips/{id}")]
    public async Task<IActionResult> PartialUpdateTrip(int id, [FromBody] JsonElement updates)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var trip = await _travelService.PartialUpdateTripAsync(id, userId, updates);
        if (trip == null) return NotFound(new { error = "Trip not found" });
        return Ok(trip);
    }

    #endregion

    #region Location Endpoints

    [HttpPost("locations/batch")]
    public async Task<IActionResult> BatchUploadLocations([FromBody] BatchLocationPointsDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var (count, points) = await _travelService.BatchUploadLocationsAsync(userId, dto);
        return Ok(new { created = count, points });
    }

    [HttpGet("location-points")]
    public async Task<IActionResult> GetLocationPoints([FromQuery] int? tripId, [FromQuery] DateTime? startTime, [FromQuery] DateTime? endTime)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var points = await _travelService.GetLocationPointsAsync(userId, tripId, startTime, endTime);
        return Ok(points);
    }

    [HttpPost("location-points")]
    public async Task<IActionResult> CreateLocationPoint([FromBody] CreateLocationPointDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var point = await _travelService.CreateLocationPointAsync(userId, dto);
        return CreatedAtAction(nameof(GetLocationPointById), new { id = point.Id }, point);
    }

    [HttpGet("location-points/{id}")]
    public async Task<IActionResult> GetLocationPointById(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var point = await _travelService.GetLocationPointByIdAsync(id, userId);
        if (point == null) return NotFound(new { error = "Location point not found" });
        return Ok(point);
    }

    [HttpPut("location-points/{id}")]
    public async Task<IActionResult> UpdateLocationPoint(int id, [FromBody] CreateLocationPointDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var point = await _travelService.UpdateLocationPointAsync(id, userId, dto);
        if (point == null) return NotFound(new { error = "Location point not found" });
        return Ok(point);
    }

    [HttpDelete("location-points/{id}")]
    public async Task<IActionResult> DeleteLocationPoint(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var deleted = await _travelService.DeleteLocationPointAsync(id, userId);
        if (!deleted) return NotFound(new { error = "Location point not found" });
        return Ok(new { message = "Location point deleted successfully" });
    }

    #endregion

    #region Travel Summary Endpoints

    [HttpGet("summary")]
    public async Task<IActionResult> GetTravelSummary([FromQuery] DateTime? date)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var summary = await _travelService.GetTravelSummaryAsync(userId, date);
        if (summary == null) return Ok(new { message = "No travel data for this date" });
        return Ok(summary);
    }

    [HttpGet("summary/weekly")]
    public async Task<IActionResult> GetWeeklySummary()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var summaries = await _travelService.GetWeeklySummaryAsync(userId);
        return Ok(summaries);
    }

    [HttpPost("steps")]
    public async Task<IActionResult> UpdateSteps([FromBody] UpdateStepsDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var result = await _travelService.UpdateStepsAsync(userId, dto);
        return Ok(result);
    }

    [HttpGet("summary/{id}")]
    public async Task<IActionResult> GetSummaryById(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var summary = await _travelService.GetSummaryByIdAsync(id, userId);
        if (summary == null) return NotFound(new { error = "Travel summary not found" });
        return Ok(summary);
    }

    [HttpPatch("summary/{id}")]
    public async Task<IActionResult> PartialUpdateSummary(int id, [FromBody] JsonElement updates)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var summary = await _travelService.PartialUpdateSummaryAsync(id, userId, updates);
        if (summary == null) return NotFound(new { error = "Travel summary not found" });
        return Ok(summary);
    }

    #endregion
}
