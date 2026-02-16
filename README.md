# Eco Daily Score

A comprehensive eco-friendly activity tracking application that helps users monitor their carbon footprint, earn achievements, and compete on leaderboards.

## 🎯 Project Status

**Backend**: 99% Complete (Production Ready)
- ✅ 126 API endpoints implemented
- ✅ 12 services with clean architecture
- ✅ 159/159 tests passing (>70% coverage)
- ✅ Email & push notifications
- ✅ Background jobs (Hangfire)
- ✅ Comprehensive documentation
- ⏳ ML integration (13 stub endpoints)

**Last Updated**: February 16, 2026

---

## 📋 Project Structure

```
.
├── Backend/                    # ASP.NET Core 8.0 Web API
│   ├── EcoBackend.API/        # API Controllers & Endpoints
│   ├── EcoBackend.Core/       # Domain Entities & Interfaces
│   └── EcoBackend.Infrastructure/  # Data Access & Migrations
│
└── Frontend/                  # Flutter Mobile Application
    └── lib/
        ├── pages/            # UI Screens
        ├── services/         # API & Business Logic
        └── core/             # Configuration & Constants
```

## 🚀 Features

### User Management ✅
- User registration and authentication with JWT tokens
- Refresh token rotation for enhanced security
- Profile management with encrypted profile pictures (AES-256)
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
- Achievement summaries and statistics
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
- GPS location point tracking
- Batch location uploads
- Carbon footprint calculation per trip
- Travel history and statistics
- Daily and weekly travel summaries
- Steps tracking integration

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

### ML Predictions ⏳
- Carbon footprint predictions (stub)
- Eco-score forecasting (stub)
- Personalized recommendations (stub)
- 13 ML endpoints ready for implementation

## 🛠️ Technologies

### Backend (ASP.NET Core)
- **Framework**: ASP.NET Core 8.0
- **Database**: SQLite with Entity Framework Core
- **ORM**: Entity Framework Core 8.0
- **Authentication**: JWT Bearer Tokens + Refresh Tokens
- **Identity**: ASP.NET Core Identity
- **Background Jobs**: Hangfire
- **Email**: MailKit 4.3.0
- **Push Notifications**: Firebase Admin SDK
- **Testing**: xUnit 2.6.3 (159/159 tests passing)
- **API Documentation**: Swagger/OpenAPI
- **Status**: 99% Complete - Production Ready

### Frontend (Flutter)
- **Framework**: Flutter
- **State Management**: StatefulWidget
- **HTTP Client**: http package
- **Storage**: flutter_secure_storage
- **Image Handling**: image_picker

---

## 📚 Documentation

### Backend Documentation
- **[API Documentation](Backend/API_DOCUMENTATION.md)** - Complete API reference with all 126 endpoints
- **[Developer Guide](Backend/DEVELOPER_GUIDE.md)** - Setup, architecture, and contribution guidelines
- **[Deployment Guide](Backend/DEPLOYMENT_GUIDE.md)** - Production deployment instructions

### Quick Links
- **Backend Status**: 99% Complete (159/159 tests passing)
- **API Version**: 1.0.0
- **Total Endpoints**: 126 (108 implemented + 13 ML stubs + 5 admin)

---

## 📦 Setup Instructions

### Backend Setup

#### Prerequisites
- .NET 8.0 SDK or later
- Visual Studio 2022 or VS Code

#### Steps

1. **Navigate to the Backend directory**
   ```bash
   cd "Backend/EcoBackend.API"
   ```

2. **Restore dependencies**
   ```bash
   dotnet restore
   ```

3. **Apply database migrations**
   ```bash
   cd ../EcoBackend.Infrastructure
   dotnet ef database update --startup-project ../EcoBackend.API
   ```

4. **Run the application**
   ```bash
   cd ../EcoBackend.API
   dotnet run
   ```

The API will be available at `http://localhost:5000`

#### Configuration

Update `appsettings.json` in EcoBackend.API:

```json
{
  "JWT": {
    "Secret": "your-secret-key-here-min-32-chars-long!",
    "ValidIssuer": "EcoBackendAPI",
    "ValidAudience": "EcoBackendClient"
  },
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=eco.db"
  }
}
```

### Frontend Setup

#### Prerequisites
- Flutter SDK (3.0 or later)
- Android Studio or Xcode
- VS Code with Flutter extension

#### Steps

1. **Navigate to the Frontend directory**
   ```bash
   cd Frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   
   Edit `lib/core/config/api_config.dart`:
   ```dart
   class ApiConfig {
     static const String baseUrl = 'http://your-api-url:5000/api';
   }
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🔑 API Endpoints

