using System.Net;
using System.Net.Http.Json;
using Xunit;
using EcoBackend.Tests.Fixtures;

namespace EcoBackend.Tests.Integration;

/// <summary>
/// Integration tests for Travel API endpoints (trips, location points, summaries, steps)
/// </summary>
public class TravelEndpointTests : IAsyncLifetime
{
    private HttpClient _client = null!;
    private CustomWebApplicationFactory _factory = null!;

    public async Task InitializeAsync()
    {
        _factory = new CustomWebApplicationFactory($"TravelTests_{Guid.NewGuid()}");
        _client = _factory.CreateClient();
        await RegisterAndAuthenticateAsync();
    }

    public async Task DisposeAsync()
    {
        _client?.Dispose();
        await _factory.DisposeAsync();
    }

    private async Task RegisterAndAuthenticateAsync()
    {
        await _client.PostAsJsonAsync("/api/users/register", new
        {
            email = "traveluser@example.com",
            username = "traveluser",
            password = "SecureP@ssw0rd123!",
            fullName = "Travel User"
        });

        var loginResponse = await _client.PostAsJsonAsync("/api/users/login", new
        {
            email = "traveluser@example.com",
            password = "SecureP@ssw0rd123!"
        });

        if (loginResponse.IsSuccessStatusCode)
        {
            var loginResult = await loginResponse.Content.ReadFromJsonAsync<Dictionary<string, object>>();
            if (loginResult != null && loginResult.ContainsKey("access"))
            {
                _client.DefaultRequestHeaders.Authorization =
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", loginResult["access"]?.ToString());
            }
        }
    }

    // ========== Trips ==========

    [Fact]
    public async Task GetTrips_ShouldReturnEmptyList()
    {
        var response = await _client.GetAsync("/api/travel/trips");
        Assert.True(response.IsSuccessStatusCode,
            $"Expected success but got {response.StatusCode}: {await response.Content.ReadAsStringAsync()}");
    }

    [Fact]
    public async Task GetTrips_WithFilters_ShouldWork()
    {
        var start = DateTime.UtcNow.AddDays(-7).ToString("o");
        var end = DateTime.UtcNow.ToString("o");
        var response = await _client.GetAsync($"/api/travel/trips?startDate={start}&endDate={end}&mode=car");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetTodaysTrips_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/travel/trips/today");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetTripStats_ShouldReturnStats()
    {
        var response = await _client.GetAsync("/api/travel/trips/stats?days=7");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("total_distance", content);
    }

    [Fact]
    public async Task CreateTrip_ShouldSucceed()
    {
        var response = await _client.PostAsJsonAsync("/api/travel/trips", new
        {
            transport_mode = "walking",
            distanceKm = 2.5,
            durationMinutes = 30,
            startLatitude = 40.7128,
            startLongitude = -74.0060,
            startLocation = "Home",
            endLatitude = 40.7200,
            endLongitude = -74.0100,
            endLocation = "Office",
            tripDate = DateTime.UtcNow.Date.ToString("o"),
            startTime = "08:00:00",
            endTime = "08:30:00",
            isAutoDetected = false,
            confidenceScore = 1.0
        });

        Assert.True(response.IsSuccessStatusCode || response.StatusCode == HttpStatusCode.Created,
            $"Create trip failed: {await response.Content.ReadAsStringAsync()}");
    }

    [Fact]
    public async Task CreateAndGetTrip_ShouldWork()
    {
        // Create trip
        var createResponse = await _client.PostAsJsonAsync("/api/travel/trips", new
        {
            transport_mode = "cycling",
            distanceKm = 5.0,
            durationMinutes = 20,
            startLatitude = 40.7128,
            startLongitude = -74.0060,
            startLocation = "Park",
            endLatitude = 40.7300,
            endLongitude = -74.0200,
            endLocation = "Gym",
            tripDate = DateTime.UtcNow.Date.ToString("o"),
            startTime = "07:00:00",
            endTime = "07:20:00",
            isAutoDetected = false,
            confidenceScore = 0.95
        });
        Assert.True(createResponse.IsSuccessStatusCode || createResponse.StatusCode == HttpStatusCode.Created);

        // Get trip by ID from response
        var content = await createResponse.Content.ReadAsStringAsync();
        var tripData = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(content,
            new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true });
        
        if (tripData != null && tripData.ContainsKey("id"))
        {
            var tripId = tripData["id"]?.ToString();
            var getResponse = await _client.GetAsync($"/api/travel/trips/{tripId}");
            Assert.True(getResponse.IsSuccessStatusCode);
        }
    }

