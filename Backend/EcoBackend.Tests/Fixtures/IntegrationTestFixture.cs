using System.Net.Http.Headers;
using System.Net.Http.Json;
using Xunit;

namespace EcoBackend.Tests.Fixtures;

/// <summary>
/// Shared fixture used by every integration test class via the
/// "Integration" xUnit collection. One WebApplicationFactory boot for the
/// entire suite, instead of one per test.
///
/// Each test class registers its own user (unique email) via
/// CreateAuthenticatedClientAsync — the in-memory DB is shared but per-class
/// emails keep auth state isolated.
/// </summary>
public class IntegrationTestFixture : IAsyncLifetime
{
    public CustomWebApplicationFactory Factory { get; private set; } = null!;

    public Task InitializeAsync()
    {
        Factory = new CustomWebApplicationFactory("IntegrationTestsSharedDb");
        return Task.CompletedTask;
    }

    public async Task DisposeAsync()
    {
        await Factory.DisposeAsync();
    }

    /// <summary>
    /// Register (idempotently) and authenticate a user, returning a
    /// pre-authorized HttpClient. Caller passes a class-unique email so
    /// classes don't accidentally share user state.
    /// </summary>
    public async Task<HttpClient> CreateAuthenticatedClientAsync(
        string email,
        string username,
        string password = "SecureP@ssw0rd123!",
        string fullName = "Test User")
    {
        var client = Factory.CreateClient();

        // Register is allowed to fail (user may already exist from a prior test in the class).
        await client.PostAsJsonAsync("/api/users/register", new
        {
            email,
            username,
            password,
            fullName
        });

        var loginResponse = await client.PostAsJsonAsync("/api/users/login", new
        {
            email,
            password
        });

        if (loginResponse.IsSuccessStatusCode)
        {
            var loginResult = await loginResponse.Content.ReadFromJsonAsync<Dictionary<string, object>>();
            if (loginResult != null && loginResult.TryGetValue("access", out var token))
            {
                client.DefaultRequestHeaders.Authorization =
                    new AuthenticationHeaderValue("Bearer", token?.ToString());
            }
        }

        return client;
    }
}

/// <summary>
/// Marker class wiring the IntegrationTestFixture to the "Integration" xUnit
/// collection. Every integration test class uses [Collection("Integration")].
/// </summary>
[CollectionDefinition("Integration")]
public class IntegrationTestCollection : ICollectionFixture<IntegrationTestFixture>
{
}
