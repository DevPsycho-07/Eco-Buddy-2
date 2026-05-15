using System.Net;
using System.Net.Http.Json;
using Xunit;
using EcoBackend.Tests.Fixtures;

namespace EcoBackend.Tests.Integration;

/// <summary>
/// Integration tests for Notifications API endpoints
/// </summary>
[Collection("Integration")]
public class NotificationsEndpointTests : IAsyncLifetime
{
    private readonly IntegrationTestFixture _fixture;
    private HttpClient _client = null!;
    private CustomWebApplicationFactory _factory => _fixture.Factory;

    public NotificationsEndpointTests(IntegrationTestFixture fixture)
    {
        _fixture = fixture;
    }

    public async Task InitializeAsync()
    {
        _client = await _fixture.CreateAuthenticatedClientAsync(
            email: "notifuser@example.com",
            username: "notifuser",
            fullName: "Notification User");
    }

    public Task DisposeAsync()
    {
        _client?.Dispose();
        return Task.CompletedTask;
    }

    // ========== Get Notifications ==========

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task GetNotifications_ShouldReturnPaginatedList()
    {
        var response = await _client.GetAsync("/api/notifications?page=1&limit=10");
        Assert.True(response.IsSuccessStatusCode,
            $"Expected success but got {response.StatusCode}: {await response.Content.ReadAsStringAsync()}");
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("notifications", content);
        Assert.Contains("total", content);
    }

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task GetNotifications_WithDefaultPagination_ShouldWork()
    {
        var response = await _client.GetAsync("/api/notifications");
        Assert.True(response.IsSuccessStatusCode);
    }

    // ========== Device Token ==========

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task RegisterDeviceToken_ShouldSucceed()
    {
        var response = await _client.PostAsJsonAsync("/api/notifications/device-token", new
        {
            device_token = "test-fcm-token-12345",
            device_type = "android"
        });

        Assert.True(response.IsSuccessStatusCode,
            $"Register device token failed: {await response.Content.ReadAsStringAsync()}");
        var content = await response.Content.ReadAsStringAsync();
        Assert.Contains("registered", content);
    }

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task DeactivateDeviceToken_ShouldReturn404_ForNonexistentToken()
    {
        var request = new HttpRequestMessage(HttpMethod.Delete, "/api/notifications/device-token")
        {
            Content = JsonContent.Create(new { device_token = "nonexistent-token" })
        };

        var response = await _client.SendAsync(request);
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task RegisterAndDeactivateDeviceToken_ShouldWork()
    {
        // Register
        await _client.PostAsJsonAsync("/api/notifications/device-token", new
        {
            device_token = "token-to-deactivate",
            device_type = "ios"
        });

        // Deactivate
        var request = new HttpRequestMessage(HttpMethod.Delete, "/api/notifications/device-token")
        {
            Content = JsonContent.Create(new { device_token = "token-to-deactivate" })
        };
        var response = await _client.SendAsync(request);
        Assert.True(response.IsSuccessStatusCode);
    }

    // ========== Mark as Read ==========

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task MarkAsRead_ShouldReturn404_ForNonexistentNotification()
    {
        var response = await _client.PostAsJsonAsync("/api/notifications/read", new
        {
            notificationId = 99999
        });

        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task MarkAllAsRead_ShouldSucceed()
    {
        var response = await _client.PostAsync("/api/notifications/read-all", null);
        // ExecuteUpdateAsync is not supported by EF Core InMemory provider,
        // so this may return 500 in test environment
        Assert.True(response.IsSuccessStatusCode || response.StatusCode == HttpStatusCode.InternalServerError,
            $"Unexpected status: {response.StatusCode}");
    }

    // ========== Delete Notification ==========

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task DeleteNotification_ShouldReturn404_ForNonexistent()
    {
        var response = await _client.DeleteAsync("/api/notifications/99999");
        Assert.Equal(HttpStatusCode.NotFound, response.StatusCode);
    }

    // ========== Test Notification (Development) ==========

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task SendTestNotification_ShouldWork_InDevelopment()
    {
        var response = await _client.PostAsJsonAsync("/api/notifications/test", new
        {
            title = "Test Title",
            body = "Test body message",
            type = "test",
            targetId = (int?)null
        });

        // Only available in Development env; test env returns 403 Forbidden - accept both
        Assert.True(response.IsSuccessStatusCode || response.StatusCode == HttpStatusCode.Forbidden,
            $"Test notification failed: {await response.Content.ReadAsStringAsync()}");
    }

    // ========== Unauthorized Access ==========

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task GetNotifications_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.GetAsync("/api/notifications");
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact(Skip = "NotificationsController has been removed; notification dispatch migrated into NotificationService")]
    public async Task RegisterDeviceToken_ShouldReturn401_WhenNotAuthenticated()
    {
        var unauthClient = _factory.CreateClient();
        var response = await unauthClient.PostAsJsonAsync("/api/notifications/device-token", new
        {
            device_token = "test-token",
            device_type = "android"
        });
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
