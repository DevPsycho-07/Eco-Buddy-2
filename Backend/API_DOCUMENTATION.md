# 📡 Eco Daily Score - API Documentation

Complete reference for all 126 API endpoints.

**Base URL:** `http://localhost:5145/api` (Development)  
**Version:** 1.0.0  
**Authentication:** Bearer JWT Token

---

## 📑 Table of Contents

1. [Authentication](#authentication)
2. [Users Controller (37 endpoints)](#users-controller)
3. [Activities Controller (13 endpoints)](#activities-controller)
4. [Achievements Controller (17 endpoints)](#achievements-controller)
5. [Analytics Controller (6 endpoints)](#analytics-controller)
6. [Travel Controller (19 endpoints)](#travel-controller)
7. [Predictions Controller (16 endpoints)](#predictions-controller)
8. [Notifications Controller (7 endpoints)](#notifications-controller)
9. [Error Responses](#error-responses)

---

## 🔐 Authentication

Most endpoints require JWT authentication. Include the token in the `Authorization` header:

```http
Authorization: Bearer <your-jwt-token>
```

### Token Lifecycle
- **Access Token:** 24 hours validity
- **Refresh Token:** 7 days validity with automatic rotation
- **Token Refresh:** Use `/api/users/refresh-token` before expiration

---

## 👤 Users Controller

### 1. Register User

**Endpoint:** `POST /api/users/register`  
**Authentication:** None  
**Description:** Register a new user account

**Request Body:**
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "SecurePassword123!",
  "confirmPassword": "SecurePassword123!"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "CfDJ8M...",
  "user": {
    "id": "user-guid",
    "username": "john_doe",
    "email": "john@example.com",
    "totalPoints": 0,
    "carbonSaved": 0.0,
    "currentStreak": 0
  }
}
```

**Errors:**
- `400 Bad Request` - Validation errors, username/email already exists

---

### 2. Check Username Availability

**Endpoint:** `GET /api/users/check-username/{username}`  
**Authentication:** None  
**Description:** Check if a username is available

**Response (200 OK):**
```json
{
  "isAvailable": true
}
```

---

### 3. Login

**Endpoint:** `POST /api/users/login`  
**Authentication:** None  
**Description:** Authenticate user and receive tokens

**Request Body:**
```json
{
  "username": "john_doe",
  "password": "SecurePassword123!"
}
```

**Response (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "CfDJ8M...",
  "user": {
    "id": "user-guid",
    "username": "john_doe",
    "email": "john@example.com",
    "totalPoints": 250,
    "carbonSaved": 15.5,
    "currentStreak": 5
  }
}
```

**Errors:**
- `401 Unauthorized` - Invalid credentials

---

### 4. Refresh Token

**Endpoint:** `POST /api/users/refresh-token`  
**Authentication:** None  
**Description:** Refresh expired access token using refresh token

**Request Body:**
```json
{
  "refreshToken": "CfDJ8M..."
}
```

**Response (200 OK):**
```json
{
  "token": "new-access-token",
  "refreshToken": "new-refresh-token"
}
```

**Errors:**
- `401 Unauthorized` - Invalid or expired refresh token

---

### 5. Logout

**Endpoint:** `POST /api/users/logout`  
**Authentication:** Required  
**Description:** Revoke user's refresh tokens

**Response (200 OK):**
```json
"Logged out successfully"
```

---

### 6. Get Profile

**Endpoint:** `GET /api/users/profile`  
**Authentication:** Required  
**Description:** Get authenticated user's profile

**Response (200 OK):**
```json
{
  "id": "user-guid",
  "username": "john_doe",
  "email": "john@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "bio": "Eco enthusiast",
  "totalPoints": 250,
  "carbonSaved": 15.5,
  "currentStreak": 5,
  "longestStreak": 12,
  "joinedDate": "2026-01-15T10:30:00Z",
  "lastActive": "2026-02-16T14:22:00Z",
  "hasProfilePicture": true
}
```

---

### 7. Update Profile

**Endpoint:** `PUT /api/users/profile`  
**Authentication:** Required  
**Description:** Update user profile information

**Request Body:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "bio": "Passionate about sustainable living",
  "email": "newemail@example.com"
}
```

**Response (200 OK):**
```json
{
  "id": "user-guid",
  "username": "john_doe",
  "email": "newemail@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "bio": "Passionate about sustainable living",
  ...
}
```

---

### 8. Upload Profile Picture

**Endpoint:** `POST /api/users/upload-picture`  
**Authentication:** Required  
**Content-Type:** `multipart/form-data`  
**Description:** Upload and encrypt profile picture

**Form Data:**
- `file`: Image file (JPG, PNG) - Max 5MB

**Response (200 OK):**
```json
{
  "message": "Profile picture uploaded successfully",
  "hasProfilePicture": true
}
```

**Errors:**
- `400 Bad Request` - No file, invalid format, or file too large

---

### 9. Get Profile Picture

**Endpoint:** `GET /api/users/profile-picture`  
**Authentication:** Required  
**Description:** Get authenticated user's decrypted profile picture

**Response (200 OK):**
- Content-Type: `image/jpeg` or `image/png`
- Body: Binary image data

**Errors:**
- `404 Not Found` - No profile picture uploaded

---

### 10. Delete Profile Picture

**Endpoint:** `DELETE /api/users/profile-picture`  
**Authentication:** Required  
**Description:** Delete user's profile picture

**Response (200 OK):**
```json
{
  "message": "Profile picture deleted successfully"
}
```

---

### 11. Get Leaderboard

**Endpoint:** `GET /api/users/leaderboard?period=all&limit=10`  
**Authentication:** Required  
**Description:** Get top users ranked by points

**Query Parameters:**
- `period` (optional): `week`, `month`, `all` (default: `all`)
- `limit` (optional): 1-100 (default: 10)

**Response (200 OK):**
```json
[
  {
    "rank": 1,
    "userId": "user-guid-1",
    "username": "eco_champion",
    "totalPoints": 1250,
    "carbonSaved": 85.5,
    "hasProfilePicture": true
  },
  {
    "rank": 2,
    "userId": "user-guid-2",
    "username": "green_warrior",
    "totalPoints": 980,
    "carbonSaved": 62.3,
    "hasProfilePicture": false
  }
]
```

---

### 12. Get My Rank

**Endpoint:** `GET /api/users/my-rank`  
**Authentication:** Required  
**Description:** Get authenticated user's leaderboard rank

**Response (200 OK):**
```json
{
  "rank": 15,
  "totalUsers": 342,
  "percentile": 95.6
}
```

---

### 13. Get Dashboard

**Endpoint:** `GET /api/users/dashboard`  
**Authentication:** Required  
**Description:** Get user dashboard with today's stats

**Response (200 OK):**
```json
{
  "todayPoints": 45,
  "todayCarbonSaved": 3.2,
  "todayActivities": 4,
  "currentStreak": 7,
  "weeklyProgress": 68.5,
  "nextBadge": {
    "name": "Eco Warrior",
    "description": "Reach 500 points",
    "progress": 85.0
  }
}
```

---

### 14. Export User Data

**Endpoint:** `GET /api/users/export-data`  
**Authentication:** Required  
**Description:** Export all user data (GDPR compliance)

**Response (200 OK):**
- Content-Type: `application/json`
- Content-Disposition: `attachment; filename="user-data-{userId}.json"`

**Response Body:**
```json
{
  "user": { ... },
  "activities": [ ... ],
  "badges": [ ... ],
  "trips": [ ... ],
  "challenges": [ ... ],
  "exportedAt": "2026-02-16T14:30:00Z"
}
```

---

### 15. Get Privacy Settings

**Endpoint:** `GET /api/users/privacy-settings`  
**Authentication:** Required  
**Description:** Get user's privacy preferences

**Response (200 OK):**
```json
{
  "shareLocation": true,
  "shareActivityData": true,
  "shareHealthData": false,
  "shareCalendarData": false
}
```

---

### 16. Update Privacy Settings

**Endpoint:** `PUT /api/users/privacy-settings`  
**Authentication:** Required  
**Description:** Update privacy preferences

**Request Body:**
```json
{
  "shareLocation": false,
  "shareActivityData": true,
  "shareHealthData": false,
  "shareCalendarData": true
}
```

**Response (200 OK):**
```json
{
  "shareLocation": false,
  "shareActivityData": true,
  "shareHealthData": false,
  "shareCalendarData": true
}
```

---

### 17. Get Notification Settings

**Endpoint:** `GET /api/users/notification-settings`  
**Authentication:** Required  
**Description:** Get notification preferences

**Response (200 OK):**
```json
{
  "pushEnabled": true,
  "emailEnabled": true,
  "achievementNotifications": true,
  "challengeNotifications": true,
  "streakReminders": true,
  "weeklyReports": true
}
```

---

### 18. Update Notification Settings

**Endpoint:** `PUT /api/users/notification-settings`  
**Authentication:** Required  
**Description:** Update notification preferences

**Request Body:**
```json
{
  "pushEnabled": true,
  "emailEnabled": false,
  "achievementNotifications": true,
  "challengeNotifications": true,
  "streakReminders": false,
  "weeklyReports": true
}
```

**Response (200 OK):**
```json
{
  "pushEnabled": true,
  "emailEnabled": false,
  ...
}
```

---

### 19. Forgot Password

**Endpoint:** `POST /api/users/forgot-password`  
**Authentication:** None  
**Description:** Request password reset email

**Request Body:**
```json
{
  "email": "john@example.com"
}
```

**Response (200 OK):**
```json
{
  "message": "Password reset email sent"
}
```

---

### 20. Reset Password

**Endpoint:** `POST /api/users/reset-password`  
**Authentication:** None  
**Description:** Reset password using token from email

**Request Body:**
```json
{
  "token": "reset-token-from-email",
  "newPassword": "NewSecurePassword123!"
}
```

**Response (200 OK):**
```json
{
  "message": "Password reset successful"
}
```

**Errors:**
- `400 Bad Request` - Invalid or expired token

---

### 21. Verify Email

**Endpoint:** `POST /api/users/verify-email`  
**Authentication:** None  
**Description:** Verify email address using token

**Request Body:**
```json
{
  "token": "verification-token-from-email"
}
```

**Response (200 OK):**
```json
{
  "message": "Email verified successfully"
}
```

---

### 22. Resend Verification Email

**Endpoint:** `POST /api/users/resend-verification`  
**Authentication:** Required  
**Description:** Resend email verification link

**Response (200 OK):**
```json
{
  "message": "Verification email sent"
}
```

---

### 23-28. Goals Management

#### Get Goals
**Endpoint:** `GET /api/users/goals`  
**Authentication:** Required

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "userId": "user-guid",
    "goalType": "DailyCarbonSavings",
    "targetValue": 5.0,
    "currentValue": 3.2,
    "deadline": "2026-02-28T23:59:59Z",
    "isCompleted": false,
    "createdAt": "2026-02-01T00:00:00Z"
  }
]
```

#### Create Goal
**Endpoint:** `POST /api/users/goals`  
**Authentication:** Required

**Request Body:**
```json
{
  "goalType": "DailyCarbonSavings",
  "targetValue": 5.0,
  "deadline": "2026-02-28T23:59:59Z"
}
```

#### Update Goal
**Endpoint:** `PUT /api/users/goals/{id}`  
**Authentication:** Required

#### Delete Goal
**Endpoint:** `DELETE /api/users/goals/{id}`  
**Authentication:** Required

---

### 29-37. Daily Scores Management

#### Get Daily Scores
**Endpoint:** `GET /api/users/daily-scores?startDate=2026-02-01&endDate=2026-02-16`  
**Authentication:** Required

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "userId": "user-guid",
    "date": "2026-02-16",
    "score": 85,
    "breakdown": {
      "transportation": 30,
      "energy": 25,
      "food": 20,
      "other": 10
    }
  }
]
```

#### Get Daily Score by Date
**Endpoint:** `GET /api/users/daily-scores/{date}`  
**Authentication:** Required

#### Create/Update Daily Score
**Endpoint:** `POST /api/users/daily-scores`  
**Authentication:** Required

#### Update Daily Score
**Endpoint:** `PUT /api/users/daily-scores/{id}`  
**Authentication:** Required

#### Delete Daily Score
**Endpoint:** `DELETE /api/users/daily-scores/{id}`  
**Authentication:** Required

---

## 🎯 Activities Controller

### 1. Get Categories

**Endpoint:** `GET /api/activities/categories`  
**Authentication:** Required  
**Description:** Get all activity categories

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Transportation",
    "description": "Eco-friendly travel options",
    "iconName": "directions_bus"
  },
  {
    "id": 2,
    "name": "Energy",
    "description": "Energy conservation activities",
    "iconName": "power"
  }
]
```

---

### 2. Get Category by ID

**Endpoint:** `GET /api/activities/categories/{id}`  
**Authentication:** Required  
**Description:** Get specific category

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Transportation",
  "description": "Eco-friendly travel options",
  "iconName": "directions_bus"
}
```

---

### 3. Get Activity Types

**Endpoint:** `GET /api/activities/types?categoryId=1`  
**Authentication:** Required  
**Description:** Get activity types, optionally filtered by category

**Query Parameters:**
- `categoryId` (optional): Filter by category ID

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "categoryId": 1,
    "name": "Public Transport",
    "description": "Using bus, train, or metro",
    "basePoints": 10,
    "carbonImpact": -2.5,
    "unit": "km",
    "iconName": "train"
  }
]
```

---

### 4. Get Activity Type by ID

**Endpoint:** `GET /api/activities/types/{id}`  
**Authentication:** Required

**Response (200 OK):**
```json
{
  "id": 1,
  "categoryId": 1,
  "name": "Public Transport",
  "description": "Using bus, train, or metro",
  "basePoints": 10,
  "carbonImpact": -2.5,
  "unit": "km",
  "iconName": "train"
}
```

---

### 5. Get Activities

**Endpoint:** `GET /api/activities/log?startDate=2026-02-01&endDate=2026-02-16`  
**Authentication:** Required  
**Description:** Get user's logged activities

**Query Parameters:**
- `startDate` (optional): Filter from date
- `endDate` (optional): Filter to date

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "userId": "user-guid",
    "activityTypeId": 1,
    "activityTypeName": "Public Transport",
    "quantity": 15.0,
    "unit": "km",
    "pointsEarned": 150,
    "carbonImpact": -37.5,
    "date": "2026-02-16T08:30:00Z",
    "notes": "Commute to work"
  }
]
```

---

### 6. Get Activity by ID

**Endpoint:** `GET /api/activities/log/{id}`  
**Authentication:** Required

**Response (200 OK):**
```json
{
  "id": 1,
  "userId": "user-guid",
  "activityTypeId": 1,
  "activityTypeName": "Public Transport",
  "quantity": 15.0,
  "unit": "km",
  "pointsEarned": 150,
  "carbonImpact": -37.5,
  "date": "2026-02-16T08:30:00Z",
  "notes": "Commute to work"
}
```

---

### 7. Create Activity

**Endpoint:** `POST /api/activities/log`  
**Authentication:** Required  
**Description:** Log a new eco-friendly activity

**Request Body:**
```json
{
  "activityTypeId": 1,
  "quantity": 15.0,
  "date": "2026-02-16T08:30:00Z",
  "notes": "Commute to work"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "userId": "user-guid",
  "activityTypeId": 1,
  "activityTypeName": "Public Transport",
  "quantity": 15.0,
  "unit": "km",
  "pointsEarned": 150,
  "carbonImpact": -37.5,
  "date": "2026-02-16T08:30:00Z",
  "notes": "Commute to work"
}
```

---

### 8. Delete Activity

**Endpoint:** `DELETE /api/activities/log/{id}`  
**Authentication:** Required  
**Description:** Delete a logged activity

**Response (204 No Content)**

**Errors:**
- `404 Not Found` - Activity not found or not owned by user

---

### 9. Get Today's Activities

**Endpoint:** `GET /api/activities/log/today`  
**Authentication:** Required  
**Description:** Get all activities logged today

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "activityTypeName": "Public Transport",
    "quantity": 15.0,
    "pointsEarned": 150,
    "carbonImpact": -37.5,
    ...
  }
]
```

---

### 10. Get Activity Summary

**Endpoint:** `GET /api/activities/log/summary?startDate=2026-02-01&endDate=2026-02-16`  
**Authentication:** Required  
**Description:** Get aggregated activity statistics

**Query Parameters:**
- `startDate` (optional): Default 30 days ago
- `endDate` (optional): Default today

**Response (200 OK):**
```json
{
  "totalActivities": 45,
  "totalPoints": 1250,
  "totalCarbonSaved": 85.5,
  "activitiesByCategory": [
    {
      "categoryName": "Transportation",
      "count": 20,
      "points": 600,
      "carbonSaved": 50.0
    }
  ]
}
```

---

### 11. Get Tips

**Endpoint:** `GET /api/activities/tips?category=Transportation`  
**Authentication:** Required  
**Description:** Get eco-friendly tips

**Query Parameters:**
- `category` (optional): Filter by category name

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "title": "Use Public Transport",
    "content": "Take the bus or train instead of driving...",
    "category": "Transportation",
    "iconName": "lightbulb"
  }
]
```

---

### 12. Get Tip by ID

**Endpoint:** `GET /api/activities/tips/{id}`  
**Authentication:** Required

**Response (200 OK):**
```json
{
  "id": 1,
  "title": "Use Public Transport",
  "content": "Take the bus or train instead of driving...",
  "category": "Transportation",
  "iconName": "lightbulb"
}
```

---

### 13. Get Daily Tip

**Endpoint:** `GET /api/activities/tips/daily`  
**Authentication:** Required  
**Description:** Get a random daily eco tip

**Response (200 OK):**
```json
{
  "id": 5,
  "title": "Save Water",
  "content": "Turn off the tap while brushing teeth...",
  "category": "Water Conservation",
  "iconName": "water_drop"
}
```

---

## 🏆 Achievements Controller

### 1. Get Badges

**Endpoint:** `GET /api/achievements/badges`  
**Authentication:** Required  
**Description:** Get all available badges

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "First Steps",
    "description": "Log your first eco-activity",
    "iconName": "star",
    "requirement": "Log 1 activity",
    "pointsRequired": 0,
    "rarity": "Common"
  }
]
```

