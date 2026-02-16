# EcoBackend Admin Data Seeder

This console application seeds comprehensive dummy data for the admin user (`admin@eco.com`) in the EcoBackend database.

## What Data Gets Seeded

The seeder creates realistic dummy data for the admin user including:

- **Activities**: 30 days of varied eco-friendly activities (walking, cycling, vegan meals, recycling, etc.)
- **Daily Scores**: 30 days of daily eco scores with CO2 metrics and step counts
- **Goals**: 6 different environmental goals with progress tracking
- **Trips**: 20+ trips over 2 weeks using different transport modes
- **Badges**: 8-12 earned badges for various achievements
- **Challenges**: Progress on 5 active challenges
- **User Profile**: Updated stats including total CO2 saved, level, XP, and streaks

## Prerequisites

1. The EcoBackend database must exist (run the API application first)
2. .NET 8.0 SDK installed
3. The admin user (`admin@eco.com`) should be created (automatically done on first API run)

## How to Run

### Option 1: Run from the DataSeeder directory

```bash
cd Backend/EcoBackend.DataSeeder
dotnet run
```

### Option 2: Run from the Backend directory

```bash
cd Backend
dotnet run --project EcoBackend.DataSeeder
```

### Option 3: Build and run executable

```bash
cd Backend/EcoBackend.DataSeeder
dotnet build
cd bin/Debug/net8.0
./EcoBackend.DataSeeder
```

## What Happens During Seeding

1. **Connects to database**: Uses the SQLite database at `../EcoBackend.API/eco.db`
2. **Checks prerequisites**: Ensures database exists and base data is seeded
3. **Removes old data**: Clears existing admin user data to avoid duplicates
4. **Seeds new data**: Creates comprehensive dummy data
5. **Updates profile**: Recalculates user statistics

## Login Credentials

After seeding, you can login with:
- **Email**: `admin@eco.com`
- **Password**: `Admin@123`

## Configuration

The database connection can be configured in `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Data Source=../EcoBackend.API/eco.db"
  }
}
```

## Data Characteristics

- **Realistic patterns**: Activities vary by day and time
- **Consistent history**: 30 days of continuous data
- **Varied activities**: Mix of transport, food, energy, and home activities
- **Progressive goals**: Goals with different completion percentages
- **Achievement milestones**: Multiple earned badges showing progression

## Troubleshooting

### Database not found
```
❌ Cannot connect to database. Please ensure the database exists.
```
**Solution**: Run the EcoBackend.API application first to create the database.

### No activity types found
```
❌ No activity types found. Please ensure the database is properly seeded.
```
**Solution**: The seeder will automatically run the base seeding. If this persists, ensure the API has been run at least once.

### Admin user not found
```
❌ Admin user admin@eco.com not found.
```
**Solution**: Run the EcoBackend.API application first. The admin user is created automatically on first run.

## Notes

- Running the seeder multiple times will **replace** existing admin data
- The seeder uses a fixed random seed (42) for reproducible results
- All timestamps are in UTC
- CO2 calculations follow the same formulas as the main application

## Development

To modify the seeded data, edit:
- `AdminDataSeeder.cs` - Main seeding logic
- Adjust quantities, date ranges, or add new data types as needed
