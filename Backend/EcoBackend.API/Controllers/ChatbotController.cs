using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using EcoBackend.API.DTOs;
using EcoBackend.API.Services;

namespace EcoBackend.API.Controllers;

/// <summary>
/// EcoBot chatbot endpoints — mirrors Django chatbot app.
/// Routes:
///   POST   /api/chatbot/chat                     – send message, get reply
///   GET    /api/chatbot/sessions                  – list sessions
///   DELETE /api/chatbot/sessions                  – delete ALL sessions
///   GET    /api/chatbot/sessions/{session_id}      – get session with messages
///   DELETE /api/chatbot/sessions/{session_id}      – delete single session
///   GET    /api/chatbot/status                     – model/service status
/// </summary>
[ApiController]
[Route("api/chatbot")]
[Authorize]
public class ChatbotController : ControllerBase
{
    private readonly ChatbotService _chatbotService;

    public ChatbotController(ChatbotService chatbotService)
    {
        _chatbotService = chatbotService;
    }

    private int UserId => int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);

    // ── Chat ──────────────────────────────────────────────────────────────────

    /// <summary>
    /// Send a message to EcoBot and receive a reply.
    /// Omit session_id to start a new session.
    /// </summary>
    [HttpPost("chat")]
    public async Task<IActionResult> Chat([FromBody] ChatRequestDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Message))
            return BadRequest(new { message = new[] { "Message field is required." } });

        if (dto.Message.Length > 2000)
            return BadRequest(new { message = new[] { "Message must be 2000 characters or fewer." } });

        if (dto.MaxTokens < 32 || dto.MaxTokens > 2048)
            return BadRequest(new { max_tokens = new[] { "max_tokens must be between 32 and 2048." } });

        if (dto.Temperature < 0.0 || dto.Temperature > 2.0)
            return BadRequest(new { temperature = new[] { "temperature must be between 0.0 and 2.0." } });

        var (response, error) = await _chatbotService.ChatAsync(UserId, dto);

        if (error != null)
        {
            if (error.Contains("Session not found"))
                return NotFound(new { error });
            return StatusCode(503, new { error });
        }

        return Ok(response);
    }

    // ── Sessions ──────────────────────────────────────────────────────────────

    /// <summary>
    /// GET  – list all sessions (lightweight, no messages).
    /// DELETE – delete ALL sessions for the authenticated user.
    /// </summary>
    [HttpGet("sessions")]
    public async Task<IActionResult> ListSessions()
    {
        var sessions = await _chatbotService.GetSessionsAsync(UserId);
        return Ok(sessions);
    }

    [HttpDelete("sessions")]
    public async Task<IActionResult> DeleteAllSessions()
    {
        var count = await _chatbotService.DeleteAllSessionsAsync(UserId);
        return Ok(new DeletedSessionsDto { DeletedSessions = count });
    }

    /// <summary>Full session including all messages.</summary>
    [HttpGet("sessions/{sessionId:guid}")]
    public async Task<IActionResult> GetSession(Guid sessionId)
    {
        var session = await _chatbotService.GetSessionDetailAsync(UserId, sessionId);
        if (session == null) return NotFound(new { error = "Session not found." });
        return Ok(session);
    }

    [HttpDelete("sessions/{sessionId:guid}")]
    public async Task<IActionResult> DeleteSession(Guid sessionId)
    {
        var deleted = await _chatbotService.DeleteSessionAsync(UserId, sessionId);
        if (!deleted) return NotFound(new { error = "Session not found." });
        return Ok(new { detail = "Session deleted." });
    }

    // ── Status ────────────────────────────────────────────────────────────────

    /// <summary>Returns current model/service status. Flutter can show a loading indicator.</summary>
    [HttpGet("status")]
    public IActionResult GetStatus()
    {
        return Ok(new ChatbotStatusDto
        {
            ModelReady = _chatbotService.IsModelReady,
            LoadError = _chatbotService.LoadError
        });
    }
}
