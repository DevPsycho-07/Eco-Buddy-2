using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EcoBackend.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPredictionTripAndUpdatePredictionLog : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PredictionLogs_AspNetUsers_UserId",
                table: "PredictionLogs");

            migrationBuilder.DropIndex(
                name: "IX_DailyLogs_UserId",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "ActualCO2",
                table: "PredictionLogs");

            migrationBuilder.DropColumn(
                name: "ErrorMargin",
                table: "PredictionLogs");

            migrationBuilder.RenameColumn(
                name: "PredictedCO2",
                table: "PredictionLogs",
                newName: "PredictedScore");

            migrationBuilder.RenameColumn(
                name: "Date",
                table: "PredictionLogs",
                newName: "InputData");

            migrationBuilder.AlterColumn<int>(
                name: "UserId",
                table: "PredictionLogs",
                type: "INTEGER",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "INTEGER");

            migrationBuilder.AddColumn<double>(
                name: "Confidence",
                table: "PredictionLogs",
                type: "REAL",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "PredictionTrips",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    UserId = table.Column<int>(type: "INTEGER", nullable: false),
                    TransportMode = table.Column<string>(type: "TEXT", nullable: false),
                    StartLatitude = table.Column<double>(type: "REAL", nullable: false),
                    StartLongitude = table.Column<double>(type: "REAL", nullable: false),
                    EndLatitude = table.Column<double>(type: "REAL", nullable: false),
                    EndLongitude = table.Column<double>(type: "REAL", nullable: false),
                    DistanceKm = table.Column<double>(type: "REAL", nullable: false),
                    StartTime = table.Column<DateTime>(type: "TEXT", nullable: false),
                    EndTime = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Date = table.Column<DateTime>(type: "TEXT", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PredictionTrips", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PredictionTrips_AspNetUsers_UserId",
                        column: x => x.UserId,
                        principalTable: "AspNetUsers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_DailyLogs_UserId_Date",
                table: "DailyLogs",
                columns: new[] { "UserId", "Date" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PredictionTrips_UserId_Date",
                table: "PredictionTrips",
                columns: new[] { "UserId", "Date" });

            migrationBuilder.AddForeignKey(
                name: "FK_PredictionLogs_AspNetUsers_UserId",
                table: "PredictionLogs",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PredictionLogs_AspNetUsers_UserId",
                table: "PredictionLogs");

            migrationBuilder.DropTable(
                name: "PredictionTrips");

            migrationBuilder.DropIndex(
                name: "IX_DailyLogs_UserId_Date",
                table: "DailyLogs");

            migrationBuilder.DropColumn(
                name: "Confidence",
                table: "PredictionLogs");

            migrationBuilder.RenameColumn(
                name: "PredictedScore",
                table: "PredictionLogs",
                newName: "PredictedCO2");

            migrationBuilder.RenameColumn(
                name: "InputData",
                table: "PredictionLogs",
                newName: "Date");

            migrationBuilder.AlterColumn<int>(
                name: "UserId",
                table: "PredictionLogs",
                type: "INTEGER",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "INTEGER",
                oldNullable: true);

            migrationBuilder.AddColumn<double>(
                name: "ActualCO2",
                table: "PredictionLogs",
                type: "REAL",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.AddColumn<double>(
                name: "ErrorMargin",
                table: "PredictionLogs",
                type: "REAL",
                nullable: false,
                defaultValue: 0.0);

            migrationBuilder.CreateIndex(
                name: "IX_DailyLogs_UserId",
                table: "DailyLogs",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_PredictionLogs_AspNetUsers_UserId",
                table: "PredictionLogs",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
