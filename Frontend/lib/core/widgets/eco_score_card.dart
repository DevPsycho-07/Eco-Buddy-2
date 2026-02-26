import 'package:flutter/material.dart';

class EcoScoreCard extends StatelessWidget {
  final int score;
  final double? predictedScore;
  final String? scoreCategory;
  final bool isPredictionLoading;
  final bool hasLoggedToday;

  const EcoScoreCard({
    super.key,
    required this.score,
    this.predictedScore,
    this.scoreCategory,
    this.isPredictionLoading = false,
    this.hasLoggedToday = false,
  });

  String _getScoreMessage() {
    // If we have a predicted score, use that; otherwise use activity points
    final double displayScore = predictedScore ?? score.toDouble();
    
    if (displayScore >= 80) {
      return '🌟 Excellent! Keep it up!';
    } else if (displayScore >= 60) {
      return '✅ Good work! Keep going!';
    } else if (displayScore >= 40) {
      return '⚠️ Room for improvement';
    } else if (displayScore >= 20) {
      return '📉 Try logging eco activities';
    } else {
      return '🔴 Start your eco journey';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use predicted score in the circle if available, otherwise fall back to activity points
    final double circleValue =
        predictedScore != null ? predictedScore! / 100 : score / 100;
    final String circleLabel =
        predictedScore != null ? predictedScore!.toStringAsFixed(0) : '$score';
    final String circleSub = scoreCategory ?? 'Points';

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Circular progress indicator — shows predicted score
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: isPredictionLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        )
                      : CircularProgressIndicator(
                          value: circleValue.clamp(0.0, 1.0),
                          strokeWidth: 10,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                ),
                if (!isPredictionLoading)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        circleLabel,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        circleSub,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Predicted Score',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (predictedScore != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      hasLoggedToday
                          ? '📊 Based on today\'s activities + profile'
                          : '⚠️ Log activities for accurate score',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getScoreMessage(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