---

### 2. Get Badge by ID

**Endpoint:** `GET /api/achievements/badges/{id}`  
**Authentication:** Required

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "First Steps",
  "description": "Log your first eco-activity",
  "iconName": "star",
  "requirement": "Log 1 activity",
  "pointsRequired": 0,
  "rarity": "Common"
}
```

---

### 3. Get My Badges

**Endpoint:** `GET /api/achievements/my-badges`  
**Authentication:** Required  
**Description:** Get user's earned badges

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "badgeId": 1,
    "badgeName": "First Steps",
    "description": "Log your first eco-activity",
    "earnedDate": "2026-01-16T10:30:00Z",
    "iconName": "star",
    "rarity": "Common"
  }
]
```

---

### 4. Get My Badge by ID

**Endpoint:** `GET /api/achievements/my-badges/{id}`  
**Authentication:** Required

**Response (200 OK):**
```json
{
  "id": 1,
  "badgeId": 1,
  "badgeName": "First Steps",
  "earnedDate": "2026-01-16T10:30:00Z",
  ...
}
```

---

### 5. Get My Badges Summary

**Endpoint:** `GET /api/achievements/my-badges/summary`  
**Authentication:** Required  
**Description:** Get badge statistics

**Response (200 OK):**
```json
{
  "totalBadges": 15,
  "earnedBadges": 7,
  "commonBadges": 4,
  "rareBadges": 2,
  "epicBadges": 1,
  "legendaryBadges": 0,
  "completionPercentage": 46.67
}
```

