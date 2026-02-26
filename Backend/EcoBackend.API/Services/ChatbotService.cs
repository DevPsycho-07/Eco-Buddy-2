using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using LLama;
using LLama.Common;
using LLama.Sampling;
using EcoChatSession = EcoBackend.Core.Entities.ChatSession;

namespace EcoBackend.API.Services;

// â”€â”€ Singleton model host (loads once at startup) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// <summary>
/// Singleton that owns the loaded LLamaWeights instance for the lifetime of the
/// application. Mirrors Django's LlmService singleton pattern.
/// </summary>
public class LlamaModelService : IDisposable
{
    private LLamaWeights? _model;
    private ModelParams? _modelParams;
    private readonly ILogger<LlamaModelService> _logger;
    private readonly string? _modelPath;
    private string? _loadError;
    private bool _isReady;

    public bool IsReady => _isReady;
    public string? LoadError => _loadError;

    public LlamaModelService(IConfiguration configuration, ILogger<LlamaModelService> logger)
    {
        _logger = logger;
        _modelPath = configuration["Chatbot:ModelPath"];
    }

    /// <summary>Load the model. Called once from IHostedService/startup.</summary>
    public void Load()
    {
        if (_isReady) return;

        if (string.IsNullOrWhiteSpace(_modelPath) || !File.Exists(_modelPath))
        {
            _loadError = string.IsNullOrWhiteSpace(_modelPath)
                ? "Chatbot:ModelPath is not configured."
                : $"Model file not found: {_modelPath}";
            _logger.LogWarning("EcoBot model unavailable: {Error}", _loadError);
            return;
        }

        try
        {
            _logger.LogInformation("Loading EcoBot model from {Path}â€¦", _modelPath);
            _modelParams = new ModelParams(_modelPath)
            {
                ContextSize = 4096,
                GpuLayerCount = 0 // 0 = CPU-only; increase if GPU available
            };
            _model = LLamaWeights.LoadFromFile(_modelParams);
            _isReady = true;
            _logger.LogInformation("EcoBot model loaded successfully.");
        }
        catch (Exception ex)
        {
            _loadError = ex.Message;
            _logger.LogError(ex, "Failed to load EcoBot model.");
        }
    }

    /// <summary>Get weights + params needed to construct a StatelessExecutor.</summary>
    public (LLamaWeights Weights, ModelParams Params)? GetExecutorContext()
    {
        if (_model == null || _modelParams == null) return null;
        return (_model, _modelParams);
    }

    public void Dispose()
    {
        _model?.Dispose();
    }
}

// â”€â”€ Background loader â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

public class LlamaModelLoaderService : IHostedService
{
    private readonly LlamaModelService _modelService;
    public LlamaModelLoaderService(LlamaModelService modelService) => _modelService = modelService;

    public Task StartAsync(CancellationToken ct) { Task.Run(_modelService.Load); return Task.CompletedTask; }
    public Task StopAsync(CancellationToken ct) => Task.CompletedTask;
}

// â”€â”€ ChatbotService â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// <summary>
/// Manages chat sessions/messages and delegates inference to LLamaSharp (local
/// GGUF) or optionally an HTTP-based OpenAI-compatible endpoint as fallback.
/// </summary>
public class ChatbotService
{
    private readonly EcoDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly LlamaModelService _llamaModel;

    // ChatML prompt format used by Qwen and most modern GGUF finetunes
    private const string ImStart = "<|im_start|>";
    private const string ImEnd   = "<|im_end|>";

    private const string BaseSystemPrompt =
        "You are EcoBot, a friendly and knowledgeable AI assistant specialised in " +
        "sustainability, carbon emissions, and eco-friendly living. " +
        "You answer questions, explain concepts, and give practical tips related to " +
        "carbon footprint, renewable energy, recycling, sustainable transport, food impact, " +
        "and environmental best practices. " +
        "You do NOT re-calculate or alter the user's eco score â€” that is handled by a " +
        "separate ML system. You CAN reference the score and recent data provided to you " +
        "to give personalised, data-aware advice. " +
        "If a question is unrelated to sustainability or environmental topics, " +
        "you MUST NOT provide any information or direct answer. " +
        "Instead, simply and politely decline and state that it is outside your area of expertise. " +
        "Keep responses concise, helpful, and conversational.";

    public ChatbotService(
        EcoDbContext context,
        IConfiguration configuration,
        IHttpClientFactory httpClientFactory,
        LlamaModelService llamaModel)
    {
        _context = context;
        _configuration = configuration;
        _httpClientFactory = httpClientFactory;
        _llamaModel = llamaModel;
    }

    // â”€â”€ Status â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    public bool IsModelReady => _llamaModel.IsReady || !string.IsNullOrWhiteSpace(_configuration["Chatbot:Endpoint"]);
    public string? LoadError => _llamaModel.IsReady ? null : _llamaModel.LoadError;

