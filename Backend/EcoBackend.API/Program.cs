using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using Hangfire;
using Hangfire.MemoryStorage;
using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;

// Allow DateTime with Kind=Unspecified to be mapped to PostgreSQL 'timestamp with time zone'
// (legacy Npgsql 5.x behavior; avoids 500s from `new DateTime(y,m,d)` values across services).
AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

// Load .env file
var envPath = Path.Combine(Directory.GetCurrentDirectory(), "..", ".env");
if (File.Exists(envPath))
{
    foreach (var line in File.ReadAllLines(envPath))
    {
        if (string.IsNullOrWhiteSpace(line) || line.StartsWith("#"))
            continue;
        
        var parts = line.Split('=', 2);
        if (parts.Length == 2)
            Environment.SetEnvironmentVariable(parts[0].Trim(), parts[1].Trim().Trim('"'));
    }
}

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.SnakeCaseLower;
    });
builder.Services.AddEndpointsApiExplorer();

// Configure Swagger with JWT support
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "Eco Daily Score API",
        Version = "v1.0.0",
        Description = "API for tracking eco-friendly activities and carbon footprint"
    });
    
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token.",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// Configure Database (skipped in Testing env — factory registers InMemory instead)
if (!builder.Environment.IsEnvironment("Testing"))
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "";
    var pgPassword = Environment.GetEnvironmentVariable("POSTGRES_PASS");
    if (!string.IsNullOrEmpty(pgPassword))
        connectionString += $";Password={pgPassword}";

    builder.Services.AddDbContext<EcoDbContext>(options =>
        options.UseNpgsql(connectionString,
            b => b.MigrationsAssembly("EcoBackend.Infrastructure")));
}

// Configure Identity
builder.Services.AddIdentity<User, IdentityRole<int>>(options =>
{
    options.Password.RequireDigit = false;
    options.Password.RequireLowercase = false;
    options.Password.RequireUppercase = false;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequiredLength = 6;
    options.User.RequireUniqueEmail = true;
    // Allow spaces and other characters in usernames
    options.User.AllowedUserNameCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@+ ";
})
.AddEntityFrameworkStores<EcoDbContext>()
.AddDefaultTokenProviders();

// Configure JWT Authentication
var jwtSecret = builder.Configuration["JWT:Secret"] ?? "your-secret-key-here-min-32-chars-long!";
var key = Encoding.UTF8.GetBytes(jwtSecret);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["JWT:ValidIssuer"] ?? "EcoBackend",
        ValidAudience = builder.Configuration["JWT:ValidAudience"] ?? "EcoBackendClient",
        IssuerSigningKey = new SymmetricSecurityKey(key)
    };
});

// Configure CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Configure Hangfire
builder.Services.AddHangfire(config => config
    .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
    .UseSimpleAssemblyNameTypeSerializer()
    .UseRecommendedSerializerSettings()
    .UseMemoryStorage());

builder.Services.AddHangfireServer();

// Register services
builder.Services.AddHttpClient(); // required by ChatbotService
builder.Services.AddSingleton<EcoBackend.API.Services.LlamaModelService>();
builder.Services.AddHostedService<EcoBackend.API.Services.LlamaModelLoaderService>();
builder.Services.AddScoped<EcoBackend.API.Services.AchievementService>();
builder.Services.AddScoped<EcoBackend.API.Services.EmailService>();
builder.Services.AddScoped<EcoBackend.API.Services.NotificationService>();
builder.Services.AddScoped<EcoBackend.API.Services.BackgroundJobService>();
builder.Services.AddSingleton<EcoBackend.API.Services.ProfilePictureEncryptionService>();
builder.Services.AddScoped<EcoBackend.API.Services.ActivityService>();
builder.Services.AddScoped<EcoBackend.API.Services.AnalyticsService>();
builder.Services.AddScoped<EcoBackend.API.Services.TravelService>();
builder.Services.AddScoped<EcoBackend.API.Services.UserService>();
builder.Services.AddSingleton<EcoBackend.API.Services.EcoScorePredictorService>();
builder.Services.AddScoped<EcoBackend.API.Services.PredictionService>();
builder.Services.AddScoped<EcoBackend.API.Services.DailyScoreService>();
builder.Services.AddScoped<EcoBackend.API.Services.GoalService>();
builder.Services.AddScoped<EcoBackend.API.Services.ChatbotService>();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "Eco Daily Score API v1");
        c.RoutePrefix = string.Empty; // Serve Swagger UI at root
        c.EnableFilter();
    });
}