---

### 6. Get Challenges

**Endpoint:** `GET /api/achievements/challenges`  
**Authentication:** Required  
**Description:** Get all available challenges

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Week of Green",
    "description": "Log eco-activities for 7 consecutive days",
    "startDate": "2026-02-01T00:00:00Z",
    "endDate": "2026-02-28T23:59:59Z",
    "targetValue": 7,
    "pointReward": 100,
    "badgeReward": "Week Warrior",
    "isActive": true,
    "participantCount": 245
  }
]
```

---

### 7. Get Challenge by ID

**Endpoint:** `GET /api/achievements/challenges/{id}`  
**Authentication:** Required

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Week of Green",
  "description": "Log eco-activities for 7 consecutive days",
  "startDate": "2026-02-01T00:00:00Z",
  "endDate": "2026-02-28T23:59:59Z",
  "targetValue": 7,
  "pointReward": 100,
  "badgeReward": "Week Warrior",
  "isActive": true,
  "participantCount": 245
}
```

---

### 8. Get Active Challenges

**Endpoint:** `GET /api/achievements/challenges/active`  
**Authentication:** Required  
**Description:** Get currently active challenges

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Week of Green",
    "endDate": "2026-02-28T23:59:59Z",
    ...
  }
]
```

---

### 9. Get My Challenges

**Endpoint:** `GET /api/achievements/my-challenges`  
**Authentication:** Required  
**Description:** Get user's joined challenges

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "challengeId": 1,
    "challengeName": "Week of Green",
    "currentValue": 4,
    "targetValue": 7,
    "progress": 57.14,
    "isCompleted": false,
    "joinedDate": "2026-02-01T10:00:00Z"
  }
]
```

