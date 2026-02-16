using System.ComponentModel.DataAnnotations;

namespace EcoBackend.API.DTOs;

public class DailyScoreDto
{
    public int Id { get; set; }
    public DateTime Date { get; set; }
    public int Score { get; set; }
    public double CO2Emitted { get; set; }
    public double CO2Saved { get; set; }
    public int Steps { get; set; }
}

public class CreateDailyScoreDto
{
    [Required]
    public DateTime Date { get; set; }
    
    [Range(0, int.MaxValue, ErrorMessage = "Score cannot be negative")]
    public int Score { get; set; } = 0;
    
    [Range(0, double.MaxValue, ErrorMessage = "CO2 emitted cannot be negative")]
    public double CO2Emitted { get; set; } = 0.0;
    
    [Range(0, double.MaxValue, ErrorMessage = "CO2 saved cannot be negative")]
    public double CO2Saved { get; set; } = 0.0;
    
    [Range(0, int.MaxValue, ErrorMessage = "Steps cannot be negative")]
    public int Steps { get; set; } = 0;
}

public class UpdateDailyScoreDto
{
    [Range(0, int.MaxValue, ErrorMessage = "Score cannot be negative")]
    public int? Score { get; set; }
    
    [Range(0, double.MaxValue, ErrorMessage = "CO2 emitted cannot be negative")]
    public double? CO2Emitted { get; set; }
    
    [Range(0, double.MaxValue, ErrorMessage = "CO2 saved cannot be negative")]
    public double? CO2Saved { get; set; }
    
    [Range(0, int.MaxValue, ErrorMessage = "Steps cannot be negative")]
    public int? Steps { get; set; }
}
