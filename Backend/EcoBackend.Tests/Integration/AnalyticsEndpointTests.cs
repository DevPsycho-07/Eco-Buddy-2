using System.Net;
using System.Net.Http.Json;
using Xunit;
using EcoBackend.Tests.Fixtures;

namespace EcoBackend.Tests.Integration;

/// <summary>
/// Integration tests for Analytics API endpoints (weekly, monthly, dashboard, stats, comparison, export)
/// </summary>
[Collection("Integration")]
public class AnalyticsEndpointTests : IAsyncLifetime
{
    private readonly IntegrationTestFixture _fixture;
    private HttpClient _client = null!;
    private CustomWebApplicationFactory _factory => _fixture.Factory;

    public AnalyticsEndpointTests(IntegrationTestFixture fixture)
    {
        _fixture = fixture;
    }

    public async Task InitializeAsync()
    {
        _client = await _fixture.CreateAuthenticatedClientAsync(
            email: "analyticsuser@example.com",
            username: "analyticsuser",
            fullName: "Analytics User");
    }

    public Task DisposeAsync()
    {
        _client?.Dispose();
        return Task.CompletedTask;
    }

    // ========== Weekly Report ==========

    [Fact]
    public async Task GetWeeklyReport_ShouldReturn404_WhenNoReport()
    {
        var response = await _client.GetAsync("/api/analytics/weekly");
        // No weekly report should exist yet
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetWeeklyReport_WithSpecificDate_ShouldWork()
    {
        var weekStart = DateTime.UtcNow.AddDays(-7).ToString("o");
        var response = await _client.GetAsync($"/api/analytics/weekly?weekStart={weekStart}");
        // Should return 404 or 200 depending on whether data exists
        Assert.True(response.StatusCode == HttpStatusCode.NotFound || response.IsSuccessStatusCode);
    }

    // ========== Monthly Report ==========

    [Fact]
    public async Task GetMonthlyReport_ShouldReturn404_WhenNoReport()
    {
        var response = await _client.GetAsync("/api/analytics/monthly");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact]
    public async Task GetMonthlyReport_WithYearAndMonth_ShouldWork()
    {
        var response = await _client.GetAsync($"/api/analytics/monthly?year={DateTime.UtcNow.Year}&month={DateTime.UtcNow.Month}");
        Assert.True(response.StatusCode == HttpStatusCode.NotFound || response.IsSuccessStatusCode);
    }

    // ========== Dashboard ==========

    [Fact]
    public async Task GetDashboard_ShouldReturnDashboardData()
    {
        var response = await _client.GetAsync("/api/analytics/dashboard");
        Assert.True(response.IsSuccessStatusCode,
            $"Expected success but got {response.StatusCode}: {await response.Content.ReadAsStringAsync()}");
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("today", content);
        Assert.Contains("week", content);
        Assert.Contains("month", content);
        Assert.Contains("user", content);
    }

    // ========== Stats ==========

    [Fact]
    public async Task GetStats_DefaultPeriod_ShouldReturnData()
    {
        var response = await _client.GetAsync("/api/analytics/stats");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("total_activities", content);
        Assert.Contains("total_points", content);
    }

    [Fact]
    public async Task GetStats_TodayPeriod_ShouldWork()
    {
        var response = await _client.GetAsync("/api/analytics/stats?period=today");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetStats_WeekPeriod_ShouldWork()
    {
        var response = await _client.GetAsync("/api/analytics/stats?period=week");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetStats_MonthPeriod_ShouldWork()
    {
        var response = await _client.GetAsync("/api/analytics/stats?period=month");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task GetStats_YearPeriod_ShouldWork()
    {
        var response = await _client.GetAsync("/api/analytics/stats?period=year");
        Assert.True(response.IsSuccessStatusCode);
    }

    // ========== Comparison ==========

    [Fact]
    public async Task GetComparison_ShouldReturnComparisonData()
    {
        var response = await _client.GetAsync("/api/analytics/comparison");
        Assert.True(response.IsSuccessStatusCode);
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("user", content);
        Assert.Contains("average", content);
        Assert.Contains("percentile", content);
        Assert.Contains("comparison", content);
    }

    // ========== Export ==========

    [Fact]
    public async Task ExportCsv_ShouldReturnCsvFile()
    {
        var response = await _client.GetAsync("/api/analytics/export/csv");
        Assert.True(response.IsSuccessStatusCode);
        Assert.Equal("text/csv", response.Content.Headers.ContentType?.MediaType);
    }

    [Fact]
    public async Task ExportCsv_WithPeriod_ShouldWork()
    {
        var response = await _client.GetAsync("/api/analytics/export/csv?period=week");
        Assert.True(response.IsSuccessStatusCode);
    }

    [Fact]
    public async Task ExportCsv_AllPeriod_ShouldWork()
    {
        var response = await _client.GetAsync("/api/analytics/export/csv?period=all");
        Assert.True(response.IsSuccessStatusCode);
    }

    // ========== Unauthorized Access ==========

    [Fact]
    public async Task GetDashboard_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.GetAsync("/api/analytics/dashboard");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task GetStats_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.GetAsync("/api/analytics/stats");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task ExportCsv_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.GetAsync("/api/analytics/export/csv");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