### Overview
**Total Endpoints**: 126
- **Users**: 37 endpoints (auth, profile, settings, goals, daily scores)
- **Activities**: 13 endpoints (categories, types, CRUD, tips, history)
- **Achievements**: 17 endpoints (badges, challenges, user progress)
- **Analytics**: 6 endpoints (reports, dashboard, stats, CSV export)
- **Travel**: 19 endpoints (trips, location points, summaries)
- **Predictions**: 16 endpoints (13 ML stubs + 3 profile endpoints)
- **Notifications**: 7 endpoints (push notifications, device tokens)
- **Admin**: 11 endpoints (health checks, background jobs dashboard)

For complete API documentation with request/response examples, see **[API_DOCUMENTATION.md](Backend/API_DOCUMENTATION.md)**.

---

---

## 🧪 Testing

The backend has comprehensive test coverage:

```bash
# Run all tests
cd Backend
dotnet test

# Results
✅ 159/159 tests passing
✅ >70% code coverage
✅ 7 integration test suites (133 tests)
✅ 2 unit test suites (26 tests)
```

**Test Suites:**
- UsersEndpointTests (30 tests) - Authentication, profile, settings
- ActivitiesEndpointTests (44 tests) - Activities CRUD, categories, types
- AchievementsEndpointTests (17 tests) - Badges, challenges
- AnalyticsEndpointTests (6 tests) - Reports, stats
- TravelEndpointTests (30 tests) - Trips, locations
- PredictionsEndpointTests (6 tests) - ML endpoints
- ProfilePictureEncryptionServiceTests (20 tests) - AES-256 encryption
- EmailServiceTests (6 tests) - Email functionality

---

## 📱 Default Users

The application comes with pre-seeded admin users:

```
Username: admin
Password: admin123

Username: admin2
Password: admin123
```

## 🔒 Security Features

- **JWT Authentication** - Token-based authentication with 24-hour validity
- **Refresh Tokens** - Automatic rotation with 7-day validity
- **Password Hashing** - ASP.NET Identity with PBKDF2
- **Profile Picture Encryption** - AES-256-CBC encryption for stored images
- **Token Revocation** - Secure logout with token cleanup
- **Email Verification** - Mandatory email verification
- **Password Reset** - Secure reset via email tokens
- **CORS Configuration** - Configurable cross-origin policies
- **File Upload Validation** - Type and size validation, SHA256 filenames
- **Rate Limiting** - Ready for AspNetCoreRateLimit integration

## 📊 Database Schema

The application uses SQLite with **19 database entities**:

**User Management:**
- User (extends IdentityUser)
- RefreshToken
- PasswordResetToken
- EmailVerificationToken

**Activities:**
- ActivityCategory
- ActivityType
- ActivityLog
- Tip

**Achievements:**
- Badge
- UserBadge
- Challenge
- UserChallenge

**Travel:**
- Trip
- LocationPoint
- TravelSummary

**Notifications:**
- Notification
- DeviceToken

**User Features:**
- UserGoal
- DailyScore

**ML Predictions:**
- UserEcoProfile
- DailyLog

## 🤝 Contributing

This project follows **Clean Architecture** principles with comprehensive testing.

**For Development:**
- See [DEVELOPER_GUIDE.md](Backend/DEVELOPER_GUIDE.md) for setup and guidelines
- All PRs must maintain >70% test coverage
- Follow conventional commit messages
- Ensure all tests pass: `dotnet test`

**For Deployment:**
- See [DEPLOYMENT_GUIDE.md](Backend/DEPLOYMENT_GUIDE.md) for production deployment

**Migration Context:**
- Original Django backend is in `Backend2(python)` (legacy)
- Current ASP.NET Core backend is feature-complete migration
- Flutter frontend adapted to work with new backend

## 📝 Notes

- The `Backend2(python)` directory contains the original Django implementation
- Database migrations are managed by Entity Framework Core
- Static files (profile pictures) are served from the `media` folder
- The application includes seeded data for testing

## 🐛 Troubleshooting

### Backend won't start
- Ensure .NET 8.0 SDK is installed
- Check if port 5000 is available
- Verify database migrations are applied

### Frontend can't connect to API
- Check API URL in `api_config.dart`
- Ensure backend is running
- Verify CORS settings in backend

### Database errors
- Delete `eco.db` and run migrations again
- Check migration files in `EcoBackend.Infrastructure/Migrations`

## 📄 License

This project is for educational purposes.
