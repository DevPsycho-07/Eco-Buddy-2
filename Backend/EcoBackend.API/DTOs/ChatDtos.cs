namespace EcoBackend.API.DTOs;

// ── Requests ──────────────────────────────────────────────────────────────────

public class ChatRequestDto
{
    public string Message { get; set; } = string.Empty;
    public Guid? SessionId { get; set; }
    public int MaxTokens { get; set; } = 512;
    public double Temperature { get; set; } = 0.7;
}

// ── Responses ─────────────────────────────────────────────────────────────────

public class ChatResponseDto
{
    public Guid SessionId { get; set; }
    public string Reply { get; set; } = string.Empty;
    public int HistoryLength { get; set; }
}

public class ChatMessageDto
{
    public int Id { get; set; }
    public string Role { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class ChatSessionListDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public int MessageCount { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class ChatSessionDetailDto : ChatSessionListDto
{
    public List<ChatMessageDto> Messages { get; set; } = new();
}

public class ChatbotStatusDto
{
    public bool ModelReady { get; set; }
    public string? LoadError { get; set; }
}

public class DeletedSessionsDto
{
    public int DeletedSessions { get; set; }
}
