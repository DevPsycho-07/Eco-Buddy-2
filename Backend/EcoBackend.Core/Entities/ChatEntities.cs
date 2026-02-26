namespace EcoBackend.Core.Entities;

/// <summary>Groups messages for a single conversation thread (mirrors Django ChatSession).</summary>
public class ChatSession
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public int UserId { get; set; }
    public string Title { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public virtual User User { get; set; } = null!;
    public virtual ICollection<ChatMessage> Messages { get; set; } = new List<ChatMessage>();
}

/// <summary>A single user ↔ assistant turn inside a ChatSession.</summary>
public class ChatMessage
{
    public int Id { get; set; }
    public Guid SessionId { get; set; }
    public string Role { get; set; } = "user"; // "user" | "assistant"
    public string Content { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Navigation
    public virtual ChatSession Session { get; set; } = null!;
}