    // â”€â”€ Chat â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    public async Task<(ChatResponseDto Response, string? Error)> ChatAsync(int userId, ChatRequestDto dto)
    {
        // Resolve or create session
        EcoChatSession session;
        if (dto.SessionId.HasValue)
        {
            var found = await _context.ChatSessions
                .FirstOrDefaultAsync(s => s.Id == dto.SessionId.Value && s.UserId == userId);
            if (found == null)
                return (null!, "Session not found or does not belong to you.");
            session = found;
        }
        else
        {
            session = new EcoChatSession
            {
                UserId = userId,
                Title = dto.Message.Length <= 60 ? dto.Message : dto.Message[..60]
            };
            _context.ChatSessions.Add(session);
            await _context.SaveChangesAsync();
        }

        // Load recent history (last 20 turns, in chronological order)
        var history = await _context.ChatMessages
            .Where(m => m.SessionId == session.Id)
            .OrderByDescending(m => m.CreatedAt)
            .Take(20)
            .OrderBy(m => m.CreatedAt)
            .Select(m => new { m.Role, m.Content })
            .ToListAsync();

        var systemPrompt = await BuildPersonalisedSystemPromptAsync(userId);

        // Infer
        string reply;
        if (_llamaModel.IsReady)
        {
            var (inferredReply, inferError) = await InferLocalAsync(systemPrompt, history.Select(h => (h.Role, h.Content)).ToList(), dto.Message, dto.MaxTokens, (float)dto.Temperature);
            if (inferError != null) return (null!, inferError);
            reply = inferredReply;
        }
        else if (!string.IsNullOrWhiteSpace(_configuration["Chatbot:Endpoint"]))
        {
            var (inferredReply, inferError) = await InferHttpAsync(systemPrompt, history.Select(h => (h.Role, h.Content)).ToList(), dto.Message, dto.MaxTokens, dto.Temperature);
            if (inferError != null) return (null!, inferError);
            reply = inferredReply;
        }
        else
        {
            var err = _llamaModel.LoadError ?? "EcoBot model is not available. Check Chatbot:ModelPath in appsettings.";
            return (null!, err);
        }

        // Persist both turns
        _context.ChatMessages.AddRange(
            new ChatMessage { SessionId = session.Id, Role = "user",      Content = dto.Message },
            new ChatMessage { SessionId = session.Id, Role = "assistant", Content = reply }
        );
        session.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        var messageCount = await _context.ChatMessages.CountAsync(m => m.SessionId == session.Id);

        return (new ChatResponseDto
        {
            SessionId = session.Id,
            Reply = reply,
            HistoryLength = messageCount
        }, null);
    }

    // â”€â”€ Sessions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    public async Task<List<ChatSessionListDto>> GetSessionsAsync(int userId)
    {
        return await _context.ChatSessions
            .Where(s => s.UserId == userId)
            .OrderByDescending(s => s.UpdatedAt)
            .Select(s => new ChatSessionListDto
            {
                Id = s.Id,
                Title = s.Title,
                MessageCount = s.Messages.Count,
                CreatedAt = s.CreatedAt,
                UpdatedAt = s.UpdatedAt
            })
            .ToListAsync();
    }

    public async Task<int> DeleteAllSessionsAsync(int userId)
    {
        var sessions = await _context.ChatSessions.Where(s => s.UserId == userId).ToListAsync();
        _context.ChatSessions.RemoveRange(sessions);
        await _context.SaveChangesAsync();
        return sessions.Count;
    }

    public async Task<ChatSessionDetailDto?> GetSessionDetailAsync(int userId, Guid sessionId)
    {
        var session = await _context.ChatSessions
            .Include(s => s.Messages.OrderBy(m => m.CreatedAt))
            .FirstOrDefaultAsync(s => s.Id == sessionId && s.UserId == userId);
        if (session == null) return null;

        return new ChatSessionDetailDto
        {
            Id = session.Id,
            Title = session.Title,
            MessageCount = session.Messages.Count,
            CreatedAt = session.CreatedAt,
            UpdatedAt = session.UpdatedAt,
            Messages = session.Messages.Select(m => new ChatMessageDto
            {
                Id = m.Id, Role = m.Role, Content = m.Content, CreatedAt = m.CreatedAt
            }).ToList()
        };
    }

    public async Task<bool> DeleteSessionAsync(int userId, Guid sessionId)
    {
        var session = await _context.ChatSessions.FirstOrDefaultAsync(s => s.Id == sessionId && s.UserId == userId);
        if (session == null) return false;
        _context.ChatSessions.Remove(session);
        await _context.SaveChangesAsync();
        return true;
    }

