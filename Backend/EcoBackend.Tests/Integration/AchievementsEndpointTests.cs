using System.Net;
using System.Net.Http.Json;
using Xunit;
using EcoBackend.Tests.Fixtures;

namespace EcoBackend.Tests.Integration;

/// <summary>
/// Integration tests for Achievements API endpoints (badges, challenges)
/// </summary>
public class AchievementsEndpointTests : IAsyncLifetime
{
    private HttpClient _client = null!;
    private CustomWebApplicationFactory _factory = null!;

    public async Task InitializeAsync()
    {
        _factory = new CustomWebApplicationFactory($"AchievementsTests_{Guid.NewGuid()}");
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
            email = "achieveuser@example.com",
            username = "achieveuser",
            password = "SecureP@ssw0rd123!",
            fullName = "Achieve User"
        });

        var loginResponse = await _client.PostAsJsonAsync("/api/users/login", new
        {
            email = "achieveuser@example.com",
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

    // ========== Badges ==========

    [Fact]
    public async Task GetBadges_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/achievements/badges");
        Assert.True(response.IsSuccessStatusCode,
            $"Expected success but got {response.StatusCode}: {await response.Content.ReadAsStringAsync()}");
    }

    [Fact]
    public async Task GetBadgeById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/achievements/badges/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetMyBadges_ShouldReturnEmptyList_WhenNoBadgesEarned()
    {
        var response = await _client.GetAsync("/api/achievements/my-badges");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("[", content); // Array response
    }

    [Fact]
    public async Task GetMyBadgeById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/achievements/my-badges/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetMyBadgesSummary_ShouldReturnSummary()
    {
        var response = await _client.GetAsync("/api/achievements/my-badges/summary");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("total_badges", content);
    }

    // ========== Challenges ==========

    [Fact]
    public async Task GetChallenges_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/achievements/challenges");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetChallengeById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/achievements/challenges/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetActiveChallenges_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/achievements/challenges/active");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task JoinChallenge_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.PostAsync("/api/achievements/challenges/999/join", null);
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    // ========== My Challenges ==========

    [Fact]
    public async Task GetMyChallenges_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/achievements/my-challenges");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetMyChallengeById_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.GetAsync("/api/achievements/my-challenges/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetMyActiveChallenges_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/achievements/my-challenges/active");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetCompletedChallenges_ShouldReturnList()
    {
        var response = await _client.GetAsync("/api/achievements/my-challenges/completed");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task UpdateMyChallenge_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.PutAsJsonAsync("/api/achievements/my-challenges/999", new
        {
            currentProgress = 5.0
        });
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task LeaveChallenge_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.DeleteAsync("/api/achievements/my-challenges/999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    // ========== Summary ==========

    [Fact]
    public async Task GetAchievementsSummary_ShouldReturnData()
    {
        var response = await _client.GetAsync("/api/achievements/summary");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("total_badges", content);
        Assert.Contains("total_challenges", content);
    }

    // ========== Unauthorized Access ==========

    [Fact]
    public async Task GetBadges_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.GetAsync("/api/achievements/badges");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task GetMyChallenges_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.GetAsync("/api/achievements/my-challenges");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