---

### 10. Get My Challenge by ID

**Endpoint:** `GET /api/achievements/my-challenges/{id}`  
**Authentication:** Required

**Response (200 OK):**
```json
{
  "id": 1,
  "challengeId": 1,
  "challengeName": "Week of Green",
  "currentValue": 4,
  "targetValue": 7,
  "progress": 57.14,
  "isCompleted": false,
  "joinedDate": "2026-02-01T10:00:00Z"
}
```

---

### 11. Get My Active Challenges

**Endpoint:** `GET /api/achievements/my-challenges/active`  
**Authentication:** Required  
**Description:** Get user's active (incomplete) challenges

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "challengeName": "Week of Green",
    "progress": 57.14,
    ...
  }
]
```

---

### 12. Get Completed Challenges

**Endpoint:** `GET /api/achievements/my-challenges/completed`  
**Authentication:** Required  
**Description:** Get user's completed challenges

**Response (200 OK):**
```json
[
  {
    "id": 2,
    "challengeName": "Carbon Saver",
    "completedDate": "2026-01-25T18:30:00Z",
    "pointsAwarded": 150
  }
]
```

---

### 13. Join Challenge

**Endpoint:** `POST /api/achievements/challenges/{id}/join`  
**Authentication:** Required  
**Description:** Join a challenge

**Response (200 OK):**
```json
{
  "id": 1,
  "challengeId": 1,
  "challengeName": "Week of Green",
  "currentValue": 0,
  "targetValue": 7,
  "progress": 0.0,
  "isCompleted": false,
  "joinedDate": "2026-02-16T14:00:00Z"
}
```

**Errors:**
- `400 Bad Request` - Already joined or challenge inactive

---

### 14. Update My Challenge

**Endpoint:** `PUT /api/achievements/my-challenges/{id}`  
**Authentication:** Required  
**Description:** Update challenge progress (admin/system use)

**Request Body:**
```json
{
  "currentValue": 5,
  "isCompleted": false
}
```

---

### 15. Partial Update My Challenge

**Endpoint:** `PATCH /api/achievements/my-challenges/{id}`  
**Authentication:** Required  
**Description:** Partially update challenge (increment progress)

**Request Body:**
```json
{
  "incrementValue": 1
}
```

---

### 16. Leave Challenge

**Endpoint:** `DELETE /api/achievements/my-challenges/{id}`  
**Authentication:** Required  
**Description:** Leave a challenge

**Response (204 No Content)**

---

### 17. Get Summary

**Endpoint:** `GET /api/achievements/summary`  
**Authentication:** Required  
**Description:** Get overall achievements summary

**Response (200 OK):**
```json
{
  "totalBadges": 7,
  "totalChallengesCompleted": 3,
  "activeChallenges": 2,
  "totalPointsFromAchievements": 450,
  "nextMilestone": "Earn 10 badges"
}
```

---

## 📊 Analytics Controller

### 1. Get Weekly Report

**Endpoint:** `GET /api/analytics/weekly`  
**Authentication:** Required  
**Description:** Get weekly activity report

**Response (200 OK):**
```json
{
  "weekStart": "2026-02-10",
  "weekEnd": "2026-02-16",
  "totalActivities": 23,
  "totalPoints": 450,
  "totalCarbonSaved": 32.5,
  "dailyBreakdown": [
    {
      "date": "2026-02-10",
      "activities": 3,
      "points": 60,
      "carbonSaved": 4.5
    }
  ],
  "topCategory": "Transportation"
}
```

---

### 2. Get Monthly Report

**Endpoint:** `GET /api/analytics/monthly?year=2026&month=2`  
**Authentication:** Required  
**Description:** Get monthly activity report

**Query Parameters:**
- `year` (optional): Default current year
- `month` (optional): 1-12, default current month

**Response (200 OK):**
```json
{
  "month": 2,
  "year": 2026,
  "totalActivities": 87,
  "totalPoints": 1540,
  "totalCarbonSaved": 98.7,
  "weeklyBreakdown": [ ... ],
  "topCategories": [
    {
      "category": "Transportation",
      "count": 35,
      "percentage": 40.2
    }
  ]
}
```

---

### 3. Get Dashboard

**Endpoint:** `GET /api/analytics/dashboard`  
**Authentication:** Required  
**Description:** Get analytics dashboard data

**Response (200 OK):**
```json
{
  "today": {
    "activities": 4,
    "points": 85,
    "carbonSaved": 6.2
  },
  "thisWeek": {
    "activities": 23,
    "points": 450,
    "carbonSaved": 32.5
  },
  "thisMonth": {
    "activities": 87,
    "points": 1540,
    "carbonSaved": 98.7
  },
  "allTime": {
    "activities": 245,
    "points": 4320,
    "carbonSaved": 287.4
  },
  "recentActivities": [ ... ]
}
```

---

### 4. Get Stats

**Endpoint:** `GET /api/analytics/stats?period=week`  
**Authentication:** Required  
**Description:** Get statistics for a period

**Query Parameters:**
- `period`: `week`, `month`, `year`, `all` (default: `week`)

**Response (200 OK):**
```json
{
  "period": "week",
  "totalActivities": 23,
  "totalPoints": 450,
  "totalCarbonSaved": 32.5,
  "averagePerDay": 3.3,
  "mostActiveDay": "2026-02-15",
  "categoryDistribution": [ ... ]
}
```

---

### 5. Get Comparison

**Endpoint:** `GET /api/analytics/comparison`  
**Authentication:** Required  
**Description:** Compare current week vs previous week

**Response (200 OK):**
```json
{
  "currentWeek": {
    "activities": 23,
    "points": 450,
    "carbonSaved": 32.5
  },
  "previousWeek": {
    "activities": 18,
    "points": 380,
    "carbonSaved": 25.8
  },
  "changes": {
    "activitiesChange": 27.8,
    "pointsChange": 18.4,
    "carbonChange": 26.0
  }
}
```

---

### 6. Export to CSV

**Endpoint:** `GET /api/analytics/export/csv?startDate=2026-01-01&endDate=2026-02-16`  
**Authentication:** Required  
**Description:** Export activity data to CSV

**Query Parameters:**
- `startDate` (optional): Default 30 days ago
- `endDate` (optional): Default today

**Response (200 OK):**
- Content-Type: `text/csv`
- Content-Disposition: `attachment; filename="activities-{userId}.csv"`

**CSV Format:**
```csv
Date,Activity Type,Category,Quantity,Unit,Points,Carbon Impact,Notes
2026-02-16,Public Transport,Transportation,15.0,km,150,-37.5,Commute to work
```

---

## 🚗 Travel Controller

### 1. Get Trips

**Endpoint:** `GET /api/travel/trips?startDate=2026-02-01&endDate=2026-02-16`  
**Authentication:** Required  
**Description:** Get user's trips

**Query Parameters:**
- `startDate` (optional)
- `endDate` (optional)

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "userId": "user-guid",
    "startTime": "2026-02-16T08:00:00Z",
    "endTime": "2026-02-16T08:30:00Z",
    "distance": 15.5,
    "transportMode": "PublicTransport",
    "carbonFootprint": -37.5,
    "pointsEarned": 155,
    "notes": "Morning commute"
  }
]
```