    [Fact]
    public async Task GetTripById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/travel/trips/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task UpdateTrip_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.PutAsJsonAsync("/api/travel/trips/999", new
        {
            transportMode = "bus",
            distanceKm = 10.0
        });
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task DeleteTrip_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.DeleteAsync("/api/travel/trips/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    // ========== Location Points ==========

    [Fact]
    public async Task GetLocationPoints_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/travel/location-points");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task CreateLocationPoint_ShouldSucceed()
    {
        var response = await _client.PostAsJsonAsync("/api/travel/location-points", new
        {
            latitude = 40.7128,
            longitude = -74.0060,
            altitude = 10.0,
            accuracy = 5.0,
            speed = 1.5,
            timestamp = DateTime.UtcNow.ToString("o"),
            detectedActivity = "walking",
            activityConfidence = 0.9
        });

        Assert.True(response.IsSuccessStatusCode || response.StatusCode == HttpStatusCode.Created,
            $"Create location point failed: {await response.Content.ReadAsStringAsync()}");
    }

    [Fact]
    public async Task GetLocationPointById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/travel/location-points/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task UpdateLocationPoint_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.PutAsJsonAsync("/api/travel/location-points/999", new
        {
            latitude = 40.7128,
            longitude = -74.0060,
            timestamp = DateTime.UtcNow.ToString("o")
        });
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task DeleteLocationPoint_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.DeleteAsync("/api/travel/location-points/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task BatchUploadLocations_ShouldSucceed()
    {
        var response = await _client.PostAsJsonAsync("/api/travel/locations/batch", new
        {
            points = new[]
            {
                new
                {
                    latitude = 40.7128,
                    longitude = -74.0060,
                    altitude = 10.0,
                    accuracy = 5.0,
                    speed = 1.2,
                    timestamp = DateTime.UtcNow.AddMinutes(-5).ToString("o"),
                    detectedActivity = "walking",
                    activityConfidence = 0.85
                },
                new
                {
                    latitude = 40.7130,
                    longitude = -74.0062,
                    altitude = 10.0,
                    accuracy = 4.0,
                    speed = 1.3,
                    timestamp = DateTime.UtcNow.ToString("o"),
                    detectedActivity = "walking",
                    activityConfidence = 0.9
                }
            }
        });

        Assert.True(response.IsSuccessStatusCode,
            $"Batch upload failed: {await response.Content.ReadAsStringAsync()}");
    }

    // ========== Travel Summary ==========

    [Fact]
    public async Task GetTravelSummary_ShouldReturn200()
    {
        var response = await _client.GetAsync("/api/travel/summary");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetTravelSummary_WithDate_ShouldWork()
    {
        var date = DateTime.UtcNow.Date.ToString("o");
        var response = await _client.GetAsync($"/api/travel/summary?date={date}");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetWeeklySummary_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/travel/summary/weekly");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetSummaryById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/travel/summary/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    // ========== Steps ==========

    [Fact]
    public async Task UpdateSteps_ShouldSucceed()
    {
        var response = await _client.PostAsJsonAsync("/api/travel/steps", new
        {
            date = DateTime.UtcNow.Date.ToString("o"),
            steps = 8500
        });

        Assert.True(response.IsSuccessStatusCode,
            $"Update steps failed: {await response.Content.ReadAsStringAsync()}");
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("8500", content);
    }

    [Fact]
    public async Task UpdateSteps_Twice_ShouldUpdateExisting()
    {
        // First update
        await _client.PostAsJsonAsync("/api/travel/steps", new
        {
            date = DateTime.UtcNow.Date.ToString("o"),
            steps = 5000
        });

        // Second update - should overwrite
        var response = await _client.PostAsJsonAsync("/api/travel/steps", new
        {
            date = DateTime.UtcNow.Date.ToString("o"),
            steps = 10000
        });

        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("10000", content);
    }

    // ========== Unauthorized Access ==========

    [Fact]
    public async Task GetTrips_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.GetAsync("/api/travel/trips");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task CreateTrip_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.PostAsJsonAsync("/api/travel/trips", new
        {
            transportMode = "walking",
            distanceKm = 1.0,
            durationMinutes = 15,
            tripDate = DateTime.UtcNow.Date.ToString("o")
        });
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
