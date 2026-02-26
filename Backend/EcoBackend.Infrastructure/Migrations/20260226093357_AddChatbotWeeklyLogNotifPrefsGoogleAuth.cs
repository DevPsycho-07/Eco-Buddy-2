using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EcoBackend.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddChatbotWeeklyLogNotifPrefsGoogleAuth : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "TrainKm",
                table: "DailyLogs",
                newName: "WaterUsageLiters");

            migrationBuilder.AddColumn<double>(
                name: "AcHours",
                table: "DailyLogs",
                type: "REAL",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "EcoScore",
                table: "DailyLogs",
                type: "REAL",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "FishMeals",
                table: "DailyLogs",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<double>(
                name: "FoodWasteKg",
                table: "DailyLogs",
                type: "REAL",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "HeatingHours",
                table: "DailyLogs",
                type: "REAL",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "InternetHours",
                table: "DailyLogs",
                type: "REAL",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "NaturalGasTherms",
                table: "DailyLogs",
                type: "REAL",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<int>(
                name: "PoultryMeals",
                table: "DailyLogs",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "RedMeatMeals",
                table: "DailyLogs",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "ScoreCategory",
                table: "DailyLogs",
                type: "TEXT",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "ShowerFrequency",
                table: "DailyLogs",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<double>(
                name: "TrainMetroKm",
                table: "DailyLogs",
                type: "REAL",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "TvPcHours",
                table: "DailyLogs",
                type: "REAL",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "DailyLogs",
                type: "TEXT",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<int>(
                name: "VeganMeals",
                table: "DailyLogs",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "VegetarianMeals",
                table: "DailyLogs",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "GoogleAuthId",
                table: "AspNetUsers",
                type: "TEXT",
                nullable: true);

            migrationBuilder.AddColumn<DateOnly>(
                name: "LastActivityDate",
                table: "AspNetUsers",
                type: "TEXT",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "ChatSessions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    UserId = table.Column<int>(type: "INTEGER", nullable: false),
                    Title = table.Column<string>(type: "TEXT", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatSessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChatSessions_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "NotificationPreferences",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    UserId = table.Column<int>(type: "INTEGER", nullable: false),
                    DailyReminders = table.Column<bool>(type: "INTEGER", nullable: false),
                    AchievementAlerts = table.Column<bool>(type: "INTEGER", nullable: false),
                    WeeklyReports = table.Column<bool>(type: "INTEGER", nullable: false),
                    TipsAndSuggestions = table.Column<bool>(type: "INTEGER", nullable: false),
                    CommunityUpdates = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_NotificationPreferences", x => x.Id);
                    table.ForeignKey(
                        name: "FK_NotificationPreferences_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WeeklyLogs",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    UserId = table.Column<int>(type: "INTEGER", nullable: false),
                    WeekStartDate = table.Column<DateOnly>(type: "TEXT", nullable: false),
                    WasteBagCount = table.Column<int>(type: "INTEGER", nullable: false),
                    GeneralWasteKg = table.Column<double>(type: "REAL", nullable: false),
                    RecycledWasteKg = table.Column<double>(type: "REAL", nullable: false),
                    GroceryBill = table.Column<double>(type: "REAL", nullable: false),
                    NewClothesMonthly = table.Column<int>(type: "INTEGER", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WeeklyLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_WeeklyLogs_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ChatMessages",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    SessionId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Role = table.Column<string>(type: "TEXT", nullable: false),
                    Content = table.Column<string>(type: "TEXT", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ChatMessages", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ChatMessages_ChatSessions_SessionId",
                        column: x => x.SessionId,
                        principalTable: "ChatSessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUsers_GoogleAuthId",
                table: "AspNetUsers",
                column: "GoogleAuthId",
                unique: true,
                filter: "\"GoogleAuthId\" IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_ChatMessages_SessionId",
                table: "ChatMessages",
                column: "SessionId");

            migrationBuilder.CreateIndex(
                name: "IX_ChatSessions_UserId",
                table: "ChatSessions",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_NotificationPreferences_UserId",
                table: "NotificationPreferences",
                column: "UserId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_WeeklyLogs_UserId_WeekStartDate",
                table: "WeeklyLogs",
                columns: new[] { "UserId", "WeekStartDate" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ChatMessages");

            migrationBuilder.DropTable(
                name: "NotificationPreferences");

            migrationBuilder.DropTable(
                name: "WeeklyLogs");

            migrationBuilder.DropTable(
                name: "ChatSessions");

            migrationBuilder.DropIndex(
                name: "IX_AspNetUsers_GoogleAuthId",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "AcHours",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "EcoScore",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "FishMeals",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "FoodWasteKg",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "HeatingHours",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "InternetHours",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "NaturalGasTherms",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "PoultryMeals",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "RedMeatMeals",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "ScoreCategory",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "ShowerFrequency",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "TrainMetroKm",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "TvPcHours",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "VeganMeals",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "VegetarianMeals",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "GoogleAuthId",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "LastActivityDate",
                table: "AspNetUsers");

            migrationBuilder.RenameColumn(
                name: "WaterUsageLiters",
                table: "DailyLogs",
                newName: "TrainKm");
        }
    }
}
