# 🛠️ Eco Daily Score - Developer Guide

Comprehensive guide for developers working on the Eco Daily Score backend.

**Version:** 1.0.0  
**Framework:** ASP.NET Core 8.0  
**Last Updated:** February 16, 2026

---

## 📑 Table of Contents

1. [Getting Started](#getting-started)
2. [Project Structure](#project-structure)
3. [Architecture](#architecture)
4. [Development Workflow](#development-workflow)
5. [Adding New Features](#adding-new-features)
6. [Testing Guidelines](#testing-guidelines)
7. [Code Standards](#code-standards)
8. [Database Management](#database-management)
9. [Debugging](#debugging)
10. [Common Tasks](#common-tasks)

---

## 🚀 Getting Started

### Prerequisites

- **.NET 8 SDK** - [Download](https://dotnet.microsoft.com/download/dotnet/8.0)
- **Visual Studio 2022** (recommended) or **VS Code**
- **SQLite Viewer** (optional, for database inspection)
- **Postman** (optional, for API testing)
- **Git** for version control

### Initial Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Backend
   ```

2. **Restore NuGet packages**
   ```bash
   dotnet restore
   ```

3. **Set up configuration**
   
   Copy `appsettings.json` to `appsettings.Development.json` and update:
   ```json
   {
     "JWT": {
       "Secret": "your-development-secret-key-min-32-chars-long!",
       "ValidIssuer": "EcoBackendAPI",
       "ValidAudience": "EcoBackendClient",
       "ExpiryInHours": 24,
       "RefreshTokenExpiryInDays": 7
     },
     "EmailSettings": {
       "SmtpServer": "smtp.gmail.com",
       "SmtpPort": 587,
       "SenderEmail": "dev@example.com",
       "SenderName": "Eco Daily Score Dev",
       "Username": "dev@example.com",
       "Password": "your-app-password"
     },
     "Firebase": {
       "CredentialsPath": "path/to/firebase-credentials-dev.json"
     },
     "ConnectionStrings": {
       "DefaultConnection": "Data Source=eco_dev.db"
     }
   }
   ```

4. **Apply database migrations**
   ```bash
   cd EcoBackend.Infrastructure
   dotnet ef database update --startup-project ../EcoBackend.API
   ```

5. **Run the application**
   ```bash
   cd ../EcoBackend.API
   dotnet run
   ```

6. **Verify setup**
   - Open browser: `https://localhost:7162/swagger`
   - Check health: `GET https://localhost:7162/health`

---

## 📁 Project Structure

```
Backend/
├── EcoBackend.slnx                          # Solution file
│
├── EcoBackend.API/                          # Presentation Layer
│   ├── Controllers/                         # API endpoints (6 controllers)
│   │   ├── AchievementsController.cs        # Badges & challenges (17 endpoints)
│   │   ├── ActivitiesController.cs          # Activities CRUD (13 endpoints)
│   │   ├── AnalyticsController.cs           # Reports & stats (6 endpoints)
│   │   ├── PredictionsController.cs         # ML endpoints (16 stubs)
│   │   ├── TravelController.cs              # Trips & locations (19 endpoints)
│   │   └── UsersController.cs               # Auth & profile (37 endpoints)
│   │
│   ├── Services/                            # Business logic layer (12 services)
│   │   ├── AchievementService.cs            # Badge/challenge logic
│   │   ├── ActivityService.cs               # Activity operations
│   │   ├── AnalyticsService.cs              # Reports & analytics
│   │   ├── DailyScoreService.cs             # Daily score tracking
│   │   ├── EmailService.cs                  # Email notifications (MailKit)
│   │   ├── GoalService.cs                   # User goals
│   │   ├── NotificationService.cs           # Push notifications (Firebase)
│   │   ├── PredictionService.cs             # ML stub service
│   │   ├── ProfilePictureEncryptionService.cs # AES-256 encryption
│   │   ├── TravelService.cs                 # Trip management
│   │   └── UserService.cs                   # User operations
│   │
│   ├── DTOs/                                # Data Transfer Objects
│   │   ├── AchievementDtos.cs               # Badge/challenge DTOs
│   │   ├── ActivityDtos.cs                  # Activity DTOs
│   │   ├── UserDtos.cs                      # User/auth DTOs
│   │   └── UserEcoProfileDto.cs             # ML profile DTOs
│   │
│   ├── media/profile_pictures/              # Encrypted profile pictures
│   ├── Program.cs                           # App configuration & DI
│   ├── appsettings.json                     # Production config
│   └── appsettings.Development.json         # Development config
│
├── EcoBackend.Core/                         # Domain Layer
│   └── Entities/                            # Domain models (19 entities)
│       ├── AchievementEntities.cs           # Badge, Challenge, UserBadge, UserChallenge
│       ├── ActivityCategory.cs              # Activity category model
│       ├── ActivityLog.cs                   # Activity log model
│       ├── ActivityType.cs                  # Activity type model
│       ├── DailyLog.cs                      # ML daily log
│       ├── DailyScore.cs                    # Daily eco score
│       ├── DeviceToken.cs                   # FCM tokens
│       ├── EmailVerificationToken.cs        # Email verification
│       ├── LocationPoint.cs                 # GPS coordinates
│       ├── Notification.cs                  # Notification history
│       ├── PasswordResetToken.cs            # Password reset tokens
│       ├── RefreshToken.cs                  # JWT refresh tokens
│       ├── Tip.cs                           # Eco tips
│       ├── TravelSummary.cs                 # Daily travel stats
│       ├── Trip.cs                          # Trip records
│       ├── User.cs                          # User (extends IdentityUser)
│       ├── UserEcoProfile.cs                # ML profile
│       └── UserGoal.cs                      # User goals
│
├── EcoBackend.Infrastructure/               # Data Access Layer
│   ├── Data/
│   │   ├── EcoDbContext.cs                  # DbContext (19 DbSets)
│   │   └── DataSeeder.cs                    # Seed data
│   │
│   └── Migrations/                          # EF Core migrations
│       └── *.cs                             # Migration files
│
└── EcoBackend.Tests/                        # Test Layer
    ├── Integration/                         # Integration tests (133 tests)
    │   ├── AchievementsEndpointTests.cs     # 17 tests
    │   ├── ActivitiesEndpointTests.cs       # 44 tests
    │   ├── AnalyticsEndpointTests.cs        # 6 tests
    │   ├── CustomWebApplicationFactory.cs   # Test setup
    │   ├── PredictionsEndpointTests.cs      # 6 tests
    │   ├── TravelEndpointTests.cs           # 30 tests
    │   └── UsersEndpointTests.cs            # 30 tests
    │
    └── Unit/                                # Unit tests (26 tests)
        ├── ProfilePictureEncryptionServiceTests.cs  # 20 tests
        └── EmailServiceTests.cs             # 6 tests
```

---

## 🏗️ Architecture

### Clean Architecture Principles

The application follows **Clean Architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                      EcoBackend.API                         │
│              (Presentation Layer)                           │
│  Controllers → Services → DTOs                              │
│  ↓ Dependency Injection                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                     EcoBackend.Core                         │
│                  (Domain Layer)                             │
│  Entities (domain models)                                   │
│  No dependencies on other layers                            │
└─────────────────────────────────────────────────────────────┘
                          ↑
┌─────────────────────────────────────────────────────────────┐
│                EcoBackend.Infrastructure                    │
│                (Data Access Layer)                          │
│  EcoDbContext → Entity Framework Core → SQLite              │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Flow
- **API** depends on **Core** and **Infrastructure**
- **Infrastructure** depends on **Core**
- **Core** has no dependencies (pure domain layer)

### Key Patterns

1. **Repository Pattern** - Abstracted data access via EF Core DbContext
2. **Service Pattern** - Business logic separated from controllers
3. **DTO Pattern** - Data transfer objects for API contracts
4. **Dependency Injection** - All services registered in Program.cs
5. **Options Pattern** - Configuration via IOptions<T>

---

## 🔄 Development Workflow

### Daily Development

1. **Pull latest changes**
   ```bash
   git pull origin main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make changes** (follow code standards below)

4. **Run tests**
   ```bash
   dotnet test
   ```

5. **Build and verify**
   ```bash
   dotnet build
   dotnet run --project EcoBackend.API
   ```

6. **Commit and push**
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   git push origin feature/your-feature-name
   ```

7. **Create Pull Request** on GitHub

### Git Commit Convention

Use conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `test:` Test changes
- `refactor:` Code refactoring
- `chore:` Maintenance tasks

**Examples:**
```bash
git commit -m "feat: add carbon forecast prediction endpoint"
git commit -m "fix: resolve token refresh race condition"
git commit -m "docs: update API documentation for analytics"
git commit -m "test: add integration tests for travel endpoints"
```

---

## ➕ Adding New Features

### Adding a New Entity

1. **Create entity in EcoBackend.Core/Entities/**
   ```csharp
   public class EcoChallenge
   {
       public int Id { get; set; }
       public string Name { get; set; } = string.Empty;
       public string Description { get; set; } = string.Empty;
       public DateTime StartDate { get; set; }
       public DateTime EndDate { get; set; }
   }
   ```

2. **Add DbSet in EcoDbContext.cs**
   ```csharp
   public DbSet<EcoChallenge> EcoChallenges { get; set; }
   ```

3. **Configure entity (optional)**
   ```csharp
   protected override void OnModelCreating(ModelBuilder modelBuilder)
   {
       modelBuilder.Entity<EcoChallenge>(entity =>
       {
           entity.HasKey(e => e.Id);
           entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
       });
   }
   ```

4. **Create migration**
   ```bash
   cd EcoBackend.Infrastructure
   dotnet ef migrations add AddEcoChallenge --startup-project ../EcoBackend.API
   ```

5. **Apply migration**
   ```bash
   dotnet ef database update --startup-project ../EcoBackend.API
   ```

---

### Adding a New API Endpoint

**Example: Add endpoint to get challenge participants**

1. **Create DTO (if needed) in DTOs/**
   ```csharp
   public class ChallengeParticipantDto
   {
       public string UserId { get; set; } = string.Empty;
       public string Username { get; set; } = string.Empty;
       public int CurrentProgress { get; set; }
       public DateTime JoinedDate { get; set; }
   }
   ```

2. **Add service method in relevant service**
   ```csharp
   // In AchievementService.cs
   public async Task<List<ChallengeParticipantDto>> GetChallengeParticipantsAsync(
       int challengeId)
   {
       var participants = await _context.UserChallenges
           .Where(uc => uc.ChallengeId == challengeId)
           .Include(uc => uc.User)
           .Select(uc => new ChallengeParticipantDto
           {
               UserId = uc.UserId,
               Username = uc.User.UserName ?? "",
               CurrentProgress = uc.CurrentValue,
               JoinedDate = uc.JoinedDate
           })
           .ToListAsync();
       
       return participants;
   }
   ```

3. **Add controller endpoint**
   ```csharp
   // In AchievementsController.cs
   [HttpGet("challenges/{id}/participants")]
   public async Task<ActionResult<List<ChallengeParticipantDto>>> GetChallengeParticipants(
       int id)
   {
       try
       {
           var participants = await _achievementService
               .GetChallengeParticipantsAsync(id);
           return Ok(participants);
       }
       catch (ArgumentException ex)
       {
           return NotFound(ex.Message);
       }
   }
   ```

4. **Add integration test**
   ```csharp
   // In AchievementsEndpointTests.cs
   [Fact]
   public async Task GetChallengeParticipants_ReturnsParticipants()
   {
       // Arrange
       var token = await AuthHelper.LoginAndGetTokenAsync(_client);
       await SeedHelper.SeedChallengeWithParticipantsAsync(_factory);
       
       // Act
       _client.DefaultRequestHeaders.Authorization = 
           new AuthenticationHeaderValue("Bearer", token);
       var response = await _client.GetAsync("/api/achievements/challenges/1/participants");
       
       // Assert
       response.EnsureSuccessStatusCode();
       var participants = await response.Content
           .ReadFromJsonAsync<List<ChallengeParticipantDto>>();
       Assert.NotNull(participants);
       Assert.NotEmpty(participants);
   }
   ```

5. **Update API documentation**
   - Add endpoint details to `API_DOCUMENTATION.md`

---

### Adding a New Service

1. **Create service class in Services/**
   ```csharp
   public class RewardService
   {
       private readonly EcoDbContext _context;
       private readonly ILogger<RewardService> _logger;
       
       public RewardService(
           EcoDbContext context,
           ILogger<RewardService> logger)
       {
           _context = context;
           _logger = logger;
       }
       
       public async Task<List<Reward>> GetRewardsAsync(string userId)
       {
           return await _context.Rewards
               .Where(r => r.UserId == userId)
               .ToListAsync();
       }
   }
   ```

2. **Register in Program.cs**
   ```csharp
   // Services registration
   builder.Services.AddScoped<RewardService>();
   ```

3. **Inject into controller**
   ```csharp
   public class RewardsController : ControllerBase
   {
       private readonly RewardService _rewardService;
       
       public RewardsController(RewardService rewardService)
       {
           _rewardService = rewardService;
       }
   }
   ```

---

## 🧪 Testing Guidelines

### Testing Strategy

- **Unit Tests**: Test individual services in isolation
- **Integration Tests**: Test full API endpoints with in-memory database
- **Target Coverage**: >70% code coverage

### Running Tests

```bash
# Run all tests
dotnet test

# Run specific test class
dotnet test --filter "FullyQualifiedName~UsersEndpointTests"

# Run with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run with detailed output
dotnet test --verbosity normal
```

### Writing Integration Tests

**Template:**
```csharp
public class NewControllerEndpointTests : IClassFixture<CustomWebApplicationFactory>
{
    private readonly HttpClient _client;
    private readonly CustomWebApplicationFactory _factory;
    
    public NewControllerEndpointTests(CustomWebApplicationFactory factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }
    
    [Fact]
    public async Task GetResource_ReturnsSuccess()
    {
        // Arrange
        var token = await AuthHelper.LoginAndGetTokenAsync(_client);
        _client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);
        
        // Act
        var response = await _client.GetAsync("/api/resource");
        
        // Assert
        response.EnsureSuccessStatusCode();
        var result = await response.Content.ReadFromJsonAsync<ResourceDto>();
        Assert.NotNull(result);
    }
    
    [Theory]
    [InlineData("")]
    [InlineData(null)]
    public async Task CreateResource_InvalidInput_ReturnsBadRequest(string? name)
    {
        // Arrange
        var token = await AuthHelper.LoginAndGetTokenAsync(_client);
        _client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", token);
        var request = new CreateResourceDto { Name = name };
        
        // Act
        var response = await _client.PostAsJsonAsync("/api/resource", request);
        
        // Assert
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }
}
```

### Writing Unit Tests

**Template:**
```csharp
public class ServiceTests
{
    [Fact]
    public void Method_ValidInput_ReturnsExpectedResult()
    {
        // Arrange
        var service = new MyService();
        var input = "test";
        
        // Act
        var result = service.ProcessInput(input);
        
        // Assert
        Assert.Equal("expected", result);
    }
}
```

---

## 📏 Code Standards

### Naming Conventions

- **Classes**: PascalCase (`UserService`, `ActivityDto`)
- **Methods**: PascalCase (`GetUserAsync`, `CreateActivity`)
- **Variables**: camelCase (`userId`, `activityList`)
- **Constants**: PascalCase (`MaxFileSize`, `DefaultPageSize`)
- **Private fields**: `_camelCase` (`_context`, `_logger`)

### Async/Await

- All I/O operations must be async
- Use `Async` suffix for async methods
- Always use `await` (never `.Result` or `.Wait()`)

**Example:**
```csharp
public async Task<User> GetUserAsync(string userId)
{
    return await _context.Users.FindAsync(userId);
}
```

### Error Handling

**Controllers:**
```csharp
[HttpGet("{id}")]
public async Task<ActionResult<ResourceDto>> GetResource(int id)
{
    try
    {
        var resource = await _service.GetResourceAsync(id);
        return Ok(resource);
    }
    catch (ArgumentException ex)
    {
        return NotFound(ex.Message);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error getting resource {Id}", id);
        return StatusCode(500, "An error occurred");
    }
}
```

**Services:**
```csharp
public async Task<Resource> GetResourceAsync(int id)
{
    var resource = await _context.Resources.FindAsync(id);
    if (resource == null)
    {
        throw new ArgumentException($"Resource {id} not found");
    }
    return resource;
}
```

### Logging

Use structured logging:
```csharp
_logger.LogInformation("User {UserId} created activity {ActivityId}", 
    userId, activity.Id);
_logger.LogWarning("Failed login attempt for {Username}", username);
_logger.LogError(ex, "Error processing payment for {UserId}", userId);
```

### DTOs vs Entities

- **Never** return entities directly from controllers
- Always map to DTOs
- DTOs should be in `DTOs/` folder

```csharp
// ✅ Good
public async Task<ActionResult<UserDto>> GetProfile()
{
    var user = await _userService.GetProfileAsync(userId);
    return Ok(user); // user is UserDto
}

// ❌ Bad
public async Task<ActionResult<User>> GetProfile()
{
    var user = await _context.Users.FindAsync(userId);
    return Ok(user); // user is entity - DON'T DO THIS
}
```

---

## 🗄️ Database Management

### Migrations

**Create new migration:**
```bash
cd EcoBackend.Infrastructure
dotnet ef migrations add MigrationName --startup-project ../EcoBackend.API
```

**Apply migrations:**
```bash
dotnet ef database update --startup-project ../EcoBackend.API
```

**Remove last migration (if not applied):**
```bash
dotnet ef migrations remove --startup-project ../EcoBackend.API
```

**Generate SQL script:**
```bash
dotnet ef migrations script --startup-project ../EcoBackend.API -o migration.sql
```

### Seeding Data

Data seeder runs automatically on startup (development only).

Location: `EcoBackend.Infrastructure/Data/DataSeeder.cs`

**Add new seed data:**
```csharp
public static async Task SeedAsync(EcoDbContext context)
{
    if (!context.YourEntity.Any())
    {
        context.YourEntity.AddRange(
            new YourEntity { ... },
            new YourEntity { ... }
        );
        await context.SaveChangesAsync();
    }
}
```

### Database Inspection

**SQLite Browser:**
```bash
# Install SQLite browser (Windows)
winget install DB.Browser.SQLiteBrowser

# Open database
# File > Open Database > eco.db
```

**Command Line:**
```bash
# Open database
sqlite3 eco.db

# List tables
.tables

# View schema
.schema Users

# Query data
SELECT * FROM Users;

# Exit
.quit
```

---

## 🐛 Debugging

### Visual Studio

1. Set `EcoBackend.API` as startup project
2. Press F5 or click "Start Debugging"
3. Set breakpoints in code
4. Use Immediate Window, Watch, and Locals

### VS Code

1. **Install extensions:**
   - C# Dev Kit
   - .NET Extension Pack

2. **Launch configuration (.vscode/launch.json):**
   ```json
   {
     "version": "0.2.0",
     "configurations": [
       {
         "name": ".NET Core Launch (web)",
         "type": "coreclr",
         "request": "launch",
         "preLaunchTask": "build",
         "program": "${workspaceFolder}/EcoBackend.API/bin/Debug/net8.0/EcoBackend.API.dll",
         "args": [],
         "cwd": "${workspaceFolder}/EcoBackend.API",
         "stopAtEntry": false,
         "serverReadyAction": {
           "action": "openExternally",
           "pattern": "\\bNow listening on:\\s+(https?://\\S+)"
         },
         "env": {
           "ASPNETCORE_ENVIRONMENT": "Development"
         }
       }
     ]
   }
   ```

3. Press F5 to start debugging

### Logging

Check console output for logs:
```
info: EcoBackend.API.Services.UserService[0]
      User admin logged in successfully
warn: EcoBackend.API.Controllers.UsersController[0]
      Invalid login attempt for username: unknown_user
```

---

## 📋 Common Tasks

### Reset Database

```bash
# Delete database file
rm eco.db

# Reapply migrations
cd EcoBackend.Infrastructure
dotnet ef database update --startup-project ../EcoBackend.API

# Restart application (will reseed data)
cd ../EcoBackend.API
dotnet run
```

### Update NuGet Packages

```bash
# List outdated packages
dotnet list package --outdated

# Update specific package
dotnet add package Microsoft.EntityFrameworkCore --version 8.0.2

# Update all packages (use with caution)
dotnet restore --force
```

### Clean and Rebuild

```bash
# Clean build artifacts
dotnet clean

# Rebuild solution
dotnet build

# Restore + rebuild
dotnet restore
dotnet build
```

### View All Routes

Run application and check Swagger UI:
```
https://localhost:7162/swagger
```

Or use Swagger JSON:
```
https://localhost:7162/swagger/v1/swagger.json
```

### Generate Test Users

Test users are seeded automatically:
- Username: `admin`, Password: `admin123`
- Username: `admin2`, Password: `admin123`

**Add custom test users:**
```csharp
// In DataSeeder.cs
var user = new User
{
    UserName = "testuser",
    Email = "test@example.com",
    EmailConfirmed = true
};
await userManager.CreateAsync(user, "Test123!");
```

---

## 🔧 Configuration

### Environment Variables

Override `appsettings.json` with environment variables:

**Windows (PowerShell):**
```powershell
$env:JWT__Secret = "new-secret-key"
$env:ConnectionStrings__DefaultConnection = "Data Source=custom.db"
dotnet run
```

**Linux/Mac:**
```bash
export JWT__Secret="new-secret-key"
export ConnectionStrings__DefaultConnection="Data Source=custom.db"
dotnet run
```

### User Secrets (Development)

Store sensitive data securely:

```bash
# Initialize secrets
cd EcoBackend.API
dotnet user-secrets init

# Set secret
dotnet user-secrets set "JWT:Secret" "your-secret-key"
dotnet user-secrets set "EmailSettings:Password" "your-password"

# List secrets
dotnet user-secrets list

# Remove secret
dotnet user-secrets remove "JWT:Secret"
```

---

## 🎯 Performance Tips

1. **Use AsNoTracking for read-only queries:**
   ```csharp
   var users = await _context.Users.AsNoTracking().ToListAsync();
   ```

2. **Select only needed columns:**
   ```csharp
   var users = await _context.Users
       .Select(u => new UserDto { Id = u.Id, Username = u.UserName })
       .ToListAsync();
   ```

3. **Use Include for eager loading:**
   ```csharp
   var trips = await _context.Trips
       .Include(t => t.LocationPoints)
       .ToListAsync();
   ```

4. **Avoid N+1 queries:**
   ```csharp
   // ❌ Bad (N+1)
   foreach (var user in users)
   {
       var badges = await _context.UserBadges
           .Where(ub => ub.UserId == user.Id)
           .ToListAsync();
   }
   
   // ✅ Good
   var userIds = users.Select(u => u.Id).ToList();
   var badges = await _context.UserBadges
       .Where(ub => userIds.Contains(ub.UserId))
       .ToListAsync();
   ```

---

## 📚 Additional Resources

- [ASP.NET Core Docs](https://docs.microsoft.com/en-us/aspnet/core/)
- [Entity Framework Core Docs](https://docs.microsoft.com/en-us/ef/core/)
- [xUnit Docs](https://xunit.net/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## 🆘 Troubleshooting

### Port Already in Use

```bash
# Find process using port 5145
netstat -ano | findstr :5145

# Kill process (Windows)
taskkill /PID <process-id> /F

# Kill process (Linux/Mac)
kill -9 <process-id>
```

### Migration Issues

```bash
# Check migration status
dotnet ef migrations list --startup-project ../EcoBackend.API

# Remove all migrations and start fresh
# 1. Delete Migrations folder
# 2. Delete database file
# 3. Create initial migration
dotnet ef migrations add Initial --startup-project ../EcoBackend.API
```

### JWT Token Issues

- Ensure `JWT:Secret` is at least 32 characters
- Check token expiry settings
- Verify token is sent in `Authorization: Bearer <token>` header

---

## 📞 Support

For development questions:
- Check this guide
- Review existing code and tests
- Check GitHub issues
- Contact: dev@ecodailyscore.com

---

**Happy Coding! 🌱**

Last Updated: February 16, 2026
