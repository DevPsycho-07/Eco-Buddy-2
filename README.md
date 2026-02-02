# Eco Daily Score

A comprehensive eco-friendly activity tracking application that helps users monitor their carbon footprint, earn achievements, and compete on leaderboards.

## 📋 Project Structure

```
.
├── Backend/                    # ASP.NET Core 8.0 Web API
│   ├── EcoBackend.API/        # API Controllers & Endpoints
│   ├── EcoBackend.Core/       # Domain Entities & Interfaces
│   └── EcoBackend.Infrastructure/  # Data Access & Migrations
│
├── Backend2(python)/          # Original Django Backend (Legacy)
│
└── Frontend/                  # Flutter Mobile Application
    └── lib/
        ├── pages/            # UI Screens
        ├── services/         # API & Business Logic
        └── core/             # Configuration & Constants
```

## 🚀 Features

### User Management
- User registration and authentication with JWT tokens
- Profile management with profile picture upload
- Real-time username availability checking
- Privacy settings and preferences

### Activity Tracking
- Log eco-friendly activities
- Track carbon footprint (CO2 saved/emitted)
- Daily activity summaries
- Activity categorization and points system

### Achievements System
- Unlock badges based on activities
- Challenge system with progress tracking
- Achievement summaries and statistics
- Points and rewards system

### Analytics & Insights
- Weekly/monthly statistics
- CO2 savings comparison
- Activity trends
- User ranking and leaderboards

### Travel Tracking
- Multi-modal transport tracking
- Carbon footprint calculation per trip
- Travel history and statistics

### ML Predictions
- Carbon footprint predictions
- Eco-score forecasting
- Personalized recommendations

## 🛠️ Technologies

### Backend (ASP.NET Core)
- **Framework**: ASP.NET Core 8.0
- **Database**: SQLite with Entity Framework Core
- **Authentication**: JWT Bearer Tokens
- **Identity**: ASP.NET Core Identity
- **API Documentation**: Swagger/OpenAPI

### Frontend (Flutter)
- **Framework**: Flutter
- **State Management**: StatefulWidget
- **HTTP Client**: http package
- **Storage**: flutter_secure_storage
- **Image Handling**: image_picker

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

### Authentication
- `POST /api/users/register` - User registration
- `POST /api/users/login` - User login
- `POST /api/users/logout` - User logout
- `GET /api/users/check-username/{username}` - Check username availability

### User Profile
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `POST /api/users/upload-picture` - Upload profile picture
- `GET /api/users/my-rank` - Get user rank
- `GET /api/users/leaderboard` - Get leaderboard

### Activities
- `GET /api/activities` - Get all activities
- `POST /api/activities/log` - Log new activity
- `GET /api/activities/log/today` - Get today's activities
- `GET /api/activities/log/summary` - Get activity summary
- `GET /api/activities/tips/daily` - Get daily eco tips

### Achievements
- `GET /api/achievements/badges` - Get all badges
- `GET /api/achievements/my-badges` - Get user badges
- `GET /api/achievements/summary` - Get achievement summary
- `GET /api/achievements/my-badges/summary` - Get badge summary
- `GET /api/achievements/challenges` - Get all challenges
- `GET /api/achievements/challenges/active` - Get active challenges
- `POST /api/achievements/challenges/{id}/join` - Join a challenge

### Analytics
- `GET /api/analytics/stats?period=week` - Get statistics
- `GET /api/analytics/comparison` - Compare current vs previous week
- `GET /api/analytics/weekly` - Get weekly analytics
- `GET /api/analytics/dashboard` - Get dashboard data

### Travel
- `GET /api/travel/trips` - Get all trips
- `POST /api/travel/trips` - Log new trip
- `GET /api/travel/trips/{id}` - Get trip details

### Predictions
- `POST /api/predictions/predict-carbon` - Predict carbon footprint
- `POST /api/predictions/predict-score` - Predict eco score
- `GET /api/predictions/recommendations` - Get personalized recommendations

## 📱 Default Users

The application comes with pre-seeded admin users:

```
Username: admin
Password: admin123

Username: admin2
Password: admin123
```

## 🔒 Security Features

- JWT token-based authentication
- Secure password hashing with ASP.NET Identity
- Token expiration and refresh mechanism
- CORS configuration for cross-origin requests
- File upload validation (type and size)

## 📊 Database Schema

The application uses SQLite with the following main entities:
- **Users** - User accounts and profiles
- **Activities** - Logged eco-friendly activities
- **ActivityTypes** - Activity categories
- **Badges** - Achievement badges
- **UserBadges** - User-badge relationships
- **Challenges** - Achievement challenges
- **UserChallenges** - User challenge progress
- **Trips** - Travel records
- **Tips** - Eco-friendly tips
- **UserEcoProfiles** - Extended user eco data

## 🤝 Contributing

This is a migration project from Django (Python) to ASP.NET Core (C#). The Flutter frontend has been adapted to work with both backends.

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
