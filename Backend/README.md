# 🌱 Eco Daily Score - Backend API

A comprehensive .NET 8 backend API for tracking daily eco-friendly activities, calculating carbon footprints, and gamifying sustainable living through achievements, challenges, and leaderboards.

## 📊 Project Status

**Version:** 1.0.0  
**Status:** Production Ready (99% Complete)  
**Last Updated:** February 16, 2026

- ✅ 126 API Endpoints Implemented
- ✅ 12 Services (Clean Architecture)
- ✅ Email System (Password Reset, Verification)
- ✅ Push Notifications (Firebase FCM)
- ✅ Background Jobs (Hangfire)
- ✅ 159/159 Tests Passing (>70% Coverage)
- ⏳ ML Integration (13 stub endpoints ready)

---

## 🚀 Quick Start

### Prerequisites

- .NET 8 SDK
- SQLite (embedded)
- Firebase credentials (for push notifications)
- SMTP server credentials (for email)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd Backend

# Restore dependencies
dotnet restore

# Update database
dotnet ef database update --project EcoBackend.Infrastructure --startup-project EcoBackend.API

# Run the application
cd EcoBackend.API
dotnet run
```

The API will be available at `https://localhost:7162` (HTTPS) or `http://localhost:5145` (HTTP).

### Configuration

Update `appsettings.json` with your credentials:

```json
{
  "JWT": {
    "Secret": "your-secret-key-min-32-chars",
    "ValidIssuer": "EcoBackendAPI",
    "ValidAudience": "EcoBackendClient"
  },
  "EmailSettings": {
    "SmtpServer": "smtp.gmail.com",
    "SmtpPort": 587,
    "SenderEmail": "your-email@gmail.com",
    "SenderName": "Eco Daily Score",
    "Username": "your-email@gmail.com",
    "Password": "your-app-password"
  },
  "Firebase": {
    "CredentialsPath": "path/to/firebase-credentials.json"
  }
}
```

---

## 📚 Documentation

- **[API Documentation](API_DOCUMENTATION.md)** - Complete API reference with examples
- **[Developer Guide](DEVELOPER_GUIDE.md)** - Setup, architecture, and contribution guidelines
- **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Production deployment instructions

---

## 🏗️ Architecture

### Clean Architecture Layers

```
EcoBackend.API/              # Presentation Layer
├── Controllers/             # API endpoints
├── Services/               # Business logic (12 services)
├── DTOs/                   # Data transfer objects
└── Program.cs              # Application configuration

EcoBackend.Core/            # Domain Layer
├── Entities/               # Domain models (19 entities)
└── Interfaces/             # Abstractions

EcoBackend.Infrastructure/  # Data Access Layer
├── Data/                   # DbContext
└── Migrations/             # EF Core migrations

EcoBackend.Tests/           # Test Layer
├── Integration/            # Integration tests (133 tests)
└── Unit/                   # Unit tests (25 tests)
```

### Key Technologies

- **Framework:** ASP.NET Core 8.0
- **ORM:** Entity Framework Core 8.0
- **Database:** SQLite (portable, file-based)
- **Authentication:** ASP.NET Identity + JWT Bearer
- **Background Jobs:** Hangfire
- **Email:** MailKit 4.3.0
- **Push Notifications:** FirebaseAdmin SDK
- **Testing:** xUnit 2.6.3
- **Documentation:** Swagger/OpenAPI

---

## 🔑 Core Features

### Authentication & Authorization
- JWT tokens (24-hour validity)
- Refresh tokens (7-day validity) with rotation
- Password reset via email
- Email verification
- Secure token revocation

### User Management
- Profile management with encrypted profile pictures (AES-256-CBC)
- Privacy settings (location, activity, health data, calendar)
- Notification preferences
- Data export (GDPR compliance)
- Leaderboard & rankings

### Activity Tracking
- 13 activity categories (Transportation, Energy, Food, etc.)
- Multiple activity types per category
- CO2 impact calculations
- Points & experience system
- Daily activity summaries

### Travel Tracking
- Trips with multiple transport modes
- Location point tracking
- Batch location uploads
- Travel summaries (daily, weekly)
- Steps tracking integration

### Gamification
- Badges (streak, CO2 saved, activities)
- Challenges (individual & multiplayer)
- User challenges with progress tracking
- Experience points & leveling system

### Analytics
- Weekly/monthly reports
- Dashboard metrics
- Comparison analysis (week vs week)
- CSV export for data analysis

### Notifications
- Push notifications via Firebase FCM
- Event-driven notifications (achievements, badges, challenges, streaks)
- Device token management
- Notification history & preferences

