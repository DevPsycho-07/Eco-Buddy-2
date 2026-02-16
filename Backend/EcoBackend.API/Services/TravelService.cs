using EcoBackend.Core.Entities;
using EcoBackend.Infrastructure.Data;
using EcoBackend.API.DTOs;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace EcoBackend.API.Services;

public class TravelService
{
    private readonly EcoDbContext _context;

    public TravelService(EcoDbContext context)
    {
        _context = context;
    }

    // ========== Trips ==========

    public async Task<List<TripDto>> GetTripsAsync(int userId, DateTime? startDate, DateTime? endDate, string? mode)
    {
        var query = _context.Trips.Where(t => t.UserId == userId);

        if (startDate.HasValue)
            query = query.Where(t => t.TripDate >= startDate.Value.Date);
        if (endDate.HasValue)
            query = query.Where(t => t.TripDate <= endDate.Value.Date);
        if (!string.IsNullOrEmpty(mode))
            query = query.Where(t => t.TransportMode == mode);

        var trips = await query.OrderByDescending(t => t.TripDate).ThenByDescending(t => t.StartTime).ToListAsync();

        return trips.Select(MapToTripDto).ToList();
    }

    public async Task<List<TripDto>> GetTodaysTripsAsync(int userId)
    {
        var today = DateTime.UtcNow.Date;

        var trips = await _context.Trips
            .Where(t => t.UserId == userId && t.TripDate == today)
            .OrderByDescending(t => t.StartTime)
            .ToListAsync();

        return trips.Select(MapToTripDto).ToList();
    }

    public async Task<TripDto?> GetTripByIdAsync(int id, int userId)
    {
        var trip = await _context.Trips
            .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);

        if (trip == null) return null;