app.UseCors("AllowAll");

// Strip trailing slashes so Flutter URLs like /api/users/profile/ match routes
app.Use(async (context, next) =>
{
    var path = context.Request.Path.Value;
    if (path != "/" && path?.EndsWith("/") == true)
        context.Request.Path = path.TrimEnd('/');
    await next();
});

// Serve static files from media folder
var mediaPath = Path.Combine(Directory.GetCurrentDirectory(), "media");
Directory.CreateDirectory(mediaPath); // Create media directory if it doesn't exist

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(mediaPath),
    RequestPath = "/media"
});

app.UseAuthentication();
app.UseAuthorization();

// Configure Hangfire Dashboard (accessible at /hangfire)
app.UseHangfireDashboard("/hangfire", new DashboardOptions
{
    Authorization = new[] { new HangfireAuthorizationFilter() }
});

app.MapControllers();

// Root endpoint
app.MapGet("/api", () => new
{
    message = "Welcome to Eco Daily Score API",
    version = "1.0.0",
    endpoints = new
    {
        users = "/api/users",
        activities = "/api/activities",
        achievements = "/api/achievements",
        travel = "/api/travel",
        analytics = "/api/analytics",
        predictions = "/api/predictions",
        chatbot = "/api/chatbot"
    }
});

// Ensure database exists and seed admin user
if (!app.Environment.IsEnvironment("Testing"))
{
    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<EcoDbContext>();
    context.Database.EnsureCreated();

    // Seed admin superuser if not exists
    var userManager = scope.ServiceProvider.GetRequiredService<UserManager<User>>();
    var adminEmail = "admin@eco.com";
    if (await userManager.FindByEmailAsync(adminEmail) == null)
    {
        var admin = new User
        {
            UserName = "admin",
            Email = adminEmail,
            FirstName = "Admin",
            LastName = "User",
            EmailConfirmed = true,
            CreatedAt = DateTime.UtcNow
        };
        await userManager.CreateAsync(admin, "Admin123");
    }
}

// Configure recurring background jobs
RecurringJob.AddOrUpdate<EcoBackend.API.Services.BackgroundJobService>(
    "calculate-daily-streaks",
    service => service.CalculateDailyStreaksAsync(),
    "0 0 * * *", // Daily at midnight UTC
    new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc });

RecurringJob.AddOrUpdate<EcoBackend.API.Services.BackgroundJobService>(
    "generate-weekly-reports",
    service => service.GenerateWeeklyReportsAsync(),
    "0 1 * * 1", // Every Monday at 1 AM UTC
    new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc });

RecurringJob.AddOrUpdate<EcoBackend.API.Services.BackgroundJobService>(
    "generate-monthly-reports",
    service => service.GenerateMonthlyReportsAsync(),
    "0 2 1 * *", // First day of month at 2 AM UTC
    new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc });

RecurringJob.AddOrUpdate<EcoBackend.API.Services.BackgroundJobService>(
    "check-badge-requirements",
    service => service.CheckBadgeRequirementsAsync(),
    "0 */6 * * *", // Every 6 hours
    new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc });

RecurringJob.AddOrUpdate<EcoBackend.API.Services.BackgroundJobService>(
    "cleanup-expired-tokens",
    service => service.CleanupExpiredTokensAsync(),
    "0 3 * * *", // Daily at 3 AM UTC
    new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc });

// Initialize default encrypted profile picture
var encryptionService = app.Services.GetRequiredService<EcoBackend.API.Services.ProfilePictureEncryptionService>();
await encryptionService.EnsureDefaultProfilePictureAsync();

app.Run();

/// <summary>
/// Authorization filter for Hangfire Dashboard
/// Only allow access in development or for authenticated admin users
/// </summary>
public class HangfireAuthorizationFilter : Hangfire.Dashboard.IDashboardAuthorizationFilter
{
    public bool Authorize(Hangfire.Dashboard.DashboardContext context)
    {
        // In development, allow all access
        // In production, this should check for admin role
        return true; // TODO: Implement proper authorization in production
    }
}

/// <summary>
/// Partial Program class for testing
/// </summary>
public partial class Program
{
}