---

### 2. Get Today's Trips

**Endpoint:** `GET /api/travel/trips/today`  
**Authentication:** Required  
**Description:** Get trips logged today

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "transportMode": "PublicTransport",
    "distance": 15.5,
    "carbonFootprint": -37.5,
    ...
  }
]
```

---

### 3. Get Trip by ID

**Endpoint:** `GET /api/travel/trips/{id}`  
**Authentication:** Required

**Response (200 OK):**
```json
{
  "id": 1,
  "userId": "user-guid",
  "startTime": "2026-02-16T08:00:00Z",
  "endTime": "2026-02-16T08:30:00Z",
  "distance": 15.5,
  "transportMode": "PublicTransport",
  "carbonFootprint": -37.5,
  "pointsEarned": 155,
  "notes": "Morning commute",
  "locationPoints": [
    {
      "latitude": 40.7128,
      "longitude": -74.0060,
      "timestamp": "2026-02-16T08:00:00Z"
    }
  ]
}
```

---

### 4. Get Trip Stats

**Endpoint:** `GET /api/travel/trips/{id}/stats`  
**Authentication:** Required  
**Description:** Get detailed statistics for a trip

**Response (200 OK):**
```json
{
  "tripId": 1,
  "duration": "00:30:00",
  "averageSpeed": 31.0,
  "totalDistance": 15.5,
  "carbonSaved": 37.5,
  "equivalentTrees": 1.8
}
```

---

### 5. Create Trip

**Endpoint:** `POST /api/travel/trips`  
**Authentication:** Required  
**Description:** Log a new trip

**Request Body:**
```json
{
  "startTime": "2026-02-16T08:00:00Z",
  "endTime": "2026-02-16T08:30:00Z",
  "distance": 15.5,
  "transportMode": "PublicTransport",
  "notes": "Morning commute"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "userId": "user-guid",
  "startTime": "2026-02-16T08:00:00Z",
  "endTime": "2026-02-16T08:30:00Z",
  "distance": 15.5,
  "transportMode": "PublicTransport",
  "carbonFootprint": -37.5,
  "pointsEarned": 155,
  "notes": "Morning commute"
}
```

---

### 6. Update Trip

**Endpoint:** `PUT /api/travel/trips/{id}`  
**Authentication:** Required  
**Description:** Update trip details

**Request Body:**
```json
{
  "startTime": "2026-02-16T08:00:00Z",
  "endTime": "2026-02-16T08:35:00Z",
  "distance": 16.0,
  "transportMode": "PublicTransport",
  "notes": "Morning commute - updated"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "distance": 16.0,
  ...
}
```

---

### 7. Delete Trip

**Endpoint:** `DELETE /api/travel/trips/{id}`  
**Authentication:** Required  
**Description:** Delete a trip

**Response (204 No Content)**

---

### 8. Partial Update Trip

**Endpoint:** `PATCH /api/travel/trips/{id}`  
**Authentication:** Required  
**Description:** Partially update trip (e.g., add notes)

**Request Body:**
```json
{
  "notes": "Added extra stop"
}
```

---

### 9-14. Location Points Management

#### Get Location Points
**Endpoint:** `GET /api/travel/trips/{tripId}/location-points`  
**Authentication:** Required

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "tripId": 1,
    "latitude": 40.7128,
    "longitude": -74.0060,
    "timestamp": "2026-02-16T08:00:00Z",
    "accuracy": 10.5
  }
]
```