        return MapToTripDto(trip);
    }

    public async Task<TripStatsDto> GetTripStatsAsync(int userId, int days)
    {
        var endDate = DateTime.UtcNow.Date;
        var startDate = endDate.AddDays(-days);

        var trips = await _context.Trips
            .Where(t => t.UserId == userId && t.TripDate >= startDate && t.TripDate <= endDate)
            .ToListAsync();

        var byMode = trips
            .GroupBy(t => t.TransportMode)
            .ToDictionary(
                g => g.Key,
                g => new ModeStatsDto
                {
                    DistanceKm = Math.Round(g.Sum(t => t.DistanceKm), 2),
                    Trips = g.Count(),
                    CO2Emitted = Math.Round(g.Sum(t => t.CO2Emitted), 2)
                });

        return new TripStatsDto
        {
            Period = $"{days} days",
            StartDate = startDate,
            EndDate = endDate,
            TotalDistance = Math.Round(trips.Sum(t => t.DistanceKm), 2),
            TotalTrips = trips.Count,
            TotalCO2Emitted = Math.Round(trips.Sum(t => t.CO2Emitted), 2),
            TotalCO2Saved = Math.Round(trips.Sum(t => t.CO2Saved), 2),
            ByMode = byMode
        };
    }

    public async Task<TripDto> CreateTripAsync(int userId, CreateTripDto dto)
    {
        var co2Rate = Trip.CO2PerKm.GetValueOrDefault(dto.TransportMode.ToLower(), 0.15);
        var co2Emitted = dto.DistanceKm * co2Rate;

        var carEmission = dto.DistanceKm * Trip.CO2PerKm["car"];
        var co2Saved = Math.Max(0, carEmission - co2Emitted);

        var trip = new Trip
        {
            UserId = userId,
            TransportMode = dto.TransportMode.ToLower(),
            DistanceKm = dto.DistanceKm,
            DurationMinutes = dto.DurationMinutes,
            StartLatitude = dto.StartLatitude,
            StartLongitude = dto.StartLongitude,
            StartLocation = dto.StartLocation,
            EndLatitude = dto.EndLatitude,
            EndLongitude = dto.EndLongitude,
            EndLocation = dto.EndLocation,
            CO2Emitted = co2Emitted,
            CO2Saved = co2Saved,
            TripDate = dto.TripDate.Date,
            StartTime = dto.StartTime,
            EndTime = dto.EndTime,
            IsAutoDetected = dto.IsAutoDetected,
            ConfidenceScore = dto.ConfidenceScore,
            CreatedAt = DateTime.UtcNow
        };

        _context.Trips.Add(trip);
        await _context.SaveChangesAsync();

        return MapToTripDto(trip);
    }

    public async Task<TripDto?> UpdateTripAsync(int id, int userId, UpdateTripDto dto)
    {
        var trip = await _context.Trips.FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);

        if (trip == null) return null;

        if (dto.TransportMode != null) trip.TransportMode = dto.TransportMode.ToLower();
        if (dto.DistanceKm.HasValue) trip.DistanceKm = dto.DistanceKm.Value;
        if (dto.DurationMinutes.HasValue) trip.DurationMinutes = dto.DurationMinutes;
        if (dto.StartLatitude.HasValue) trip.StartLatitude = dto.StartLatitude;
        if (dto.StartLongitude.HasValue) trip.StartLongitude = dto.StartLongitude;
        if (dto.StartLocation != null) trip.StartLocation = dto.StartLocation;
        if (dto.EndLatitude.HasValue) trip.EndLatitude = dto.EndLatitude;
        if (dto.EndLongitude.HasValue) trip.EndLongitude = dto.EndLongitude;
        if (dto.EndLocation != null) trip.EndLocation = dto.EndLocation;
        if (dto.TripDate.HasValue) trip.TripDate = dto.TripDate.Value.Date;
        if (dto.StartTime.HasValue) trip.StartTime = dto.StartTime;
        if (dto.EndTime.HasValue) trip.EndTime = dto.EndTime;
        if (dto.ConfidenceScore.HasValue) trip.ConfidenceScore = dto.ConfidenceScore.Value;

        if (dto.TransportMode != null || dto.DistanceKm.HasValue)
        {
            var co2Rate = Trip.CO2PerKm.GetValueOrDefault(trip.TransportMode, 0.15);
            trip.CO2Emitted = trip.DistanceKm * co2Rate;

            var carEmission = trip.DistanceKm * Trip.CO2PerKm["car"];
            trip.CO2Saved = Math.Max(0, carEmission - trip.CO2Emitted);
        }

        await _context.SaveChangesAsync();

        return MapToTripDto(trip);
    }

    public async Task<bool> DeleteTripAsync(int id, int userId)
    {
        var trip = await _context.Trips.FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);

        if (trip == null) return false;

        _context.Trips.Remove(trip);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<TripDto?> PartialUpdateTripAsync(int id, int userId, JsonElement updates)
    {
        var trip = await _context.Trips.FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
        if (trip == null) return null;

        if (updates.TryGetProperty("transport_mode", out var modeElement))
            trip.TransportMode = modeElement.GetString() ?? trip.TransportMode;
        if (updates.TryGetProperty("start_location", out var startLocElement))
            trip.StartLocation = startLocElement.GetString() ?? trip.StartLocation;
        if (updates.TryGetProperty("end_location", out var endLocElement))
            trip.EndLocation = endLocElement.GetString() ?? trip.EndLocation;
        if (updates.TryGetProperty("distance_km", out var distanceElement))
            trip.DistanceKm = distanceElement.GetDouble();
        if (updates.TryGetProperty("duration_minutes", out var durationElement))
            trip.DurationMinutes = durationElement.GetInt32();
        if (updates.TryGetProperty("co2_emitted", out var carbonElement))
            trip.CO2Emitted = carbonElement.GetDouble();

        await _context.SaveChangesAsync();

        return MapToTripDto(trip);
    }

    // ========== Location Points ==========

    public async Task<List<LocationPointDto>> GetLocationPointsAsync(int userId, int? tripId, DateTime? startTime, DateTime? endTime)
    {
        var query = _context.LocationPoints.Where(lp => lp.UserId == userId);

        if (tripId.HasValue)
            query = query.Where(lp => lp.TripId == tripId.Value);
        if (startTime.HasValue)
            query = query.Where(lp => lp.Timestamp >= startTime.Value);
        if (endTime.HasValue)
            query = query.Where(lp => lp.Timestamp <= endTime.Value);

        var points = await query.OrderBy(lp => lp.Timestamp).ToListAsync();

        return points.Select(MapToLocationPointDto).ToList();
    }

    public async Task<LocationPointDto?> GetLocationPointByIdAsync(int id, int userId)
    {
        var locationPoint = await _context.LocationPoints
            .FirstOrDefaultAsync(lp => lp.Id == id && lp.UserId == userId);

        if (locationPoint == null) return null;

        return MapToLocationPointDto(locationPoint);
    }

    public async Task<LocationPointDto> CreateLocationPointAsync(int userId, CreateLocationPointDto dto)
    {
        var locationPoint = new LocationPoint
        {
            UserId = userId,
            Latitude = dto.Latitude,
            Longitude = dto.Longitude,
            Altitude = dto.Altitude,
            Accuracy = dto.Accuracy,
            Speed = dto.Speed,
            Timestamp = dto.Timestamp,
            DetectedActivity = dto.DetectedActivity,
            ActivityConfidence = dto.ActivityConfidence
        };

        _context.LocationPoints.Add(locationPoint);
        await _context.SaveChangesAsync();

        return MapToLocationPointDto(locationPoint);
    }

    public async Task<LocationPointDto?> UpdateLocationPointAsync(int id, int userId, CreateLocationPointDto dto)
    {
        var locationPoint = await _context.LocationPoints
            .FirstOrDefaultAsync(lp => lp.Id == id && lp.UserId == userId);

        if (locationPoint == null) return null;

        locationPoint.Latitude = dto.Latitude;
        locationPoint.Longitude = dto.Longitude;
        locationPoint.Altitude = dto.Altitude;
        locationPoint.Accuracy = dto.Accuracy;
        locationPoint.Speed = dto.Speed;
        locationPoint.Timestamp = dto.Timestamp;
        locationPoint.DetectedActivity = dto.DetectedActivity;
        locationPoint.ActivityConfidence = dto.ActivityConfidence;

        await _context.SaveChangesAsync();

        return MapToLocationPointDto(locationPoint);
    }

    public async Task<bool> DeleteLocationPointAsync(int id, int userId)
    {
        var locationPoint = await _context.LocationPoints
            .FirstOrDefaultAsync(lp => lp.Id == id && lp.UserId == userId);

        if (locationPoint == null) return false;

        _context.LocationPoints.Remove(locationPoint);
        await _context.SaveChangesAsync();
        return true;
    }

    public async Task<(int Count, List<LocationPointDto> Points)> BatchUploadLocationsAsync(int userId, BatchLocationPointsDto dto)
    {
        var locationPoints = new List<LocationPoint>();

        foreach (var pointDto in dto.Points)
        {
            var locationPoint = new LocationPoint
            {
                UserId = userId,
                Latitude = pointDto.Latitude,
                Longitude = pointDto.Longitude,
                Altitude = pointDto.Altitude,
                Accuracy = pointDto.Accuracy,
                Speed = pointDto.Speed,
                Timestamp = pointDto.Timestamp,
                DetectedActivity = pointDto.DetectedActivity,
                ActivityConfidence = pointDto.ActivityConfidence
            };
            locationPoints.Add(locationPoint);
        }

        _context.LocationPoints.AddRange(locationPoints);
        await _context.SaveChangesAsync();

        var createdDtos = locationPoints.Select(MapToLocationPointDto).ToList();

        return (createdDtos.Count, createdDtos);
    }

    // ========== Travel Summary ==========

    public async Task<TravelSummaryDto?> GetTravelSummaryAsync(int userId, DateTime? date)
    {
        var targetDate = (date ?? DateTime.UtcNow).Date;

        var summary = await _context.TravelSummaries
            .FirstOrDefaultAsync(ts => ts.UserId == userId && ts.Date == targetDate);

        if (summary == null) return null;

        return MapToTravelSummaryDto(summary);
    }

    public async Task<List<TravelSummaryDto>> GetWeeklySummaryAsync(int userId)
    {
        var endDate = DateTime.UtcNow.Date;
        var startDate = endDate.AddDays(-7);

        var summaries = await _context.TravelSummaries
            .Where(ts => ts.UserId == userId && ts.Date >= startDate && ts.Date <= endDate)
            .OrderByDescending(ts => ts.Date)
            .ToListAsync();

        return summaries.Select(MapToTravelSummaryDto).ToList();
    }

    public async Task<object> UpdateStepsAsync(int userId, UpdateStepsDto dto)
    {
        var targetDate = dto.Date.Date;

        var summary = await _context.TravelSummaries
            .FirstOrDefaultAsync(ts => ts.UserId == userId && ts.Date == targetDate);

        if (summary == null)
        {
            summary = new TravelSummary
            {
                UserId = userId,
                Date = targetDate,
                Steps = dto.Steps
            };
            _context.TravelSummaries.Add(summary);
        }
        else
        {
            summary.Steps = dto.Steps;
        }

        await _context.SaveChangesAsync();

        return new { date = summary.Date, steps = summary.Steps };
    }

    public async Task<object?> GetSummaryByIdAsync(int id, int userId)
    {
        var summary = await _context.TravelSummaries
            .FirstOrDefaultAsync(ts => ts.Id == id && ts.UserId == userId);

        if (summary == null) return null;

        return new
        {
            id = summary.Id,
            userId = summary.UserId,
            date = summary.Date,
            totalKm = summary.TotalKm,
            totalTrips = summary.TotalTrips,
            totalCO2Emitted = summary.TotalCO2Emitted,
            totalCO2Saved = summary.TotalCO2Saved,
            walkingKm = summary.WalkingKm,
            cyclingKm = summary.CyclingKm,
            publicTransitKm = summary.PublicTransitKm,
            carKm = summary.CarKm,
            otherKm = summary.OtherKm,
            steps = summary.Steps
        };
    }

    public async Task<object?> PartialUpdateSummaryAsync(int id, int userId, JsonElement updates)
    {
        var summary = await _context.TravelSummaries
            .FirstOrDefaultAsync(ts => ts.Id == id && ts.UserId == userId);

        if (summary == null) return null;

        if (updates.TryGetProperty("total_km", out var distanceElement))
            summary.TotalKm = distanceElement.GetDouble();
        if (updates.TryGetProperty("total_co2_emitted", out var carbonElement))
            summary.TotalCO2Emitted = carbonElement.GetDouble();
        if (updates.TryGetProperty("total_co2_saved", out var savedElement))
            summary.TotalCO2Saved = savedElement.GetDouble();
        if (updates.TryGetProperty("steps", out var stepsElement))
            summary.Steps = stepsElement.GetInt32();

        await _context.SaveChangesAsync();

        return new
        {
            id = summary.Id,
            userId = summary.UserId,
            date = summary.Date,
            totalKm = summary.TotalKm,
            totalTrips = summary.TotalTrips,
            totalCO2Emitted = summary.TotalCO2Emitted,
            totalCO2Saved = summary.TotalCO2Saved,
            walkingKm = summary.WalkingKm,
            cyclingKm = summary.CyclingKm,
            publicTransitKm = summary.PublicTransitKm,
            carKm = summary.CarKm,
            otherKm = summary.OtherKm,
            steps = summary.Steps
        };
    }

    // ========== Private Helpers ==========

    private static TripDto MapToTripDto(Trip trip)
    {
        return new TripDto
        {
            Id = trip.Id,
            TransportMode = trip.TransportMode,
            DistanceKm = trip.DistanceKm,
            DurationMinutes = trip.DurationMinutes,
            StartLatitude = trip.StartLatitude,
            StartLongitude = trip.StartLongitude,
            StartLocation = trip.StartLocation,
            EndLatitude = trip.EndLatitude,
            EndLongitude = trip.EndLongitude,
            EndLocation = trip.EndLocation,
            CO2Emitted = trip.CO2Emitted,
            CO2Saved = trip.CO2Saved,
            TripDate = trip.TripDate,
            StartTime = trip.StartTime,
            EndTime = trip.EndTime,
            IsAutoDetected = trip.IsAutoDetected,
            ConfidenceScore = trip.ConfidenceScore,
            CreatedAt = trip.CreatedAt
        };
    }

    private static LocationPointDto MapToLocationPointDto(LocationPoint lp)
    {
        return new LocationPointDto
        {
            Id = lp.Id,
            TripId = lp.TripId,
            Latitude = lp.Latitude,
            Longitude = lp.Longitude,
            Altitude = lp.Altitude,
            Accuracy = lp.Accuracy,
            Speed = lp.Speed,
            Timestamp = lp.Timestamp,
            DetectedActivity = lp.DetectedActivity,
            ActivityConfidence = lp.ActivityConfidence
        };
    }

    private static TravelSummaryDto MapToTravelSummaryDto(TravelSummary s)
    {
        return new TravelSummaryDto
        {
            Id = s.Id,
            Date = s.Date,
            WalkingKm = s.WalkingKm,
            CyclingKm = s.CyclingKm,
            PublicTransitKm = s.PublicTransitKm,
            CarKm = s.CarKm,
            OtherKm = s.OtherKm,
            TotalKm = s.TotalKm,
            TotalTrips = s.TotalTrips,
            TotalCO2Emitted = s.TotalCO2Emitted,
            TotalCO2Saved = s.TotalCO2Saved,
            Steps = s.Steps
        };
    }
}
