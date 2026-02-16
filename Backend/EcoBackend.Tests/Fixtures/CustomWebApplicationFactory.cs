using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using EcoBackend.Infrastructure.Data;

namespace EcoBackend.Tests.Fixtures;

/// <summary>
/// Custom WebApplicationFactory that configures in-memory database
/// and ensures the media directory exists for profile picture encryption.
/// </summary>
public class CustomWebApplicationFactory : WebApplicationFactory<Program>
{
    private readonly string _databaseName;

    public CustomWebApplicationFactory(string databaseName = "TestDb")
    {
        _databaseName = databaseName;
        // Pre-create the blank profile picture before the server starts
        EnsureBlankProfilePicture();
    }

    private void EnsureBlankProfilePicture()
    {
        // ProfilePictureEncryptionService uses Directory.GetCurrentDirectory() + /media/profile_pictures/
        var mediaPath = Path.Combine(Directory.GetCurrentDirectory(), "media", "profile_pictures");
        Directory.CreateDirectory(mediaPath);

        var blankPicturePath = Path.Combine(mediaPath, "blank-profile-picture.png");
        if (!File.Exists(blankPicturePath))
        {
            // Create a minimal valid PNG file (1x1 pixel)
            var minimalPng = new byte[]
            {
                0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
                0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
                0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
                0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
                0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, // IDAT chunk
                0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
                0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
                0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, // IEND chunk
                0x44, 0xAE, 0x42, 0x60, 0x82
            };
            File.WriteAllBytes(blankPicturePath, minimalPng);
        }
    }

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureServices(services =>
        {
            // Remove the existing DbContext registration
            var descriptor = services.SingleOrDefault(d =>
                d.ServiceType == typeof(DbContextOptions<EcoDbContext>));
            if (descriptor != null)
            {
                services.Remove(descriptor);
            }

            // Remove the DbContext itself
            var dbContextDescriptor = services.SingleOrDefault(d =>
                d.ServiceType == typeof(EcoDbContext));
            if (dbContextDescriptor != null)
            {
                services.Remove(dbContextDescriptor);
            }

            // Add in-memory database for testing
            services.AddDbContext<EcoDbContext>(options =>
            {
                options.UseInMemoryDatabase(databaseName: _databaseName);
            });
        });

        builder.UseEnvironment("Development");
    }
}
