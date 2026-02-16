using System.Net;
using System.Net.Http.Json;
using Xunit;
using EcoBackend.Tests.Fixtures;

namespace EcoBackend.Tests.Integration;

/// <summary>
/// Integration tests for Predictions API endpoints (profile, daily-logs, prediction stubs)
/// </summary>
public class PredictionsEndpointTests : IAsyncLifetime
{
    private HttpClient _client = null!;
    private CustomWebApplicationFactory _factory = null!;

    public async Task InitializeAsync()
    {
        _factory = new CustomWebApplicationFactory($"PredictionsTests_{Guid.NewGuid()}");
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
            email = "predictuser@example.com",
            username = "predictuser",
            password = "SecureP@ssw0rd123!",
            fullName = "Predict User"
        });

        var loginResponse = await _client.PostAsJsonAsync("/api/users/login", new
        {
            email = "predictuser@example.com",
            password = "SecureP@ssw0rd123!"
        });

        if (loginResponse.IsSuccessStatusCode)
        {
            var loginResult = await loginResponse.Content.ReadFromJsonAsync<Dictionary<string, object>>();
            if (loginResult != null && loginResult.ContainsKey("accessToken"))
            {
                _client.DefaultRequestHeaders.Authorization =
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", loginResult["accessToken"]?.ToString());
            }
        }
    }

    // ========== Profile ==========

    [Fact]
    public async Task GetProfile_ShouldReturn200()
    {
        var response = await _client.GetAsync("/api/predictions/profile");
        Assert.True(response.IsSuccessStatusCode,
            $"Expected success but got {response.StatusCode}: {await response.Content.ReadAsStringAsync()}");
    }

    [Fact]
    public async Task CreateOrUpdateProfile_ShouldSucceed()
    {
        var response = await _client.PostAsJsonAsync("/api/predictions/profile", new
        {
            householdSize = 3,
            ageGroup = "25-34",
            lifestyleType = "moderate",
            locationType = "urban",
            vehicleType = "sedan",
            carFuelType = "petrol",
            dietType = "omnivore",
            usesSolarPanels = false,
            smartThermostat = true,
            renewableEnergyPercent = 20.0,
            recyclingPracticed = true,
            compostingPracticed = false,
            wasteBagSize = "medium",
            socialActivity = "moderate"
        });

        Assert.True(response.IsSuccessStatusCode,
            $"Create profile failed: {await response.Content.ReadAsStringAsync()}");
    }

    [Fact]
    public async Task CreateProfile_ThenGetProfile_ShouldReturnData()
    {
        // Create profile
        await _client.PostAsJsonAsync("/api/predictions/profile", new
        {
            householdSize = 2,
            ageGroup = "18-24",
            lifestyleType = "active",
            locationType = "suburban",
            vehicleType = "none",
            carFuelType = "none",
            dietType = "vegetarian",
            usesSolarPanels = true,
            smartThermostat = false,
            renewableEnergyPercent = 50.0,
            recyclingPracticed = true,
            compostingPracticed = true,
            wasteBagSize = "small",
            socialActivity = "high"
        });

        // Get profile
        var response = await _client.GetAsync("/api/predictions/profile");
        Assert.True(response.IsSuccessStatusCode);
    }

    // ========== Daily Logs ==========

    [Fact]
    public async Task GetDailyLogs_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/predictions/daily-logs");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetDailyLogs_WithDateFilters_ShouldWork()
    {
        var start = DateTime.UtcNow.AddDays(-7).ToString("o");
        var end = DateTime.UtcNow.ToString("o");
        var response = await _client.GetAsync($"/api/predictions/daily-logs?startDate={start}&endDate={end}");
        Assert.True(response.IsSuccessStatusCode);
    }

    // ========== Prediction Stubs ==========

    [Fact]
    public async Task Predict_ShouldReturnNotImplemented()
    {
        var response = await _client.PostAsJsonAsync("/api/predictions/predict", new { });
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    [Fact]
    public async Task QuickPredict_ShouldReturnNotImplemented()
    {
        var response = await _client.PostAsJsonAsync("/api/predictions/predict/quick", new { });
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    [Fact]
    public async Task GetPredictionHistory_ShouldReturnNotImplemented()
    {
        var response = await _client.GetAsync("/api/predictions/history");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    [Fact]
    public async Task PredictTrips_ShouldReturnNotImplemented()
    {
        var response = await _client.PostAsJsonAsync("/api/predictions/trips", new { });
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    [Fact]
    public async Task GetTripPredictions_ShouldReturnNotImplemented()
    {
        var response = await _client.GetAsync("/api/predictions/trips");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    [Fact]
    public async Task PredictDaily_ShouldReturnNotImplemented()
    {
        var response = await _client.PostAsJsonAsync("/api/predictions/daily", new { });
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    [Fact]
    public async Task GetDailyPredictions_ShouldReturnNotImplemented()
    {
        var response = await _client.GetAsync("/api/predictions/daily");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    [Fact]
    public async Task GetWeeklyPredictions_ShouldReturnNotImplemented()
    {
        var response = await _client.GetAsync("/api/predictions/weekly");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    [Fact]
    public async Task PredictWeekly_ShouldReturnNotImplemented()
    {
        var response = await _client.PostAsJsonAsync("/api/predictions/weekly", new { });
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    [Fact]
    public async Task GetModelInfo_ShouldReturnModelDetails()
    {
        var response = await _client.GetAsync("/api/predictions/model-info");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("model", content);
    }

    [Fact]
    public async Task GetPredictionDashboard_ShouldReturnNotImplemented()
    {
        var response = await _client.GetAsync("/api/predictions/dashboard");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    [Fact]
    public async Task UpdateProfile_Stub_ShouldReturnNotImplemented()
    {
        var response = await _client.PutAsJsonAsync("/api/predictions/profile", new { });
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("not_implemented", content);
    }

    // ========== Unauthorized Access ==========

    [Fact]
    public async Task GetProfile_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.GetAsync("/api/predictions/profile");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Predict_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.PostAsJsonAsync("/api/predictions/predict", new { });
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
