using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using EcoBackend.Infrastructure.Data;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/travel")]
[Authorize]
public class TravelController : ControllerBase
{
    private readonly EcoDbContext _context;
    
    public TravelController(EcoDbContext context)
    {
        _context = context;
    }
    
    [HttpGet("trips")]
    public async Task<IActionResult> GetTrips([FromQuery] DateTime? startDate, [FromQuery] DateTime? endDate)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        
        var query = _context.Trips.Where(t => t.UserId == userId);
        
        if (startDate.HasValue)
            query = query.Where(t => t.TripDate >= startDate.Value);
        if (endDate.HasValue)
            query = query.Where(t => t.TripDate <= endDate.Value);
        
        var trips = await query.OrderByDescending(t => t.TripDate).ToListAsync();
        
        return Ok(trips);
    }
    
    [HttpGet("summary")]
    public async Task<IActionResult> GetTravelSummary([FromQuery] DateTime? date)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var targetDate = date ?? DateTime.UtcNow.Date;
        
        var summary = await _context.TravelSummaries
            .FirstOrDefaultAsync(ts => ts.UserId == userId && ts.Date == targetDate);
        
        if (summary == null)
        {
            return Ok(new { message = "No travel data for this date" });
        }
        
        return Ok(summary);
    }
}
