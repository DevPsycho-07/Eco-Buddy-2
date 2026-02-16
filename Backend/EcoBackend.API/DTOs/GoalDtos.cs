using System.ComponentModel.DataAnnotations;

namespace EcoBackend.API.DTOs;

public class UserGoalDto
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public double TargetValue { get; set; }
    public double CurrentValue { get; set; }
    public string Unit { get; set; } = string.Empty;
    public bool IsCompleted { get; set; }
    public DateTime? Deadline { get; set; }
    public double ProgressPercentage { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateUserGoalDto
{
    [Required]
    [StringLength(200, MinimumLength = 1)]
    public string Title { get; set; } = string.Empty;
    
    public string Description { get; set; } = string.Empty;
    
    [Required]
    [Range(0.01, double.MaxValue, ErrorMessage = "Target value must be greater than 0")]
    public double TargetValue { get; set; }
    
    [Required]
    [StringLength(50, MinimumLength = 1)]
    public string Unit { get; set; } = string.Empty;
    
    public DateTime? Deadline { get; set; }
}

public class UpdateUserGoalDto
{
    [StringLength(200, MinimumLength = 1)]
    public string? Title { get; set; }
    
    public string? Description { get; set; }
    
    [Range(0.01, double.MaxValue, ErrorMessage = "Target value must be greater than 0")]
    public double? TargetValue { get; set; }
    
    [Range(0, double.MaxValue, ErrorMessage = "Current value cannot be negative")]
    public double? CurrentValue { get; set; }
    
    [StringLength(50, MinimumLength = 1)]
    public string? Unit { get; set; }
    
    public bool? IsCompleted { get; set; }
    
    public DateTime? Deadline { get; set; }
}
