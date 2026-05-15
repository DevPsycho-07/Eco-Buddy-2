# 🌱 Eco Daily Score — Backend API

A .NET 10 backend API for tracking daily eco-friendly activities, calculating carbon footprints, and gamifying sustainable living through achievements, challenges, leaderboards, an AI chatbot, and ML-based eco-score predictions.

## 📊 Project Status

**Version:** 1.0.0
**Status:** Production Ready
**Last Updated:** May 15, 2026

- ✅ 129 API endpoints across 7 controllers
- ✅ 15 services (Clean Architecture)
- ✅ AI chatbot (local LLaMA inference via LLamaSharp)
- ✅ ML eco-score predictions (ONNX Runtime)
- ✅ Email system (password reset, verification)
- ✅ Push notifications (Firebase FCM)
- ✅ Background jobs (Hangfire)
- ✅ 159 tests (145 passing, 14 skipped)

---

## 🚀 Quick Start

### Prerequisites

- .NET 10 SDK
- PostgreSQL 14+ (running locally or remotely)
- (Optional) Firebase credentials for push notifications
- (Optional) SMTP server credentials for email
- (Optional) GGUF model file in `EcoBackend.API/models/` for the AI chatbot
- (Optional) `eco_score_model.onnx` in `EcoBackend.API/models/` for ML predictions

### Installation

```bash
# From the Backend directory

# Restore dependencies
dotnet restore

# Apply database migrations
dotnet ef database update --project EcoBackend.Infrastructure --startup-project EcoBackend.API

# Run the application
cd EcoBackend.API
dotnet run
```

The API serves Swagger UI at `/swagger` in development.

### Configuration

Update `EcoBackend.API/appsettings.json` with your credentials:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=eco_db;Username=postgres;Password=your-password"
  },
  "JWT": {
    "Secret": "your-secret-key-min-32-chars",
    "ValidIssuer": "EcoBackend",
    "ValidAudience": "EcoBackendClient"
  },
  "Email": {
    "SmtpHost": "smtp.gmail.com",
    "SmtpPort": 587,
    "SmtpUser": "your-email@gmail.com",
    "SmtpPassword": "your-app-password",
    "FromEmail": "your-email@gmail.com",
    "FromName": "Eco Daily Score"
  },
  "Firebase": {
    "CredentialPath": "firebase-credentials.json"
  },
  "Authentication": {
    "Google": {
      "ClientId": "your-google-oauth-client-id"
    }
  },
  "Chatbot": {
    "ModelPath": "models/ecobot-3b-q5_k_m.gguf"
  }
}
```

---

## 📚 Documentation

- **[API Documentation](API_DOCUMENTATION.md)** — Complete API reference with examples
- **[Developer Guide](DEVELOPER_GUIDE.md)** — Setup, architecture, and contribution guidelines
- **[Deployment Guide](DEPLOYMENT_GUIDE.md)** — Production deployment instructions

---

## 🏗️ Architecture

### Clean Architecture Layers

```
EcoBackend.API/              # Presentation Layer
├── Controllers/             # API endpoints (7 controllers)
├── Services/                # Business logic (15 services)
├── DTOs/                    # Data transfer objects
└── Program.cs               # Application configuration

EcoBackend.Core/             # Domain Layer
├── Entities/                # Domain models
└── Interfaces/              # Abstractions

EcoBackend.Infrastructure/   # Data Access Layer
├── Data/                    # DbContext
└── Migrations/              # EF Core migrations

