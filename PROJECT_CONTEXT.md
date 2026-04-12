# Eco Buddy - Complete Project Context

> **Project Name:** Eco Buddy (Eco Daily Score)
> **Project Type:** Full-Stack Mobile Application
> **Purpose:** Carbon footprint tracking, eco-friendly activity logging, and sustainability gamification
> **Target Platform:** Cross-platform mobile app (Android/iOS) with REST API backend

---

## TABLE OF CONTENTS

1. [Project Overview](#1-project-overview)
2. [Technology Stack](#2-technology-stack)
3. [Backend Architecture](#3-backend-architecture)
4. [Frontend Architecture](#4-frontend-architecture)
5. [Database Schema](#5-database-schema)
6. [API Endpoints](#6-api-endpoints)
7. [Authentication System](#7-authentication-system)
8. [Key Features](#8-key-features)
9. [Services Documentation](#9-services-documentation)
10. [Data Models](#10-data-models)
11. [Configuration](#11-configuration)
12. [Dependencies](#12-dependencies)
13. [File Structure](#13-file-structure)

---

## 1. PROJECT OVERVIEW

### 1.1 Problem Statement
Climate change is a pressing global issue, and individual carbon footprints contribute significantly to environmental degradation. People lack easy-to-use tools to track their daily activities' environmental impact and make eco-friendly lifestyle changes.

### 1.2 Solution
Eco Buddy is a comprehensive mobile application that:
- Tracks daily activities and calculates carbon emissions
- Gamifies sustainability with badges, challenges, and leaderboards
- Provides AI-powered eco-friendly suggestions via chatbot
- Uses machine learning to predict and improve eco scores
- Enables travel tracking with GPS for accurate carbon calculations

### 1.3 Key Objectives
1. Help users track and reduce their carbon footprint
2. Make sustainability engaging through gamification
3. Provide personalized eco-friendly recommendations
4. Build a community of environmentally conscious users
5. Enable data-driven insights into environmental impact

### 1.4 Target Users
- Environmentally conscious individuals
- Students learning about sustainability
- Organizations tracking employee eco-initiatives
- Anyone wanting to reduce their carbon footprint

---

## 2. TECHNOLOGY STACK

### 2.1 Backend
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | ASP.NET Core Web API | .NET 9.0 |
| Database | SQLite | - |
| ORM | Entity Framework Core | 9.0.3 |
| Authentication | JWT + ASP.NET Core Identity | - |
| Background Jobs | Hangfire | 1.8.14 |
| Email | MailKit (SMTP) | 4.3.0 |
| Push Notifications | Firebase Admin SDK | 3.0.1 |
| AI/ML | LLamaSharp + ML.NET ONNX | - |
| API Documentation | Swagger/OpenAPI | 6.5.0 |
| Object Mapping | AutoMapper | 12.0.1 |

### 2.2 Frontend
| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | SDK |
| State Management | Riverpod | flutter_riverpod |
| Navigation | go_router | - |
| HTTP Client | Dio | - |
| Local Storage | Hive | hive_flutter |
| Secure Storage | flutter_secure_storage | - |
| Charts | fl_chart | - |
| Animations | Lottie, Shimmer | - |
| Push Notifications | Firebase Messaging | - |
| Authentication | Google Sign-In | - |

### 2.3 External Services
| Service | Purpose |
|---------|---------|
| Firebase Cloud Messaging | Push notifications |
| Google OAuth | Social sign-in |
| SMTP (Gmail) | Transactional emails |
| LLaMA Model (Local GGUF) | AI chatbot |

---

## 3. BACKEND ARCHITECTURE

### 3.1 Clean Architecture Layers

```
Backend/
├── EcoBackend.API/              # Presentation Layer
│   ├── Controllers/             # HTTP endpoints (7 controllers)
│   ├── Services/                # Business logic (15+ services)
│   ├── DTOs/                    # Data Transfer Objects
│   └── Program.cs               # Application entry & configuration
│
├── EcoBackend.Core/             # Domain Layer
│   └── Entities/                # Domain models (25+ entities)
│
└── EcoBackend.Infrastructure/   # Data Access Layer
    └── Data/
        └── EcoDbContext.cs      # EF Core DbContext (27 DbSets)
```

### 3.2 Controllers Overview

| Controller | Base Route | Endpoints | Purpose |
|------------|------------|-----------|---------|
| UsersController | `/api/users` | 40+ | Auth, profile, goals, scores, notifications, leaderboard |
| ActivitiesController | `/api/activities` | 12 | Activity logging, categories, types, tips |
| AchievementsController | `/api/achievements` | 15 | Badges, challenges, gamification |
| TravelController | `/api/travel` | 17 | Trips, GPS tracking, CO2 calculations |
| AnalyticsController | `/api/analytics` | 6 | Reports, statistics, data export |
| PredictionsController | `/api/predictions` | 14 | ML predictions, eco profiles, logs |
| ChatbotController | `/api/chatbot` | 6 | AI chatbot sessions and messages |

### 3.3 Middleware & Configuration

**Custom Middleware:**
- Trailing slash stripper (for Flutter compatibility)
- JWT authentication middleware
- CORS "AllowAll" policy

**JSON Configuration:**
- Snake_case property naming
- Camel case to snake_case conversion

### 3.4 Background Jobs (Hangfire)

| Job | Schedule | Purpose |
|-----|----------|---------|
| calculate-daily-streaks | Daily midnight UTC | Update user activity streaks |
| generate-weekly-reports | Monday 1 AM UTC | Generate weekly analytics |
| generate-monthly-reports | 1st of month 2 AM UTC | Generate monthly analytics |
| check-badge-requirements | Every 6 hours | Award earned badges automatically |
| cleanup-expired-tokens | Daily 3 AM UTC | Remove expired refresh/reset tokens |

---

## 4. FRONTEND ARCHITECTURE

### 4.1 Project Structure

```
Frontend/lib/
├── main.dart                    # App entry point
├── core/                        # Core infrastructure
│   ├── config/                  # API configuration
│   ├── di/                      # Dependency injection (GetIt)
│   ├── navigation/              # AppShell, AppDrawer
│   ├── network/                 # DioClient, CacheManager, Connectivity
│   ├── providers/               # Riverpod providers
│   ├── routing/                 # go_router configuration
│   ├── storage/                 # Hive offline storage
│   ├── theme/                   # Light/Dark themes
│   ├── utils/                   # Helpers, responsive, permissions
│   └── widgets/                 # Reusable UI components
├── pages/                       # Feature screens (18 directories)
├── providers/                   # Theme provider
└── services/                    # API service layer (14 services)
```

### 4.2 Screens/Pages Overview

| Screen | Route | Purpose |
|--------|-------|---------|
| Home/Dashboard | `/home` | Main dashboard with eco score, stats, tips |
| Activity Log | `/activities` | Log new eco-friendly activities |
| All Activities | `/activities/all` | View/search all logged activities |
| Analytics | `/analytics` | Charts, breakdowns, predictions |
| Achievements | `/achievements` | Badges, challenges, milestones |
| Profile | `/profile` | User profile, impact stats |
| Edit Profile | `/edit-profile` | Update profile info and picture |
| Eco Profile Setup | `/eco-profile-setup` | ML questionnaire setup |
| Leaderboard | `/leaderboard` | Global/Friends/Local rankings |
| Tips | `/tips` | Eco-friendly suggestions |
| History | `/history` | Activity history log |
| Travel Insights | `/travel-insights` | Travel tracking, emissions |
| Eco Chat | `/eco-chat` | AI sustainability assistant |
| Settings | `/settings` | App preferences |
| Notifications | `/notifications` | In-app notifications |
| Login/Register | `/login`, `/register` | Authentication |
| Forgot/Reset Password | `/forgot-password`, `/reset-password` | Password recovery |

### 4.3 State Management

**Riverpod Provider Pattern:**
```dart
// Theme state
final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>

// Units state (metric/imperial)
final unitsProvider = StateNotifierProvider<UnitsNotifier, String>
```

**Usage:**
- `ConsumerStatefulWidget` for reactive UI
- `ref.watch()` for reading state
- `ref.read().notifier` for mutations
- Persistence via `OfflineStorage` (Hive)

### 4.4 Navigation

**go_router with ShellRoute:**
- Shell provides persistent navigation bar and drawer
- 5 main destinations: Dashboard, Log Activity, Analytics, Achievements, Profile
- Drawer includes: Chat, Tips, Leaderboard, History, Travel, Settings

### 4.5 Offline-First Architecture

- **Hive** for local NoSQL storage
- **OfflineStorage** class manages:
  - User data cache
  - API response cache (5-min TTL)
  - Offline action queue
  - App settings persistence
- **OfflineSyncService** syncs queued actions when online

---

## 5. DATABASE SCHEMA

### 5.1 Entity Relationship Overview

```
User (ASP.NET Identity)
├── UserGoal (1:N)
├── DailyScore (1:N)
├── DeviceToken (1:N)
├── Notification (1:N)
├── NotificationPreference (1:N)
├── RefreshToken (1:N)
├── PasswordResetToken (1:N)
├── EmailVerificationToken (1:N)
├── Activity (1:N) → ActivityType → ActivityCategory
├── UserBadge (1:N) → Badge
├── UserChallenge (1:N) → Challenge
├── Trip (1:N) → LocationPoint (1:N)
├── TravelSummary (1:N)
├── UserEcoProfile (1:1)
├── DailyLog (1:N)
├── WeeklyLog (1:N)
├── PredictionLog (1:N)
├── PredictionTrip (1:N)
├── ChatSession (1:N) → ChatMessage (1:N)
├── WeeklyReport (1:N)
└── MonthlyReport (1:N)
```

### 5.2 Core Entities

#### User Entity
```csharp
public class User : IdentityUser<int>
{
    // Profile
    public string? Name { get; set; }
    public string? Bio { get; set; }
    public string? ProfilePictureIv { get; set; }
    public string? Location { get; set; }
    public DateTime JoinedDate { get; set; }

    // Eco Stats
    public int EcoPoints { get; set; }
    public double TotalCO2Saved { get; set; }
    public int TotalActivities { get; set; }
    public int CurrentStreak { get; set; }
    public int LongestStreak { get; set; }
    public int WeeklyScore { get; set; }
    public int MonthlyScore { get; set; }

    // Settings
    public bool IsPublicProfile { get; set; }
    public bool ShowOnLeaderboard { get; set; }
    public bool AllowDataCollection { get; set; }
    public bool DailyRemindersEnabled { get; set; }
    public bool WeeklySummaryEnabled { get; set; }
    public bool AchievementAlertsEnabled { get; set; }
    public bool ChallengeUpdatesEnabled { get; set; }
    public bool CommunityNotificationsEnabled { get; set; }

    // OAuth
    public string? GoogleAuthId { get; set; }
    public bool IsEmailVerified { get; set; }
}
```

#### Activity Entities
```csharp
public class ActivityCategory
{
    public int Id { get; set; }
    public string Name { get; set; }           // Transport, Food, Energy, etc.
    public string? Icon { get; set; }
    public string? Description { get; set; }
}

public class ActivityType
{
    public int Id { get; set; }
    public string Name { get; set; }
    public int CategoryId { get; set; }
    public double CO2Impact { get; set; }      // kg CO2 saved/caused
    public int EcoPoints { get; set; }
    public string? Unit { get; set; }          // km, kWh, meals, etc.
    public string? Description { get; set; }
}

public class Activity
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public int ActivityTypeId { get; set; }
    public double Quantity { get; set; }
    public DateTime Date { get; set; }
    public string? Notes { get; set; }
    public double CO2Saved { get; set; }       // Calculated
    public int PointsEarned { get; set; }      // Calculated
}
```

#### Achievement Entities
```csharp
public class Badge
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public string Icon { get; set; }
    public string Category { get; set; }
    public string RequirementType { get; set; }  // activities_count, distance, streak, co2_saved, eco_points
    public double RequirementValue { get; set; }
    public string? RequirementUnit { get; set; }
    public int Points { get; set; }
}

public class Challenge
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Description { get; set; }
    public string Category { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public double TargetValue { get; set; }
    public string TargetUnit { get; set; }
    public int Points { get; set; }
    public int ParticipantsCount { get; set; }
}
```

#### Travel Entities
```csharp
public class Trip
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string Mode { get; set; }           // walking, cycling, car, bus, train, flight
    public double DistanceKm { get; set; }
    public double CO2Emitted { get; set; }     // Calculated using CO2PerKm
    public DateTime StartTime { get; set; }
    public DateTime? EndTime { get; set; }
    public int? Steps { get; set; }

    // CO2 emission factors (kg CO2 per km)
    public static readonly Dictionary<string, double> CO2PerKm = new()
    {
        ["walking"] = 0.0,
        ["cycling"] = 0.0,
        ["e_bike"] = 0.006,
        ["bus"] = 0.089,
        ["train"] = 0.041,
        ["metro"] = 0.033,
        ["car_petrol"] = 0.192,
        ["car_diesel"] = 0.171,
        ["car_electric"] = 0.053,
        ["motorcycle"] = 0.103,
        ["flight_domestic"] = 0.255,
        ["flight_international"] = 0.195
    };
}

public class LocationPoint
{
    public int Id { get; set; }
    public int TripId { get; set; }
    public double Latitude { get; set; }
    public double Longitude { get; set; }
    public double? Altitude { get; set; }
    public double? Speed { get; set; }
    public double? Accuracy { get; set; }
    public DateTime Timestamp { get; set; }
}
```

#### Prediction Entities
```csharp
public class UserEcoProfile
{
    public int Id { get; set; }
    public int UserId { get; set; }

    // Lifestyle factors for ML prediction
    public string DietType { get; set; }           // vegan, vegetarian, pescatarian, omnivore
    public string PrimaryTransport { get; set; }   // walking, cycling, public, car, mixed
    public string HomeEnergySource { get; set; }   // renewable, mixed, fossil
    public bool HasSolarPanels { get; set; }
    public int HouseholdSize { get; set; }
    public double HomeSquareMeters { get; set; }
    public string RecyclingHabits { get; set; }    // always, often, sometimes, rarely, never
    public int FlightsPerYear { get; set; }
    public bool UseReusableBags { get; set; }
    public bool CompostOrganicWaste { get; set; }
    public string ShoppingHabits { get; set; }     // minimal, average, frequent
    public string MeatConsumption { get; set; }    // daily, weekly, monthly, never
}

public class DailyLog
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public DateTime Date { get; set; }

    // Daily activity tracking
    public double WalkingKm { get; set; }
    public double CyclingKm { get; set; }
    public double PublicTransportKm { get; set; }
    public double CarKm { get; set; }
    public int VegetarianMeals { get; set; }
    public int MeatMeals { get; set; }
    public double ElectricityKwh { get; set; }
    public double GasUsageM3 { get; set; }
    public double WaterLiters { get; set; }
    public int RecycledItems { get; set; }
    public int PlasticItemsAvoided { get; set; }

    // Calculated
    public double TotalCO2Kg { get; set; }
    public int EcoScore { get; set; }
}
```

### 5.3 Seeded Data

**26 Default Badges:**
- First Steps (1 activity)
- Week Warrior (7-day streak)
- Eco Champion (30-day streak)
- Carbon Cutter (100kg CO2 saved)
- Point Master (1000 eco points)
- Distance Walker (100km walked)
- Cycling Pro (500km cycled)
- And more...

---

## 6. API ENDPOINTS

### 6.1 Authentication Endpoints (`/api/users`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/register` | User registration |
| POST | `/login` | User login (returns JWT + refresh token) |
| POST | `/token/refresh` | Refresh JWT token |
| POST | `/logout` | User logout |
| POST | `/google` | Google Sign-In |
| POST | `/forgot-password` | Request password reset email |
| POST | `/reset-password` | Reset password with token |
| POST | `/verify-email` | Verify email address |
| GET | `/check-username/{username}` | Check username availability |

### 6.2 Profile Endpoints (`/api/users`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/profile` | Get user profile |
| PUT | `/profile` | Update full profile |
| PATCH | `/profile` | Partial profile update |
| POST | `/profile-picture` | Upload profile picture |
| GET | `/profile-picture` | Get own profile picture |
| GET | `/profile-picture/{userId}` | Get user's profile picture |
| DELETE | `/profile-picture` | Delete profile picture |
| GET | `/privacy-settings` | Get privacy settings |
| PUT/PATCH | `/privacy-settings` | Update privacy settings |
| GET | `/notification-settings` | Get notification settings |
| PUT/PATCH | `/notification-settings` | Update notification settings |
| GET | `/export-data` | Export all user data (GDPR) |

### 6.3 Activity Endpoints (`/api/activities`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/categories` | List activity categories |
| GET | `/types` | List activity types (filterable) |
| GET | `/` | List user activities |
| POST | `/` | Log new activity |
| GET | `/{id}` | Get activity by ID |
| DELETE | `/{id}` | Delete activity |
| GET | `/today` | Get today's activities |
| GET | `/summary` | Get activity summary |
| GET | `/tips` | Get eco tips |
| GET | `/tips/daily` | Get daily tip |
| GET | `/history` | Get activity history |

### 6.4 Achievement Endpoints (`/api/achievements`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/badges` | List all badges |
| GET | `/my-badges` | List user's earned badges |
| GET | `/my-badges/summary` | Get badges summary |
| GET | `/challenges` | List all challenges |
| GET | `/challenges/active` | Get active challenges |
| GET | `/my-challenges` | List user's challenges |
| POST | `/challenges/{id}/join` | Join a challenge |
| PUT | `/my-challenges/{id}` | Update challenge progress |
| DELETE | `/my-challenges/{id}` | Leave challenge |

### 6.5 Travel Endpoints (`/api/travel`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/trips` | List trips |
| POST | `/trips` | Create trip |
| GET | `/trips/{id}` | Get trip by ID |
| PUT | `/trips/{id}` | Update trip |
| DELETE | `/trips/{id}` | Delete trip |
| GET | `/trips/today` | Get today's trips |
| GET | `/trips/stats` | Get trip statistics |
| POST | `/location-points` | Add GPS location |
| POST | `/locations/batch` | Batch upload locations |
| GET | `/summary` | Get travel summary |
| POST | `/steps` | Update step count |

### 6.6 Analytics Endpoints (`/api/analytics`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/weekly` | Get weekly report |
| GET | `/monthly` | Get monthly report |
| GET | `/dashboard` | Get analytics dashboard |
| GET | `/stats` | Get stats by period |
| GET | `/comparison` | Compare user vs average |
| GET | `/export/csv` | Export to CSV |

### 6.7 Prediction Endpoints (`/api/predictions`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/profile` | Get eco profile |
| POST | `/profile` | Create/update eco profile |
| GET | `/daily` | Get today's daily log |
| POST | `/daily` | Create/update daily log |
| POST | `/predict` | Predict eco score (ML) |
| POST | `/predict/quick` | Quick prediction (anonymous) |
| GET | `/history` | Get prediction history |
| GET | `/model-info` | Get ML model info |

### 6.8 Chatbot Endpoints (`/api/chatbot`)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/chat` | Send message, get AI reply |
| GET | `/sessions` | List chat sessions |
| GET | `/sessions/{id}` | Get session with messages |
| DELETE | `/sessions/{id}` | Delete session |
| DELETE | `/sessions` | Delete all sessions |
| GET | `/status` | Get chatbot status |

---

## 7. AUTHENTICATION SYSTEM

### 7.1 JWT Configuration

```json
{
  "JWT": {
    "Secret": "your-secret-key-min-32-chars",
    "ValidIssuer": "EcoBackend",
    "ValidAudience": "EcoBackendClient"
  }
}
```

### 7.2 Token Flow

```
1. User logs in with email/password or Google OAuth
2. Server returns:
   - JWT access token (short-lived)
   - Refresh token (long-lived, stored in DB)
3. Client stores tokens securely (flutter_secure_storage)
4. Client includes JWT in Authorization header
5. When JWT expires, client uses refresh token to get new pair
6. Refresh token rotation: old token revoked, new token issued
```

### 7.3 Password Reset Flow

```
1. User requests reset via /forgot-password
2. Server generates token, sends email with deep link
3. User clicks link: eco-daily-score://reset-password?token=xxx
4. App opens reset password page
5. User submits new password with token
6. Server validates token, updates password
```

### 7.4 Email Verification Flow

```
1. After registration, server sends verification email
2. Email contains deep link: eco-daily-score://verify-email?token=xxx
3. User clicks link, app opens verification page
4. App calls /verify-email with token
5. Server marks email as verified
```

---

## 8. KEY FEATURES

### 8.1 Activity Tracking
- Log eco-friendly activities by category
- Categories: Transport, Food, Energy, Shopping, Waste, Water
- Calculate CO2 savings per activity
- Earn eco points for each activity
- View daily, weekly, monthly summaries

### 8.2 Gamification System
- **Badges:** 26 achievements (First Steps to Eco Legend)
- **Challenges:** Time-limited community challenges
- **Streaks:** Daily activity streaks
- **Leaderboard:** Global, Friends, Local, Challenge rankings
- **Points:** Eco points earned for all activities

### 8.3 Travel Tracking
- GPS-based trip recording
- Automatic transport mode detection
- CO2 emission calculations per transport mode
- Step counting integration
- Daily/weekly travel summaries

### 8.4 AI Chatbot
- Sustainability advice and tips
- Powered by local LLaMA model (GGUF format)
- HTTP fallback for cloud AI
- Persistent chat sessions
- Context-aware responses

### 8.5 ML Predictions
- Eco profile questionnaire
- Daily activity logging
- ONNX model for score prediction
- Personalized recommendations
- Progress tracking over time

### 8.6 Analytics & Reports
- Interactive charts (fl_chart)
- Category breakdowns
- Period comparisons
- Trend analysis
- CSV data export

### 8.7 Push Notifications
- Firebase Cloud Messaging
- Categories: Daily reminders, achievements, challenges, community
- Per-category preferences
- Device token management

### 8.8 Offline Support
- Hive local database
- Offline action queue
- Automatic sync when online
- API response caching

### 8.9 Privacy & Security
- Encrypted profile pictures
- GDPR data export
- Privacy settings control
- Secure token storage
- Profile visibility options

---

## 9. SERVICES DOCUMENTATION

### 9.1 Backend Services

| Service | File | Responsibilities |
|---------|------|------------------|
| **UserService** | `UserService.cs` | Registration, login, profile CRUD, password reset, email verification, Google OAuth, leaderboard, data export |
| **ActivityService** | `ActivityService.cs` | Activity CRUD, categories, types, tips, daily summaries, history |
| **AchievementService** | `AchievementService.cs` | Badge management, challenge participation, progress tracking, automatic badge awarding |
| **TravelService** | `TravelService.cs` | Trip CRUD, GPS locations, CO2 calculations, travel summaries, batch uploads |
| **AnalyticsService** | `AnalyticsService.cs` | Weekly/monthly reports, dashboard data, statistics, CSV export |
| **PredictionService** | `PredictionService.cs` | Eco profiles, daily/weekly logs, ML predictions, prediction history |
| **ChatbotService** | `ChatbotService.cs` | LLamaSharp integration, session management, message handling, HTTP fallback |
| **NotificationService** | `NotificationService.cs` | FCM sending, device tokens, notification CRUD, preferences |
| **EmailService** | `EmailService.cs` | SMTP via MailKit, password reset emails, verification emails, welcome emails |
| **BackgroundJobService** | `BackgroundJobService.cs` | Streak calculation, report generation, badge checking, token cleanup |
| **GoalService** | `GoalService.cs` | User goal CRUD, progress tracking |
| **DailyScoreService** | `DailyScoreService.cs` | Daily score management |
| **LlamaModelService** | `LlamaModelService.cs` | Singleton LLaMA model loader |
| **ProfilePictureEncryptionService** | `ProfilePictureEncryptionService.cs` | AES encryption for profile pictures |
| **EcoScorePredictorService** | `EcoScorePredictorService.cs` | ONNX model inference for eco scores |

### 9.2 Frontend Services

| Service | File | Responsibilities |
|---------|------|------------------|
| **AuthService** | `auth_service.dart` | Login, register, logout, token refresh, secure storage |
| **ActivityService** | `activity_service.dart` | Activity API calls, tips, categories |
| **DashboardService** | `dashboard_service.dart` | Dashboard data, challenges, leaderboard |
| **AnalyticsService** | `analytics_service.dart` | Analytics with date filtering, comparisons |
| **AchievementsService** | `achievements_service.dart` | Badges, challenges API |
| **NotificationService** | `notification_service.dart` | In-app notifications |
| **FCMService** | `fcm_service.dart` | Firebase messaging setup |
| **TravelService** | `travel_service.dart` | Travel logging, trip calculations |
| **EcoProfileService** | `eco_profile_service.dart` | Eco profile, ML predictions |
| **GuestService** | `guest_service.dart` | Guest mode management |
| **EmailService** | `email_service.dart` | Email verification requests |
| **PermissionService** | `permission_service.dart` | Device permission handling |
| **BackgroundServices** | `background_services.dart` | GPS tracking, offline sync, optimization |
| **SecureProfilePictureService** | `secure_profile_picture_service.dart` | Encrypted picture upload/download |

---

## 10. DATA MODELS

### 10.1 Backend DTOs

#### Authentication
```csharp
UserRegistrationDto { Username, Email, Password, Name? }
LoginDto { Email, Password }
RefreshTokenDto { Token, RefreshToken }
GoogleSignInDto { IdToken }
ForgotPasswordDto { Email }
ResetPasswordDto { Token, NewPassword }
```

#### Profile
```csharp
UserProfileDto { Id, Username, Email, Name, Bio, Location, ProfilePictureUrl, EcoPoints, TotalCO2Saved, CurrentStreak, ... }
UserPrivacySettingsDto { IsPublicProfile, ShowOnLeaderboard, AllowDataCollection }
NotificationSettingsDto { DailyReminders, WeeklySummary, AchievementAlerts, ... }
```

#### Activities
```csharp
ActivityCreateDto { ActivityTypeId, Quantity, Date, Notes }
ActivityResponseDto { Id, Type, Category, Quantity, CO2Saved, PointsEarned, Date, Notes }
CategoryDto { Id, Name, Icon, Description }
ActivityTypeDto { Id, Name, CategoryId, CO2Impact, EcoPoints, Unit }
TipDto { Id, Title, Description, Category }
```

#### Travel
```csharp
CreateTripDto { Mode, DistanceKm, StartTime, EndTime, Steps }
TripDto { Id, Mode, DistanceKm, CO2Emitted, StartTime, EndTime, Steps }
LocationPointDto { Latitude, Longitude, Altitude, Speed, Accuracy, Timestamp }
TravelSummaryDto { Date, TotalDistanceKm, TotalCO2, TripsByMode }
```

#### Achievements
```csharp
BadgeDto { Id, Name, Description, Icon, Category, RequirementType, RequirementValue, Points }
UserBadgeDto { Badge, EarnedAt, Progress }
ChallengeDto { Id, Name, Description, StartDate, EndDate, TargetValue, TargetUnit, Points, ParticipantsCount }
```

#### Predictions
```csharp
UserEcoProfileDto { DietType, PrimaryTransport, HomeEnergySource, HasSolarPanels, ... }
DailyLogInputDto { WalkingKm, CyclingKm, PublicTransportKm, CarKm, VegetarianMeals, ... }
PredictionResultDto { EcoScore, CO2Footprint, Recommendations, Breakdown }
```

### 10.2 Frontend Models

Models are embedded within service files. Key structures mirror backend DTOs with Dart types.

---

## 11. CONFIGURATION

### 11.1 Backend Configuration (appsettings.json)

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=eco.db"
  },
  "JWT": {
    "Secret": "your-secret-key-here-min-32-chars-long",
    "ValidIssuer": "EcoBackend",
    "ValidAudience": "EcoBackendClient"
  },
  "Email": {
    "SmtpHost": "smtp.gmail.com",
    "SmtpPort": 587,
    "SmtpUser": "",
    "SmtpPassword": "",
    "FromEmail": "noreply@ecodailyscore.com",
    "FromName": "Eco Daily Score",
    "PasswordResetUrl": "eco-daily-score://reset-password",
    "EmailVerificationUrl": "eco-daily-score://verify-email",
    "PasswordResetTimeout": 3600,
    "EmailVerificationTimeout": 86400
  },
  "Firebase": {
    "CredentialPath": "firebase-credentials.json"
  },
  "Authentication": {
    "Google": {
      "ClientId": ""
    }
  },
  "Chatbot": {
    "ModelPath": "models/ecobot-3b-q5_k_m.gguf",
    "Endpoint": "",
    "ApiKey": "",
    "Model": "gpt-3.5-turbo"
  }
}
```

### 11.2 Frontend Configuration

**API Config** (`api_config.dart`):
```dart
class ApiConfig {
  static const String baseUrl = 'https://api.ecobuddy.example.com/api';
}
```

**Deep Links:**
- `eco-daily-score://reset-password`
- `eco-daily-score://verify-email`

**Cache Settings:**
- HTTP response cache: 5 minutes
- Profile picture cache: 30 minutes

**Responsive Breakpoints:**
- Mobile: < 600px
- Tablet: 600-900px
- Desktop: > 900px

---

## 12. DEPENDENCIES

### 12.1 Backend NuGet Packages

| Package | Version | Purpose |
|---------|---------|---------|
| Microsoft.AspNetCore.Authentication.JwtBearer | 9.0.3 | JWT authentication |
| Microsoft.AspNetCore.Identity.EntityFrameworkCore | 9.0.3 | Identity system |
| Microsoft.EntityFrameworkCore.Sqlite | 9.0.3 | SQLite database |
| AutoMapper.Extensions.Microsoft.DependencyInjection | 12.0.1 | Object mapping |
| FirebaseAdmin | 3.0.1 | FCM notifications |
| Hangfire.AspNetCore | 1.8.14 | Background jobs |
| Hangfire.MemoryStorage | 1.8.1 | Hangfire storage |
| MailKit | 4.3.0 | SMTP emails |
| LLamaSharp | 0.* | Local AI model |
| LLamaSharp.Backend.Cpu | 0.* | CPU inference |
| Microsoft.ML.OnnxRuntime | 1.20.1 | ML predictions |
| Swashbuckle.AspNetCore | 6.5.0 | Swagger API docs |
| Google.Apis.Auth | 1.73.0 | Google OAuth |

### 12.2 Frontend Flutter Packages

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| go_router | Navigation/routing |
| dio | HTTP client |
| hive_flutter | Local storage |
| flutter_secure_storage | Secure token storage |
| firebase_core | Firebase initialization |
| firebase_messaging | Push notifications |
| google_sign_in | Google OAuth |
| fl_chart | Charts/graphs |
| shimmer | Loading animations |
| lottie | JSON animations |
| image_picker | Profile picture selection |
| permission_handler | Device permissions |
| uni_links | Deep linking |
| connectivity_plus | Network monitoring |
| logger | Structured logging |

---

## 13. FILE STRUCTURE

### 13.1 Complete Backend Structure

```
Backend/
├── EcoBackend.API/
│   ├── Controllers/
│   │   ├── UsersController.cs
│   │   ├── ActivitiesController.cs
│   │   ├── AchievementsController.cs
│   │   ├── TravelController.cs
│   │   ├── AnalyticsController.cs
│   │   ├── PredictionsController.cs
│   │   └── ChatbotController.cs
│   ├── Services/
│   │   ├── UserService.cs
│   │   ├── ActivityService.cs
│   │   ├── AchievementService.cs
│   │   ├── TravelService.cs
│   │   ├── AnalyticsService.cs
│   │   ├── PredictionService.cs
│   │   ├── ChatbotService.cs
│   │   ├── NotificationService.cs
│   │   ├── EmailService.cs
│   │   ├── BackgroundJobService.cs
│   │   ├── GoalService.cs
│   │   ├── DailyScoreService.cs
│   │   ├── LlamaModelService.cs
│   │   ├── ProfilePictureEncryptionService.cs
│   │   └── EcoScorePredictorService.cs
│   ├── DTOs/
│   │   ├── UserDtos.cs
│   │   ├── ActivityDtos.cs
│   │   ├── AchievementDtos.cs
│   │   ├── TravelDtos.cs
│   │   ├── PredictionDtos.cs
│   │   ├── ChatDtos.cs
│   │   ├── GoalDtos.cs
│   │   ├── DailyScoreDtos.cs
│   │   ├── NotificationDtos.cs
│   │   └── UserEcoProfileDto.cs
│   ├── Program.cs
│   ├── appsettings.json
│   └── EcoBackend.API.csproj
├── EcoBackend.Core/
│   ├── Entities/
│   │   ├── UserEntities.cs
│   │   ├── ActivityEntities.cs
│   │   ├── AchievementEntities.cs
│   │   ├── TravelEntities.cs
│   │   ├── PredictionEntities.cs
│   │   ├── AnalyticsEntities.cs
│   │   └── ChatEntities.cs
│   └── EcoBackend.Core.csproj
└── EcoBackend.Infrastructure/
    ├── Data/
    │   └── EcoDbContext.cs
    └── EcoBackend.Infrastructure.csproj
```

### 13.2 Complete Frontend Structure

```
Frontend/lib/
├── main.dart
├── core/
│   ├── config/
│   │   └── api_config.dart
│   ├── di/
│   │   └── service_locator.dart
│   ├── navigation/
│   │   ├── app_drawer.dart
│   │   └── app_shell.dart
│   ├── network/
│   │   ├── cache_manager.dart
│   │   ├── connectivity_service.dart
│   │   └── dio_client.dart
│   ├── providers/
│   │   ├── app_providers.dart
│   │   └── units_provider.dart
│   ├── routing/
│   │   └── app_router.dart
│   ├── storage/
│   │   └── offline_storage.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── app_logger.dart
│   │   ├── animation_utils.dart
│   │   ├── haptic_helper.dart
│   │   ├── image_optimizer.dart
│   │   ├── permission_extensions.dart
│   │   ├── permissions_init.dart
│   │   ├── responsive.dart
│   │   ├── search_filter_helper.dart
│   │   └── unit_converter.dart
│   └── widgets/
│       ├── daily_tip_card.dart
│       ├── eco_score_card.dart
│       ├── error_view.dart
│       ├── loading_widgets.dart
│       ├── permission_request_widget.dart
│       ├── pull_to_refresh_wrapper.dart
│       ├── quick_stats_card.dart
│       └── secure_profile_picture_avatar.dart
├── pages/
│   ├── achievements/
│   │   └── achievements_page.dart
│   ├── activities/
│   │   └── activities_page.dart
│   ├── activity/
│   │   ├── activity_log_page.dart
│   │   └── all_activities_page.dart
│   ├── analytics/
│   │   └── analytics_page.dart
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── signup_page.dart
│   │   ├── register_page.dart
│   │   ├── welcome_page.dart
│   │   ├── forgot_password_page.dart
│   │   ├── reset_password_page.dart
│   │   └── verify_email_page.dart
│   ├── chat/
│   │   └── eco_chat_page.dart
│   ├── history/
│   │   └── history_page.dart
│   ├── home/
│   │   └── home_page.dart
│   ├── leaderboard/
│   │   └── leaderboard_page.dart
│   ├── legal/
│   │   ├── terms_of_service_page.dart
│   │   └── privacy_policy_page.dart
│   ├── notifications/
│   │   └── notifications_page.dart
│   ├── privacy/
│   │   └── privacy_dashboard_page.dart
│   ├── profile/
│   │   ├── profile_page.dart
│   │   ├── edit_profile_page.dart
│   │   ├── eco_profile_setup_page.dart
│   │   ├── notifications_page.dart
│   │   ├── export_data_page.dart
│   │   └── help_support_page.dart
│   ├── settings/
│   │   └── settings_page.dart
│   ├── tips/
│   │   └── tips_page.dart
│   └── travel/
│       └── travel_insights_page.dart
├── providers/
│   └── theme_provider.dart
└── services/
    ├── achievements_service.dart
    ├── activity_service.dart
    ├── analytics_service.dart
    ├── auth_service.dart
    ├── background_services.dart
    ├── dashboard_service.dart
    ├── eco_profile_service.dart
    ├── email_service.dart
    ├── fcm_service.dart
    ├── guest_service.dart
    ├── notification_service.dart
    ├── permission_service.dart
    ├── secure_profile_picture_service.dart
    └── travel_service.dart
```

---

## SUMMARY

**Eco Buddy** is a comprehensive sustainability tracking application featuring:

- **Full-stack architecture** with .NET 9 backend and Flutter frontend
- **100+ API endpoints** covering all user interactions
- **25+ database entities** for complete data modeling
- **AI-powered chatbot** using local LLaMA model
- **ML predictions** for personalized eco scores
- **Gamification** with badges, challenges, and leaderboards
- **GPS travel tracking** with CO2 calculations
- **Offline-first** mobile experience
- **Push notifications** via Firebase
- **Social authentication** with Google OAuth
- **Privacy controls** and GDPR compliance

---

*Document Generated: March 2026*
*Project: Eco Buddy (Eco Daily Score)*