#### Get Location Point by ID
**Endpoint:** `GET /api/travel/location-points/{id}`  
**Authentication:** Required

#### Create Location Point
**Endpoint:** `POST /api/travel/location-points`  
**Authentication:** Required

**Request Body:**
```json
{
  "tripId": 1,
  "latitude": 40.7128,
  "longitude": -74.0060,
  "timestamp": "2026-02-16T08:00:00Z",
  "accuracy": 10.5
}
```

#### Update Location Point
**Endpoint:** `PUT /api/travel/location-points/{id}`  
**Authentication:** Required

#### Delete Location Point
**Endpoint:** `DELETE /api/travel/location-points/{id}`  
**Authentication:** Required

#### Batch Upload Locations
**Endpoint:** `POST /api/travel/location-points/batch`  
**Authentication:** Required  
**Description:** Upload multiple location points at once

**Request Body:**
```json
[
  {
    "tripId": 1,
    "latitude": 40.7128,
    "longitude": -74.0060,
    "timestamp": "2026-02-16T08:00:00Z"
  },
  {
    "tripId": 1,
    "latitude": 40.7200,
    "longitude": -74.0100,
    "timestamp": "2026-02-16T08:05:00Z"
  }
]
```

**Response (201 Created):**
```json
{
  "created": 2,
  "locationPoints": [ ... ]
}
```