### Background Jobs
- Daily streak calculation (midnight UTC)
- Weekly reports (Monday 1 AM UTC)
- Monthly reports (1st of month 2 AM UTC)
- Badge requirement checks (every 6 hours)
- Token cleanup (daily 3 AM UTC)

---

## 📡 API Endpoints Overview

| Module | Endpoints | Description |
|--------|-----------|-------------|
| **Users** | 37 | Auth, profile, settings, leaderboard, goals, daily scores |
| **Activities** | 13 | Categories, types, activities CRUD, tips, history |
| **Achievements** | 17 | Badges, challenges, user progress |
| **Analytics** | 6 | Reports, dashboard, stats, CSV export |
| **Travel** | 19 | Trips, location points, summaries |
| **Predictions** | 16 | Eco profile, daily logs, ML stubs |
| **Notifications** | 7 | Push notifications, device tokens |
| **Other** | 14 | Health checks, background jobs dashboard |

**Total:** 126 endpoints

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for detailed endpoint documentation.

---

## 🧪 Testing

```bash
# Run all tests
dotnet test

# Run with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run specific test suite
dotnet test --filter "FullyQualifiedName~UsersEndpointTests"
```

**Test Results:**
- ✅ 159/159 tests passing
- ✅ >70% code coverage
- ✅ 7 integration test suites
- ✅ 2 unit test suites

---

## 🔐 Security Features

- **Encryption:** AES-256-CBC for profile pictures
- **Password Hashing:** ASP.NET Identity (PBKDF2)
- **Token Security:** Cryptographic random generation, secure rotation
- **File Validation:** Type & size validation, SHA256 filenames
- **CORS:** Configurable cross-origin policies
- **Rate Limiting:** Ready for AspNetCoreRateLimit integration

---

## 📊 Database Schema

19 database entities:
- User (ASP.NET Identity)
- Activity, ActivityType, ActivityCategory
- Trip, LocationPoint, TravelSummary
- Badge, UserBadge, Challenge, UserChallenge
- DailyScore, UserGoal
- Notification, DeviceToken
- RefreshToken, PasswordResetToken, EmailVerificationToken
- UserEcoProfile, DailyLog (ML predictions)

---

## 🔄 Background Jobs (Hangfire)

Access the Hangfire Dashboard at `/hangfire` (development only).

**Scheduled Jobs:**
1. **Daily Streak Calculation** - 00:00 UTC
2. **Weekly Reports** - Monday 01:00 UTC
3. **Monthly Reports** - 1st of month 02:00 UTC
4. **Badge Requirements** - Every 6 hours
5. **Token Cleanup** - 03:00 UTC

---

## 🌐 API Versioning & Documentation

- **Swagger UI:** Available at `/swagger` (development)
- **OpenAPI Spec:** Available at `/swagger/v1/swagger.json`
- **API Version:** v1 (current)

---

## 📦 NuGet Packages

**Core:**
- Microsoft.AspNetCore.OpenApi 8.0.0
- Microsoft.EntityFrameworkCore 8.0.0
- Microsoft.AspNetCore.Identity.EntityFrameworkCore 8.0.0
- Swashbuckle.AspNetCore 6.5.0

**Database:**
- Microsoft.EntityFrameworkCore.Sqlite 8.0.0
- Microsoft.EntityFrameworkCore.Tools 8.0.0

**Authentication:**
- Microsoft.AspNetCore.Authentication.JwtBearer 8.0.0
- System.IdentityModel.Tokens.Jwt 7.3.1

**Email & Notifications:**
- MailKit 4.3.0
- FirebaseAdmin 3.0.0

**Background Jobs:**
- Hangfire 1.8.9
- Hangfire.MemoryStorage 1.8.0

**Testing:**
- xunit 2.6.3
- Microsoft.AspNetCore.Mvc.Testing 8.0.0
- Microsoft.EntityFrameworkCore.InMemory 8.0.0

---

## 🤝 Contributing

See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for development setup and contribution guidelines.

---

## 📝 License

Copyright © 2026 Eco Daily Score. All rights reserved.

---

## 🆘 Support

For issues, questions, or contributions:
- Create an issue on GitHub
- Check existing documentation
- Review test files for usage examples

---

## 🎯 Roadmap

### Current (Week 1) - ✅ Complete
- All 126 endpoints implemented
- All 12 services with clean architecture
- Email & push notifications
- Background jobs
- Testing (159/159 passing)

### Next (Week 2)
- ML predictions via ONNX
- Feature engineering (82 features)
- Replace 13 stub endpoints

### Future (Week 3-6)
- Docker containerization
- CI/CD pipeline
- Monitoring & logging
- Performance optimization
- Production deployment

---

**Built with ❤️ for a sustainable future 🌍**
