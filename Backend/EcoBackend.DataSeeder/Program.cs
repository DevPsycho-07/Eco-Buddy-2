using EcoBackend.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace EcoBackend.DataSeeder;

/// <summary>
/// Console application to seed dummy data for admin@eco.com user
/// </summary>
class Program
{
    static async Task Main(string[] args)
    {
        Console.WriteLine("==============================================");
        Console.WriteLine("  EcoBackend Admin Data Seeder");
        Console.WriteLine("==============================================");
        Console.WriteLine();

        // Build configuration
        var configuration = new ConfigurationBuilder()
            .SetBasePath(Directory.GetCurrentDirectory())
            .AddJsonFile("appsettings.json", optional: true)
            .Build();

        // Get connection string
        var connectionString = configuration.GetConnectionString("DefaultConnection") 
            ?? "Data Source=../EcoBackend.API/eco.db";

        Console.WriteLine($"📊 Using database: {connectionString}");
        Console.WriteLine();

        // Create DbContext
        var optionsBuilder = new DbContextOptionsBuilder<EcoDbContext>();
        optionsBuilder.UseSqlite(connectionString);

        using var context = new EcoDbContext(optionsBuilder.Options);

        try
        {
            // Ensure database exists
            var canConnect = await context.Database.CanConnectAsync();
            if (!canConnect)
            {
                Console.WriteLine("❌ Cannot connect to database. Please ensure the database exists.");
                Console.WriteLine("   Run the EcoBackend.API application first to create the database.");
                return;
            }

            Console.WriteLine("✓ Connected to database successfully");
            Console.WriteLine();

            // Check if base data is seeded
            var categoriesCount = await context.ActivityCategories.CountAsync();
            if (categoriesCount == 0)
            {
                Console.WriteLine("⚠ Database is not initialized. Seeding base data first...");
                await DbInitializer.SeedAsync(context);
                Console.WriteLine();
            }

            // Seed admin dummy data
            await AdminDataSeeder.SeedAdminDummyDataAsync(context);

            Console.WriteLine();
            Console.WriteLine("==============================================");
            Console.WriteLine("✅ Data seeding completed successfully!");
            Console.WriteLine("==============================================");
            Console.WriteLine();
            Console.WriteLine("You can now login with:");
            Console.WriteLine("  Email: admin@eco.com");
            Console.WriteLine("  Password: Admin@123");
        }
        catch (Exception ex)
        {
            Console.WriteLine();
            Console.WriteLine("❌ Error occurred during seeding:");
            Console.WriteLine($"   {ex.Message}");
            Console.WriteLine();
            Console.WriteLine("Stack trace:");
            Console.WriteLine(ex.StackTrace);
            return;
        }
    }
}