EcoBackend.Tests/            # Test Layer
├── Integration/             # Integration tests
├── Services/                # Service tests
└── Fixtures/                # Test fixtures & data factories
```

### Key Technologies

- **Framework:** ASP.NET Core (.NET 10)
- **ORM:** Entity Framework Core 9
- **Database:** PostgreSQL (Npgsql provider)
- **Authentication:** ASP.NET Identity + JWT Bearer, Google Sign-In
- **Background Jobs:** Hangfire
- **Email:** MailKit
- **Push Notifications:** Firebase Admin SDK
- **AI Chatbot:** LLamaSharp (local GGUF model inference)
- **ML:** Microsoft.ML.OnnxRuntime
- **Testing:** xUnit, Moq
- **Documentation:** Swagger/OpenAPI

---

## 🔑 Core Features

### Authentication & Authorization
- JWT tokens with refresh token rotation
- Google Sign-In
- Password reset and email verification via email
- Secure token revocation

### User Management
- Profile management with encrypted profile pictures (AES-256-CBC)
- Privacy settings (location, activity, health data, calendar)
- Notification preferences
- Data export (GDPR compliance)
- Leaderboard & rankings

### Activity Tracking
- 13 activity categories with multiple types each
- CO2 impact calculations
- Points & experience system
- Daily activity summaries

### Travel Tracking
- Trips with multiple transport modes
- Location point tracking with batch uploads
- Travel summaries (daily, weekly)
- Steps tracking integration

### Gamification
- Badges (streak, CO2 saved, activities)
- Challenges (individual & multiplayer)
- Streak tracking
- Experience points & leveling

### Analytics
- Weekly/monthly reports
- Dashboard metrics
- Comparison analysis (week vs week)
- CSV export

### AI Chatbot
- Conversational eco-assistant running a local LLaMA model (LLamaSharp)
- Persistent chat sessions and history
- Fully offline — no external API dependency

### ML Predictions
- Eco-score prediction via an ONNX model
- User eco-profile and daily-log feature engineering
- Carbon footprint forecasting

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
- Token cleanup (3 AM UTC)

---

## 📡 API Endpoints Overview

| Module | Endpoints | Description |
|--------|-----------|-------------|
| **Users** | 49 | Auth, profile, settings, goals, daily scores, notifications, leaderboard |
| **Travel** | 19 | Trips, location points, summaries |
| **Achievements** | 18 | Badges, challenges, user progress |
| **Predictions** | 17 | Eco profile, daily logs, ML predictions |
| **Activities** | 14 | Categories, types, activities CRUD, tips, history |
| **Analytics** | 6 | Reports, dashboard, stats, CSV export |
| **Chatbot** | 6 | Chat, sessions, model status |

**Total:** 129 endpoints

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for detailed endpoint documentation.

---

## 🧪 Testing

```bash
# Run all tests
dotnet test

# Run with coverage
dotnet test --collect:"XPlat Code Coverage"

# Run a specific test suite
dotnet test --filter "FullyQualifiedName~UsersEndpointTests"
```

**Test Results:**
- 159 tests — 145 passing, 14 skipped
- Skipped tests cover notification flows that require live Firebase/SMTP credentials
- 7 integration test suites + 2 service test suites
- Shared fixtures: `CustomWebApplicationFactory`, `IntegrationTestFixture`, `TestDataFactory`

---

## 🔐 Security Features

- **Encryption:** AES-256-CBC for profile pictures
- **Password Hashing:** ASP.NET Identity (PBKDF2)
- **Token Security:** cryptographic random generation, secure rotation
- **File Validation:** type & size validation, hashed filenames
- **CORS:** configurable cross-origin policies

---

## 🗄️ Database

The backend uses **PostgreSQL** with EF Core migrations. Domain entities are organized by area:

- **User Management:** User (ASP.NET Identity), RefreshToken, PasswordResetToken, EmailVerificationToken
- **Activities:** ActivityCategory, ActivityType, ActivityLog, Tip
- **Achievements:** Badge, UserBadge, Challenge, UserChallenge
- **Travel:** Trip, LocationPoint, TravelSummary
- **Notifications:** Notification, DeviceToken
- **User Features:** UserGoal, DailyScore
- **ML & Chat:** UserEcoProfile, DailyLog, ChatSession

---

## 🔄 Background Jobs (Hangfire)

Access the Hangfire dashboard at `/hangfire` (development only).

| Job | Schedule |
|-----|----------|
| Daily streak calculation | 00:00 UTC |
| Weekly reports | Monday 01:00 UTC |
| Monthly reports | 1st of month 02:00 UTC |
| Badge requirement checks | Every 6 hours |
| Token cleanup | 03:00 UTC |

---

## 📦 Key NuGet Packages

**Core & Database**
- Microsoft.EntityFrameworkCore 9.0.3
- Npgsql.EntityFrameworkCore.PostgreSQL 9.0.3
- Microsoft.AspNetCore.Identity.EntityFrameworkCore 9.0.3
- Swashbuckle.AspNetCore 6.5.0

**Authentication**
- Microsoft.AspNetCore.Authentication.JwtBearer 9.0.3
- System.IdentityModel.Tokens.Jwt 8.0.2
- Google.Apis.Auth 1.73.0

**Email & Notifications**
- MailKit 4.16.0
- FirebaseAdmin 3.0.1

**Background Jobs**
- Hangfire.AspNetCore 1.8.14
- Hangfire.MemoryStorage 1.8.1

**AI & ML**
- LLamaSharp + LLamaSharp.Backend.Cpu
- Microsoft.ML.OnnxRuntime 1.20.1

**Testing**
- xunit 2.9.2
- Moq 4.20.70
- Microsoft.AspNetCore.Mvc.Testing 9.0.3
- Microsoft.EntityFrameworkCore.InMemory 9.0.3

---

## 🤝 Contributing

See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) for development setup and contribution guidelines.

---

## 📝 License

Developed for educational purposes.

---

**Built with ❤️ for a sustainable future 🌍**
