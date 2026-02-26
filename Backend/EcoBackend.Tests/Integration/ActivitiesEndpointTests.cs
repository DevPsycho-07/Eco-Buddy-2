using System.Net;
using System.Net.Http.Json;
using Xunit;
using EcoBackend.Tests.Fixtures;

namespace EcoBackend.Tests.Integration;

/// <summary>
/// Integration tests for Activities API endpoints (categories, types, tips, CRUD, summary)
/// </summary>
public class ActivitiesEndpointTests : IAsyncLifetime
{
    private HttpClient _client = null!;
    private CustomWebApplicationFactory _factory = null!;

    public async Task InitializeAsync()
    {
        _factory = new CustomWebApplicationFactory($"ActivitiesTests_{Guid.NewGuid()}");
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
            email = "activityuser@example.com",
            username = "activityuser",
            password = "SecureP@ssw0rd123!",
            fullName = "Activity User"
        });

        var loginResponse = await _client.PostAsJsonAsync("/api/users/login", new
        {
            email = "activityuser@example.com",
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

    // ========== Categories ==========

    [Fact]
    public async Task GetCategories_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/activities/categories");
        Assert.True(response.IsSuccessStatusCode,
            $"Expected success but got {response.StatusCode}: {await response.Content.ReadAsStringAsync()}");
    }

    [Fact]
    public async Task GetCategoryById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/activities/categories/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    // ========== Activity Types ==========

    [Fact]
    public async Task GetActivityTypes_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/activities/types");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetActivityTypes_WithCategoryFilter_ShouldWork()
    {
        var response = await _client.GetAsync("/api/activities/types?category=1");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetActivityTypeById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/activities/types/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    // ========== Activities CRUD ==========

    [Fact]
    public async Task GetActivities_ShouldReturnEmptyList_WhenNoActivities()
    {
        var response = await _client.GetAsync("/api/activities");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("[", content); // Should be an array
    }

    [Fact]
    public async Task CreateActivity_ShouldFail_WithInvalidActivityType()
    {
        var response = await _client.PostAsJsonAsync("/api/activities", new
        {
            activityTypeId = 99999,
            quantity = 5.0,
            activityDate = DateTime.UtcNow.Date.ToString("o")
        });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
    }

    [Fact]
    public async Task GetActivityById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/activities/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task DeleteActivity_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.DeleteAsync("/api/activities/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    // ========== Today & Summary ==========

    [Fact]
    public async Task GetTodayActivities_ShouldReturn200()
    {
        var response = await _client.GetAsync("/api/activities/today");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetSummary_ShouldReturnSummaryData()
    {
        var response = await _client.GetAsync("/api/activities/summary?days=7");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("total_activities", content);
    }

    [Fact]
    public async Task GetSummary_WithDifferentPeriods_ShouldWork()
    {
        var response = await _client.GetAsync("/api/activities/summary?days=30");
        Assert.True(response.IsSuccessStatusCode);
    }

    // ========== Tips ==========

    [Fact]
    public async Task GetTips_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/activities/tips");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetTipById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/activities/tips/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetDailyTip_ShouldReturnTip()
    {
        var response = await _client.GetAsync("/api/activities/tips/daily");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("title", content);
    }

    // ========== Alternative Routes ==========

    [Fact]
    public async Task GetLogToday_ShouldReturnSameAsTodayActivities()
    {
        var response = await _client.GetAsync("/api/activities/log/today");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetLogSummary_ShouldReturnSummary()
    {
        var response = await _client.GetAsync("/api/activities/log/summary");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetLogHistory_ShouldReturnGroupedActivities()
    {
        var response = await _client.GetAsync("/api/activities/log/history?days=30");
        Assert.True(response.IsSuccessStatusCode);
    }

    // ========== Activities with Date Filters ==========

    [Fact]
    public async Task GetActivities_WithDateFilters_ShouldWork()
    {
        var start = DateTime.UtcNow.AddDays(-7).ToString("o");
        var end = DateTime.UtcNow.ToString("o");
        var response = await _client.GetAsync($"/api/activities?startDate={start}&endDate={end}");
        Assert.True(response.IsSuccessStatusCode);
    }

    // ========== Unauthorized Access ==========

    [Fact]
    public async Task GetActivities_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.GetAsync("/api/activities");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task CreateActivity_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.PostAsJsonAsync("/api/activities", new
        {
            activityTypeId = 1,
            quantity = 5.0,
            activityDate = DateTime.UtcNow.Date.ToString("o")
        });
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
