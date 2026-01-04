class IELTSBandCalculator {
  /// Convert raw score to IELTS band score (0-9, only .0 or .5)
  /// IELTS only uses: 0, 0.5, 1.0, 1.5, ..., 8.5, 9.0
  static double calculateBandScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0.0;
    
    final percentage = (correctAnswers / totalQuestions) * 100;
    double rawBand = 0.0;
    
    // IELTS Reading/Listening band score conversion (Academic)
    // Based on official IELTS scoring table
    if (percentage >= 97.5) {
      rawBand = 9.0;
    } else if (percentage >= 95.0) {
      rawBand = 8.5;
    } else if (percentage >= 90.0) {
      rawBand = 8.0;
    } else if (percentage >= 82.5) {
      rawBand = 7.5;
    } else if (percentage >= 75.0) {
      rawBand = 7.0;
    } else if (percentage >= 67.5) {
      rawBand = 6.5;
    } else if (percentage >= 60.0) {
      rawBand = 6.0;
    } else if (percentage >= 52.5) {
      rawBand = 5.5;
    } else if (percentage >= 45.0) {
      rawBand = 5.0;
    } else if (percentage >= 37.5) {
      rawBand = 4.5;
    } else if (percentage >= 30.0) {
      rawBand = 4.0;
    } else if (percentage >= 22.5) {
      rawBand = 3.5;
    } else if (percentage >= 15.0) {
      rawBand = 3.0;
    } else if (percentage >= 10.0) {
      rawBand = 2.5;
    } else if (percentage >= 5.0) {
      rawBand = 2.0;
    } else if (percentage >= 2.5) {
      rawBand = 1.5;
    } else if (percentage > 0) {
      rawBand = 1.0;
    } else {
      rawBand = 0.0;
    }
    
    return rawBand;
  }

  /// Calculate overall IELTS band score from 4 sections
  /// Average of Listening, Reading, Writing, Speaking
  /// Rounded to nearest .0 or .5
  static double calculateOverallBand({
    required double listening,
    required double reading,
    required double writing,
    required double speaking,
  }) {
    final average = (listening + reading + writing + speaking) / 4;
    return roundToHalfBand(average);
  }

  /// Round to nearest .0 or .5
  /// Example: 6.125 -> 6.0, 6.25 -> 6.5, 6.375 -> 6.5, 6.75 -> 7.0
  static double roundToHalfBand(double score) {
    // IELTS rounding rules:
    // .25 and below -> round down to .0
    // .75 and above -> round up to next .0
    // Otherwise -> round to .5
    
    final integerPart = score.floor();
    final decimalPart = score - integerPart;
    
    if (decimalPart < 0.25) {
      return integerPart.toDouble();
    } else if (decimalPart < 0.75) {
      return integerPart + 0.5;
    } else {
      return (integerPart + 1).toDouble();
    }
  }

  /// Get band descriptor (e.g., "Expert User", "Very Good User")
  static String getBandDescriptor(double band) {
    if (band == 9.0) return 'Expert User';
    if (band >= 8.0) return 'Very Good User';
    if (band >= 7.0) return 'Good User';
    if (band >= 6.0) return 'Competent User';
    if (band >= 5.0) return 'Modest User';
    if (band >= 4.0) return 'Limited User';
    if (band >= 3.0) return 'Extremely Limited User';
    if (band >= 2.0) return 'Intermittent User';
    if (band >= 1.0) return 'Non User';
    return 'Did Not Attempt';
  }

  /// Get band color for UI
  static int getBandColor(double band) {
    if (band >= 8.0) return 0xFF4CAF50; // Green
    if (band >= 7.0) return 0xFF8BC34A; // Light Green
    if (band >= 6.0) return 0xFF2196F3; // Blue
    if (band >= 5.0) return 0xFFFF9800; // Orange
    if (band >= 4.0) return 0xFFFF5722; // Deep Orange
    return 0xFFF44336; // Red
  }

  /// Convert AI score (0-9 with decimals) to proper IELTS band
  static double convertAIScoreToBand(double aiScore) {
    return roundToHalfBand(aiScore);
  }
}