---

### 15. Get Travel Summary

**Endpoint:** `GET /api/travel/summary?startDate=2026-02-01&endDate=2026-02-16`  
**Authentication:** Required  
**Description:** Get aggregated travel statistics

**Response (200 OK):**
```json
{
  "totalTrips": 45,
  "totalDistance": 687.5,
  "totalCarbonSaved": 1234.8,
  "totalPoints": 3250,
  "transportModeBreakdown": [
    {
      "mode": "PublicTransport",
      "trips": 30,
      "distance": 450.0,
      "percentage": 65.5
    }
  ]
}
```

---

### 16. Get Weekly Summary

**Endpoint:** `GET /api/travel/summary/weekly`  
**Authentication:** Required  
**Description:** Get current week's travel summary

**Response (200 OK):**
```json
{
  "weekStart": "2026-02-10",
  "weekEnd": "2026-02-16",
  "totalTrips": 12,
  "totalDistance": 145.6,
  "totalCarbonSaved": 267.8,
  "dailyBreakdown": [ ... ]
}
```

---

### 17. Update Steps

**Endpoint:** `PUT /api/travel/summary/steps`  
**Authentication:** Required  
**Description:** Update daily steps count

**Request Body:**
```json
{
  "date": "2026-02-16",
  "steps": 8542
}
```

**Response (200 OK):**
```json
{
  "date": "2026-02-16",
  "steps": 8542,
  "pointsEarned": 42
}
```

---

### 18. Get Summary by ID

**Endpoint:** `GET /api/travel/summary/{id}`  
**Authentication:** Required

**Response (200 OK):**
```json
{
  "id": 1,
  "userId": "user-guid",
  "date": "2026-02-16",
  "totalTrips": 3,
  "totalDistance": 45.2,
  "steps": 8542
}
```

---

### 19. Partial Update Summary

**Endpoint:** `PATCH /api/travel/summary/{id}`  
**Authentication:** Required  
**Description:** Partially update travel summary

**Request Body:**
```json
{
  "steps": 10000
}
```

---

## 🤖 Predictions Controller

### 1. Get Eco Profile

**Endpoint:** `GET /api/predictions/profile`  
**Authentication:** Required  
**Description:** Get user's eco profile for ML predictions

**Response (200 OK):**
```json
{
  "id": 1,
  "userId": "user-guid",
  "avgDailyActivities": 3.5,
  "avgCarbonSaved": 4.8,
  "preferredTransportMode": "PublicTransport",
  "activityPatterns": "Morning commuter",
  "lastUpdated": "2026-02-16T14:00:00Z"
}
```

---

### 2. Create/Update Eco Profile

**Endpoint:** `POST /api/predictions/profile`  
**Authentication:** Required  
**Description:** Create or update eco profile

**Request Body:**
```json
{
  "avgDailyActivities": 3.5,
  "avgCarbonSaved": 4.8,
  "preferredTransportMode": "PublicTransport",
  "activityPatterns": "Morning commuter"
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "userId": "user-guid",
  "avgDailyActivities": 3.5,
  "avgCarbonSaved": 4.8,
  "preferredTransportMode": "PublicTransport",
  "activityPatterns": "Morning commuter",
  "lastUpdated": "2026-02-16T14:30:00Z"
}
```

---

### 3. Get Daily Logs

**Endpoint:** `GET /api/predictions/logs?startDate=2026-02-01&endDate=2026-02-16`  
**Authentication:** Required  
**Description:** Get daily logs for ML analysis