    // â”€â”€ Local GGUF inference via LLamaSharp â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    private async Task<(string Reply, string? Error)> InferLocalAsync(
        string systemPrompt,
        List<(string Role, string Content)> history,
        string userMessage,
        int maxTokens,
        float temperature)
    {
        try
        {
            var execCtx = _llamaModel.GetExecutorContext();
            if (execCtx == null)
                return (string.Empty, "Model weights not available.");

            var executor = new StatelessExecutor(execCtx.Value.Weights, execCtx.Value.Params);

            // Build ChatML prompt
            var prompt = BuildChatMLPrompt(systemPrompt, history, userMessage);

            var inferParams = new InferenceParams
            {
                MaxTokens = maxTokens,
                SamplingPipeline = new DefaultSamplingPipeline { Temperature = temperature },
                AntiPrompts = new List<string> { ImStart, "User:", "\nUser:" }
            };

            var sb = new System.Text.StringBuilder();
            await foreach (var token in executor.InferAsync(prompt, inferParams))
                sb.Append(token);

            var reply = sb.ToString().Trim().Replace(ImEnd, string.Empty).Trim();
            return (reply, null);
        }
        catch (Exception ex)
        {
            return (string.Empty, $"Inference error: {ex.Message}");
        }
    }

    /// <summary>Build a ChatML-formatted prompt string.</summary>
    private static string BuildChatMLPrompt(
        string systemPrompt,
        List<(string Role, string Content)> history,
        string userMessage)
    {
        var sb = new System.Text.StringBuilder();
        sb.Append(ImStart).Append("system\n").Append(systemPrompt).AppendLine(ImEnd);

        foreach (var (role, content) in history)
            sb.Append(ImStart).Append(role).Append('\n').Append(content).AppendLine(ImEnd);

        sb.Append(ImStart).Append("user\n").Append(userMessage).AppendLine(ImEnd);
        sb.Append(ImStart).Append("assistant\n"); // model continues from here

        return sb.ToString();
    }

    // â”€â”€ HTTP OpenAI-compatible fallback â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    private async Task<(string Reply, string? Error)> InferHttpAsync(
        string systemPrompt,
        List<(string Role, string Content)> history,
        string userMessage,
        int maxTokens,
        double temperature)
    {
        try
        {
            var endpoint = _configuration["Chatbot:Endpoint"]!;
            var apiKey   = _configuration["Chatbot:ApiKey"] ?? string.Empty;
            var model    = _configuration["Chatbot:Model"]  ?? "gpt-3.5-turbo";

            var messages = new List<object>();
            messages.Add(new { role = "system", content = systemPrompt });
            foreach (var (role, content) in history)
                messages.Add(new { role, content });
            messages.Add(new { role = "user", content = userMessage });

            var body = new { model, messages, max_tokens = maxTokens, temperature };

            var client = _httpClientFactory.CreateClient("chatbot");
            if (!string.IsNullOrEmpty(apiKey))
                client.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");

            var response = await client.PostAsJsonAsync(endpoint, body);
            if (!response.IsSuccessStatusCode)
                return (string.Empty, $"LLM API error: {response.StatusCode}");

            using var doc = await System.Text.Json.JsonDocument.ParseAsync(
                await response.Content.ReadAsStreamAsync());
            var reply = doc.RootElement
                .GetProperty("choices")[0]
                .GetProperty("message")
                .GetProperty("content")
                .GetString() ?? string.Empty;

            return (reply.Trim(), null);
        }
        catch (Exception ex)
        {
            return (string.Empty, $"Inference error: {ex.Message}");
        }
    }

    // â”€â”€ System prompt builder â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

    private async Task<string> BuildPersonalisedSystemPromptAsync(int userId)
    {
        var lines = new List<string> { BaseSystemPrompt, "" };
        try
        {
            var user = await _context.Users.FindAsync(userId);
            if (user != null)
            {
                var fullName = $"{user.FirstName} {user.LastName}".Trim();
                if (!string.IsNullOrEmpty(fullName))
                    lines.Add($"The user's name is {fullName}.");
            }

            var profile = await _context.UserEcoProfiles.FirstOrDefaultAsync(p => p.UserId == userId);
            if (profile != null)
                lines.Add($"Their eco profile: diet={profile.DietType}, vehicle={profile.VehicleType}, " +
                          $"lifestyle={profile.LifestyleType}, location={profile.LocationType}, " +
                          $"household_size={profile.HouseholdSize}, recycling={profile.RecyclingPracticed}, " +
                          $"composting={profile.CompostingPracticed}, solar_panels={profile.UsesSolarPanels}, " +
                          $"renewable_energy={profile.RenewableEnergyPercent}%.");

            var recentLogs = await _context.DailyLogs
                .Where(l => l.UserId == userId)
                .OrderByDescending(l => l.Date)
                .Take(7)
                .ToListAsync();

            var scored = recentLogs.FirstOrDefault(l => l.EcoScore.HasValue);
            if (scored != null)
                lines.Add($"Their latest eco score is {scored.EcoScore:F1}/100 ({scored.ScoreCategory}). You may reference this when giving advice.");
            else
                lines.Add("The user has not yet received an eco score â€” encourage them to log their daily activities in the app.");
        }
        catch { /* silently fall back */ }

        return string.Join("\n", lines);
    }
}
