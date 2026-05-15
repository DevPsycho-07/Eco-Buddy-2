# 🌱 Eco Daily Score

A full-stack sustainability app that helps users track their carbon footprint, log eco-friendly activities, earn achievements, and get AI-powered guidance toward greener habits.

## 🎯 Project Status

**Backend** — Production Ready
- ✅ 129 API endpoints across 7 controllers
- ✅ 15 services (Clean Architecture)
- ✅ AI chatbot (local LLaMA inference)
- ✅ ML eco-score predictions (ONNX Runtime)
- ✅ Email & push notifications
- ✅ Background jobs (Hangfire)
- ✅ 159 tests (145 passing, 14 skipped)

**Frontend** — Flutter mobile app with Riverpod state management

**Last Updated**: May 15, 2026

---

## 📋 Project Structure

```
.
├── Backend/                         # ASP.NET Core (.NET 10) Web API
│   ├── EcoBackend.API/             # Controllers, services, DTOs
│   ├── EcoBackend.Core/            # Domain entities & interfaces
│   ├── EcoBackend.Infrastructure/  # EF Core DbContext & migrations
│   └── EcoBackend.Tests/           # Integration & service tests
│
└── Frontend/                        # Flutter mobile application
    └── lib/
        ├── pages/                  # UI screens
        ├── services/               # API & business logic
        └── core/                   # Configuration & constants
```

## 🚀 Features

### User Management ✅
- Registration and authentication with JWT tokens
- Refresh token rotation for enhanced security
- Google Sign-In support
- Profile management with encrypted profile pictures (AES-256-CBC)
- Email verification and password reset via email
- Privacy settings and notification preferences
- Data export (GDPR compliance)
- Real-time username availability checking

### Activity Tracking ✅
- Log eco-friendly activities (13 categories, 50+ activity types)
- Track carbon footprint (CO2 saved/emitted)
- Daily activity summaries and statistics
- Activity categorization and points system
- Daily eco tips and recommendations

### Achievements System ✅
- Unlock badges based on activities
- Challenge system with progress tracking
- Individual and multiplayer challenges
- Streak tracking
- Points and experience system
- Leaderboards and rankings

### Analytics & Insights ✅
- Weekly/monthly reports
- CO2 savings comparison
- Activity trends and patterns
- User ranking and leaderboards
- Dashboard with key metrics
- CSV data export

### Travel Tracking ✅
- Multi-modal transport tracking
- GPS location point tracking with batch uploads
- Carbon footprint calculation per trip
- Travel history and statistics
- Daily and weekly travel summaries
- Steps tracking integration

### AI Chatbot ✅
- Conversational eco-assistant powered by a local LLaMA model (LLamaSharp)
- Persistent chat sessions and history
- Runs fully offline — no external API calls

### ML Predictions ✅
- Eco-score prediction via an ONNX model (`eco_score_model.onnx`)
- User eco-profile and daily-log feature engineering
- Carbon footprint forecasting

### Notifications ✅
- Push notifications via Firebase FCM
- Email notifications (MailKit/SMTP)
- Event-driven notifications (badges, challenges, streaks)
- Device token management
- Notification history and preferences

### Background Jobs ✅
- Daily streak calculation (midnight UTC)
- Weekly reports (Monday 1 AM UTC)
- Monthly reports (1st of month 2 AM UTC)
- Badge requirement checks (every 6 hours)
- Token cleanup (daily 3 AM UTC)
- Hangfire dashboard for monitoring

## 🛠️ Technologies

### Backend
- **Framework**: ASP.NET Core (.NET 10)
- **Database**: PostgreSQL with Entity Framework Core 9
- **Authentication**: JWT Bearer tokens + refresh tokens, ASP.NET Core Identity, Google Sign-In
- **Background Jobs**: Hangfire
- **Email**: MailKit
- **Push Notifications**: Firebase Admin SDK
- **AI Chatbot**: LLamaSharp (local GGUF model inference)
- **ML**: Microsoft.ML.OnnxRuntime
- **Testing**: xUnit
- **API Documentation**: Swagger/OpenAPI

### Frontend (Flutter)
- **Framework**: Flutter (Dart SDK ^3.8.1)
- **State Management**: Riverpod
- **Dependency Injection**: GetIt
- **HTTP Client**: Dio
- **Local Storage**: Hive, flutter_secure_storage, shared_preferences
- **Navigation**: go_router
- **Push Notifications**: Firebase Messaging
- **Auth**: Google Sign-In
- **UI**: Lottie, shimmer, flutter_animate