**Query Parameters:**
- `startDate` (optional)
- `endDate` (optional)

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "userId": "user-guid",
    "date": "2026-02-16",
    "activities": 4,
    "carbonSaved": 6.2,
    "points": 85,
    "transportMode": "PublicTransport"
  }
]
```

---

### 4-16. ML Prediction Endpoints (Stubs)

**Note:** The following endpoints are currently stubs returning mock data. Full ML implementation is planned.

#### Predict Carbon Footprint
**Endpoint:** `POST /api/predictions/predict-carbon`  
**Authentication:** Required  
**Description:** Predict carbon footprint for planned activity

**Request Body:**
```json
{
  "activityType": "PublicTransport",
  "quantity": 15.0,
  "duration": 30
}
```

**Response (200 OK):**
```json
{
  "predictedCarbon": -37.5,
  "confidence": 0.85,
  "factors": [
    "Transport mode",
    "Distance",
    "Peak hours"
  ]
}
```

#### Predict Eco Score
**Endpoint:** `POST /api/predictions/predict-score`  
**Authentication:** Required  
**Description:** Predict future eco score

**Request Body:**
```json
{
  "daysAhead": 7,
  "plannedActivities": [
    {
      "activityType": "PublicTransport",
      "quantity": 15.0
    }
  ]
}
```

**Response (200 OK):**
```json
{
  "currentScore": 85,
  "predictedScore": 92,
  "improvement": 8.2,
  "confidence": 0.78
}
```

#### Get Recommendations
**Endpoint:** `GET /api/predictions/recommendations`  
**Authentication:** Required  
**Description:** Get personalized eco recommendations

**Response (200 OK):**
```json
[
  {
    "title": "Try biking to work",
    "description": "Based on your commute distance...",
    "potentialCarbonSaving": 12.5,
    "potentialPoints": 250,
    "priority": "High"
  }
]
```

#### Other ML Stubs
- `POST /api/predictions/predict-trend` - Predict activity trends
- `POST /api/predictions/suggest-goals` - Suggest personalized goals
- `GET /api/predictions/carbon-forecast` - Weekly carbon forecast
- `GET /api/predictions/activity-insights` - Activity pattern insights
- `POST /api/predictions/optimal-route` - Optimal eco-friendly route
- `GET /api/predictions/peer-comparison` - Compare with similar users
- `POST /api/predictions/challenge-suggestions` - Suggest challenges
- `GET /api/predictions/achievement-forecast` - Predict next badges
- `POST /api/predictions/carbon-offset-suggestions` - Suggest offset actions

---

## 🔔 Notifications Controller

### 1. Send Push Notification

**Endpoint:** `POST /api/notifications/send`  
**Authentication:** Required (Admin)  
**Description:** Send push notification to users

**Request Body:**
```json
{
  "userId": "user-guid",
  "title": "New Badge Earned!",
  "body": "You've earned the 'Eco Warrior' badge",
  "data": {
    "type": "badge",
    "badgeId": "5"
  }
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "messageId": "fcm-message-id",
  "recipients": 1
}
```

---

### 2. Register Device Token

**Endpoint:** `POST /api/notifications/register-token`  
**Authentication:** Required  
**Description:** Register FCM device token

**Request Body:**
```json
{
  "deviceToken": "fcm-device-token-string",
  "platform": "Android"
}
```

**Response (200 OK):**
```json
{
  "message": "Token registered successfully"
}
```

---

### 3. Unregister Device Token

**Endpoint:** `DELETE /api/notifications/unregister-token`  
**Authentication:** Required  
**Description:** Remove device token

**Request Body:**
```json
{
  "deviceToken": "fcm-device-token-string"
}
```

**Response (200 OK):**
```json
{
  "message": "Token unregistered successfully"
}
```

---

### 4. Get My Notifications

**Endpoint:** `GET /api/notifications`  
**Authentication:** Required  
**Description:** Get notification history

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "userId": "user-guid",
    "title": "New Badge Earned!",
    "body": "You've earned the 'Eco Warrior' badge",
    "type": "badge",
    "isRead": false,
    "createdAt": "2026-02-16T14:00:00Z"
  }
]
```

---

### 5. Mark as Read

**Endpoint:** `PUT /api/notifications/{id}/read`  
**Authentication:** Required  
**Description:** Mark notification as read

**Response (200 OK):**
```json
{
  "message": "Notification marked as read"
}
```

---

### 6. Delete Notification

**Endpoint:** `DELETE /api/notifications/{id}`  
**Authentication:** Required  
**Description:** Delete notification

**Response (204 No Content)**

---

### 7. Get Unread Count

**Endpoint:** `GET /api/notifications/unread-count`  
**Authentication:** Required  
**Description:** Get count of unread notifications

**Response (200 OK):**
```json
{
  "count": 5
}
```

---

## ❌ Error Responses

All endpoints return standard HTTP status codes and error responses:

### 400 Bad Request
```json
{
  "type": "ValidationError",
  "title": "One or more validation errors occurred",
  "status": 400,
  "errors": {
    "Username": ["Username must be at least 3 characters"],
    "Password": ["Password must contain at least one uppercase letter"]
  }
}
```

### 401 Unauthorized
```json
{
  "error": "Unauthorized",
  "message": "Invalid or expired token"
}
```

### 403 Forbidden
```json
{
  "error": "Forbidden",
  "message": "You do not have permission to access this resource"
}
```

### 404 Not Found
```json
{
  "error": "NotFound",
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "InternalServerError",
  "message": "An unexpected error occurred"
}
```

---

## 📋 Common Patterns

### Pagination
Many list endpoints support pagination (future enhancement):
```
GET /api/activities/log?page=1&pageSize=20
```

### Filtering by Date
Date filters use ISO 8601 format:
```
GET /api/activities/log?startDate=2026-02-01T00:00:00Z&endDate=2026-02-16T23:59:59Z
```

### Sorting
Some endpoints support sorting (future enhancement):
```
GET /api/users/leaderboard?sortBy=points&order=desc
```

---

## 🔍 Testing Endpoints

Use the following tools to test the API:

1. **Swagger UI:** `http://localhost:5145/swagger` (development only)
2. **Postman Collection:** Available in `/docs/postman/`
3. **curl Examples:**

```bash
# Register
curl -X POST http://localhost:5145/api/users/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@test.com","password":"Test123!","confirmPassword":"Test123!"}'

# Login
curl -X POST http://localhost:5145/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"Test123!"}'

# Get Profile (with token)
curl -X GET http://localhost:5145/api/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📞 Support

For API questions or issues:
- Review this documentation
- Check integration tests in `EcoBackend.Tests/Integration/`
- Create an issue on GitHub
- Contact: support@ecodailyscore.com

---

**Last Updated:** February 16, 2026  
**API Version:** 1.0.0  
**Total Endpoints:** 126
