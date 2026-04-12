using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace EcoBackend.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class SeedCategoriesTypesAndTips : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "ActivityCategories",
                columns: new[] { "Id", "Color", "Description", "Icon", "Name" },
                values: new object[,]
                {
                    { 1, "#2196F3", "Transportation and commuting activities", "directions_car", "Transport" },
                    { 2, "#4CAF50", "Food choices and dietary habits", "restaurant", "Food" },
                    { 3, "#FF9800", "Home energy usage and conservation", "bolt", "Energy" },
                    { 4, "#9C27B0", "Waste management and recycling", "recycling", "Recycling" },
                    { 5, "#00BCD4", "Water usage and conservation", "water_drop", "Water" }
                });

            migrationBuilder.InsertData(
                table: "ActivityTypes",
                columns: new[] { "Id", "CO2Impact", "CategoryId", "Icon", "ImpactUnit", "IsEcoFriendly", "Name", "Points" },
                values: new object[,]
                {
                    { 1, 0.0, 1, "directions_walk", "per km", true, "Walking", 15 },
                    { 2, 0.0, 1, "directions_bike", "per km", true, "Cycling", 15 },
                    { 3, 0.088999999999999996, 1, "directions_bus", "per km", true, "Public Transit", 10 },
                    { 4, 0.041000000000000002, 1, "train", "per km", true, "Train", 12 },
                    { 5, 0.192, 1, "directions_car", "per km", false, "Car (Solo)", 0 },
                    { 6, 0.096000000000000002, 1, "people", "per km", true, "Carpooling", 8 },
                    { 7, 0.052999999999999999, 1, "electric_car", "per km", true, "Electric Vehicle", 10 },
                    { 8, 0.0, 1, "directions_run", "per km", true, "Running", 15 },
                    { 9, -2.5, 2, "eco", "per meal", true, "Vegan Meal", 20 },
                    { 10, -1.5, 2, "grass", "per meal", true, "Vegetarian Meal", 15 },
                    { 11, -0.5, 2, "storefront", "per purchase", true, "Local Produce", 10 },
                    { 12, -1.0, 2, "soup_kitchen", "per meal", true, "Zero Waste Cooking", 15 },
                    { 13, 3.2999999999999998, 2, "lunch_dining", "per meal", false, "Meat-based Meal", 0 },
                    { 14, -1.5, 3, "solar_power", "per kWh", true, "Solar Energy Used", 20 },
                    { 15, -0.050000000000000003, 3, "lightbulb", "per hour", true, "LED Lighting", 5 },
                    { 16, -2.3999999999999999, 3, "dry_cleaning", "per load", true, "Air Dry Laundry", 10 },
                    { 17, -0.29999999999999999, 3, "thermostat", "per degree/day", true, "Thermostat Reduction", 8 },
                    { 18, -0.5, 4, "recycling", "per kg", true, "Recycling", 10 },
                    { 19, -0.29999999999999999, 4, "compost", "per kg", true, "Composting", 10 },
                    { 20, -1.0, 4, "auto_awesome", "per item", true, "Upcycling", 15 },
                    { 21, -0.20000000000000001, 4, "block", "per day", true, "Plastic-Free Day", 20 },
                    { 22, -0.10000000000000001, 5, "shower", "per shower", true, "Short Shower", 5 },
                    { 23, -0.20000000000000001, 5, "water", "per litre", true, "Rainwater Harvesting", 10 },
                    { 24, -0.5, 5, "plumbing", "per fix", true, "Fix Leaks", 15 }
                });

            migrationBuilder.InsertData(
                table: "Tips",
                columns: new[] { "Id", "CategoryId", "Content", "ImpactDescription", "IsActive", "Priority", "Title" },
                values: new object[,]
                {
                    { 1, 1, "For trips under 3 km, consider walking or cycling instead of driving. You'll save fuel and stay fit.", "Saves ~0.2 kg CO2 per km", true, 1, "Walk or Cycle Short Distances" },
                    { 2, 1, "Buses and trains emit far less CO2 per passenger than individual cars.", "Saves ~0.1 kg CO2 per km vs car", true, 2, "Use Public Transport" },
                    { 3, 1, "Share rides with colleagues or neighbours to halve your per-person emissions.", "Reduces car emissions by 50%", true, 3, "Try Carpooling" },
                    { 4, 2, "Replacing one beef meal with a plant-based alternative saves about 3 kg of CO2.", "Saves ~3 kg CO2 per meal swap", true, 1, "Eat More Plant-Based Meals" },
                    { 5, 2, "Locally sourced food travels less, reducing transport emissions and supporting local farmers.", "Reduces food miles significantly", true, 2, "Buy Local Produce" },
                    { 6, 3, "LED bulbs use up to 80% less energy than incandescent bulbs and last 25 times longer.", "Saves ~40 kg CO2 per bulb/year", true, 1, "Switch to LED Bulbs" },
                    { 7, 3, "Electronics on standby still consume power. Unplug chargers and devices when not in use.", "Saves ~100 kWh per year", true, 2, "Unplug Idle Devices" },
                    { 8, 4, "Composting food scraps reduces methane from landfills and creates nutrient-rich soil.", "Diverts ~200 kg waste/year", true, 1, "Start Composting" },
                    { 9, 4, "Carry reusable bags, bottles, and containers to avoid single-use plastic waste.", "Prevents ~50 kg plastic waste/year", true, 2, "Refuse Single-Use Plastics" },
                    { 10, 5, "Reducing shower time by 2 minutes saves about 20 litres of water per shower.", "Saves ~7,000 litres per year", true, 1, "Shorten Your Shower" }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 17);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 19);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 20);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 21);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 22);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 23);

            migrationBuilder.DeleteData(
                table: "ActivityTypes",
                keyColumn: "Id",
                keyValue: 24);

            migrationBuilder.DeleteData(
                table: "Tips",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "Tips",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "Tips",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "Tips",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "Tips",
                keyColumn: "Id",
                keyValue: 5);

            migrationBuilder.DeleteData(
                table: "Tips",
                keyColumn: "Id",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Tips",
                keyColumn: "Id",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Tips",
                keyColumn: "Id",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Tips",
                keyColumn: "Id",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Tips",
                keyColumn: "Id",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "ActivityCategories",
                keyColumn: "Id",
                keyValue: 1);

            migrationBuilder.DeleteData(
                table: "ActivityCategories",
                keyColumn: "Id",
                keyValue: 2);

            migrationBuilder.DeleteData(
                table: "ActivityCategories",
                keyColumn: "Id",
                keyValue: 3);

            migrationBuilder.DeleteData(
                table: "ActivityCategories",
                keyColumn: "Id",
                keyValue: 4);

            migrationBuilder.DeleteData(
                table: "ActivityCategories",
                keyColumn: "Id",
                keyValue: 5);
        }
    }
}
