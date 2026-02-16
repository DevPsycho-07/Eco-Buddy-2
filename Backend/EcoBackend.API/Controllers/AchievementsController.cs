using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Text.Json;
using EcoBackend.API.DTOs;
using EcoBackend.API.Services;

namespace EcoBackend.API.Controllers;

[ApiController]
[Route("api/achievements")]
[Authorize]
public class AchievementsController : ControllerBase
{
    private readonly AchievementService _achievementService;

    public AchievementsController(AchievementService achievementService)
    {
        _achievementService = achievementService;
    }

    [HttpGet("badges")]
    public async Task<IActionResult> GetBadges()
    {
        var badges = await _achievementService.GetBadgesAsync();
        return Ok(badges);
    }

    [HttpGet("badges/{id}")]
    public async Task<IActionResult> GetBadgeById(int id)
    {
        var badge = await _achievementService.GetBadgeByIdAsync(id);
        if (badge == null) return NotFound(new { error = "Badge not found" });
        return Ok(badge);
    }

    [HttpGet("my-badges")]
    public async Task<IActionResult> GetMyBadges()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var badges = await _achievementService.GetMyBadgesAsync(userId);
        return Ok(badges);
    }

    [HttpGet("my-badges/{id}")]
    public async Task<IActionResult> GetMyBadgeById(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var badge = await _achievementService.GetMyBadgeByIdAsync(id, userId);
        if (badge == null) return NotFound(new { error = "User badge not found" });
        return Ok(badge);
    }

    [HttpGet("my-badges/summary")]
    public async Task<IActionResult> GetMyBadgesSummary()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var summary = await _achievementService.GetMyBadgesSummaryAsync(userId);
        return Ok(summary);
    }

    [HttpGet("challenges")]
    public async Task<IActionResult> GetChallenges()
    {
        var challenges = await _achievementService.GetChallengesAsync();
        return Ok(challenges);
    }

    [HttpGet("challenges/{id}")]
    public async Task<IActionResult> GetChallengeById(int id)
    {
        var challenge = await _achievementService.GetChallengeByIdAsync(id);
        if (challenge == null) return NotFound(new { error = "Challenge not found" });
        return Ok(challenge);
    }

    [HttpGet("challenges/active")]
    public async Task<IActionResult> GetActiveChallenges()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var challenges = await _achievementService.GetActiveChallengesAsync(userId);
        return Ok(challenges);
    }

    [HttpGet("my-challenges")]
    public async Task<IActionResult> GetMyChallenges()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var challenges = await _achievementService.GetMyChallengesAsync(userId);
        return Ok(challenges);
    }

    [HttpGet("my-challenges/{id}")]
    public async Task<IActionResult> GetMyChallengeById(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var challenge = await _achievementService.GetMyChallengeByIdAsync(id, userId);
        if (challenge == null) return NotFound(new { error = "User challenge not found" });
        return Ok(challenge);
    }

    [HttpGet("my-challenges/active")]
    public async Task<IActionResult> GetMyActiveChallenges()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var challenges = await _achievementService.GetMyActiveChallengesAsync(userId);
        return Ok(challenges);
    }

    [HttpGet("my-challenges/completed")]
    public async Task<IActionResult> GetCompletedChallenges()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var challenges = await _achievementService.GetCompletedChallengesAsync(userId);
        return Ok(challenges);
    }

    [HttpPost("challenges/{id}/join")]
    public async Task<IActionResult> JoinChallenge(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var (success, error) = await _achievementService.JoinChallengeAsync(id, userId);
        if (!success && error == "not_found") return NotFound();
        if (!success && error == "already_joined") return BadRequest(new { error = "Already joined this challenge" });
        return Ok(new { message = "Successfully joined challenge" });
    }

    [HttpPut("my-challenges/{id}")]
    public async Task<IActionResult> UpdateMyChallenge(int id, [FromBody] UpdateUserChallengeDto dto)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var challenge = await _achievementService.UpdateMyChallengeAsync(id, userId, dto);
        if (challenge == null) return NotFound(new { error = "User challenge not found" });
        return Ok(challenge);
    }

    [HttpPatch("my-challenges/{id}")]
    public async Task<IActionResult> PartialUpdateMyChallenge(int id, [FromBody] JsonElement updates)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var challenge = await _achievementService.PartialUpdateMyChallengeAsync(id, userId, updates);
        if (challenge == null) return NotFound(new { error = "User challenge not found" });
        return Ok(challenge);
    }

    [HttpDelete("my-challenges/{id}")]
    public async Task<IActionResult> LeaveChallenge(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var deleted = await _achievementService.LeaveChallengeAsync(id, userId);
        if (!deleted) return NotFound(new { error = "User challenge not found" });
        return Ok(new { message = "Successfully left challenge" });
    }

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var summary = await _achievementService.GetSummaryAsync(userId);
        return Ok(summary);
    }
}