---

## 📚 Documentation

- **[API Documentation](Backend/API_DOCUMENTATION.md)** — Complete API reference
- **[Developer Guide](Backend/DEVELOPER_GUIDE.md)** — Setup, architecture, contribution guidelines
- **[Deployment Guide](Backend/DEPLOYMENT_GUIDE.md)** — Production deployment instructions

---

## 📦 Setup Instructions

### Backend Setup

#### Prerequisites
- .NET 10 SDK
- PostgreSQL 14+ (running locally or remotely)
- Visual Studio 2022 or VS Code
- (Optional) Firebase credentials for push notifications, SMTP credentials for email
- (Optional) GGUF model file at `EcoBackend.API/models/` for the AI chatbot

#### Steps

1. **Navigate to the API project**
   ```bash
   cd "Backend/EcoBackend.API"
   ```

2. **Restore dependencies**
   ```bash
   dotnet restore
   ```

3. **Apply database migrations**
   ```bash
   dotnet ef database update --project ../EcoBackend.Infrastructure --startup-project .
   ```

4. **Run the application**
   ```bash
   dotnet run
   ```

#### Configuration

Update `appsettings.json` in `EcoBackend.API`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=eco_db;Username=postgres;Password=your-password"
  },
  "JWT": {
    "Secret": "your-secret-key-here-min-32-chars-long!",
    "ValidIssuer": "EcoBackend",
    "ValidAudience": "EcoBackendClient"
  }
}
```

### Frontend Setup

#### Prerequisites
- Flutter SDK (Dart ^3.8.1)
- Android Studio or Xcode
- VS Code with the Flutter extension

#### Steps

1. **Navigate to the Frontend directory**
   ```bash
   cd Frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure the API endpoint** in the app config / `.env`, then run:
   ```bash
   flutter run
   ```

## 🔑 API Endpoints

**Total**: 129 endpoints across 7 controllers

| Module | Endpoints | Description |
|--------|-----------|-------------|
| Users | 49 | Auth, profile, settings, goals, daily scores, notifications, leaderboard |
| Travel | 19 | Trips, location points, summaries |
| Achievements | 18 | Badges, challenges, user progress |
| Predictions | 17 | Eco profile, daily logs, ML predictions |
| Activities | 14 | Categories, types, CRUD, tips, history |
| Analytics | 6 | Reports, dashboard, stats, CSV export |
| Chatbot | 6 | Chat, sessions, model status |

For complete documentation with request/response examples, see **[API_DOCUMENTATION.md](Backend/API_DOCUMENTATION.md)**.

---

## 🧪 Testing

```bash
cd Backend
dotnet test
```

**Results**: 159 tests — 145 passing, 14 skipped. The skipped tests cover notification flows that require live Firebase/SMTP credentials.

**Test suites:**
- Integration: Users, Activities, Achievements, Analytics, Travel, Predictions, Notifications
- Services: EmailService, NotificationService

---

## 🔒 Security Features

- **JWT Authentication** — token-based auth with refresh token rotation
- **Google Sign-In** — OAuth-based authentication
- **Password Hashing** — ASP.NET Identity (PBKDF2)
- **Profile Picture Encryption** — AES-256-CBC for stored images
- **Token Revocation** — secure logout with token cleanup
- **Email Verification & Password Reset** — secure email-token flows
- **File Upload Validation** — type/size validation, hashed filenames
- **CORS Configuration** — configurable cross-origin policies

## 📊 Database Schema

The backend uses **PostgreSQL** with EF Core migrations. Domain entities are organized by area:

**User Management** — User (extends IdentityUser), RefreshToken, PasswordResetToken, EmailVerificationToken
**Activities** — ActivityCategory, ActivityType, ActivityLog, Tip
**Achievements** — Badge, UserBadge, Challenge, UserChallenge
**Travel** — Trip, LocationPoint, TravelSummary
**Notifications** — Notification, DeviceToken
**User Features** — UserGoal, DailyScore
**ML & Chat** — UserEcoProfile, DailyLog, ChatSession

## 🐛 Troubleshooting

### Backend won't start
- Ensure the .NET 10 SDK is installed
- Verify PostgreSQL is running and the connection string is correct
- Confirm database migrations are applied

### Frontend can't connect to API
- Check the API URL in the app configuration
- Ensure the backend is running and CORS is configured

### Database errors
- Verify the PostgreSQL `eco_db` database exists
- Re-run `dotnet ef database update`

## 📄 License

This project is developed for educational purposes.
