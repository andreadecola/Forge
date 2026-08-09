import 'package:flutter_test/flutter_test.dart';
import 'package:forge/domain/entities/biological_sex.dart';
import 'package:forge/domain/services/body_metrics_service.dart';

void main() {
  group('BodyMetricsService.calculateBmi', () {
    test('computes BMI from weight and height', () {
      final bmi = BodyMetricsService.calculateBmi(weightKg: 70, heightCm: 175);
      expect(bmi, closeTo(22.86, 0.01));
    });
  });

  group('BodyMetricsService.calculateBmr', () {
    test('Mifflin-St Jeor male', () {
      final bmr = BodyMetricsService.calculateBmr(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        biologicalSexForFormula: BiologicalSexForFormula.male,
      );
      // 10*80 + 6.25*180 - 5*30 + 5 = 800 + 1125 - 150 + 5 = 1780
      expect(bmr, 1780);
    });

    test('Mifflin-St Jeor female', () {
      final bmr = BodyMetricsService.calculateBmr(
        weightKg: 60,
        heightCm: 165,
        age: 25,
        biologicalSexForFormula: BiologicalSexForFormula.female,
      );
      // 10*60 + 6.25*165 - 5*25 - 161 = 600 + 1031.25 - 125 - 161 = 1345.25
      expect(bmr, closeTo(1345.25, 0.01));
    });

    test('returns null when biologicalSexForFormula is missing', () {
      final bmr = BodyMetricsService.calculateBmr(
        weightKg: 70,
        heightCm: 170,
        age: 40,
        biologicalSexForFormula: null,
      );
      expect(bmr, isNull);
    });
  });

  group('BodyMetricsService.calculateTdee', () {
    test('multiplies BMR by the activity factor', () {
      final tdee = BodyMetricsService.calculateTdee(
        bmr: 1500,
        activityFactor: 1.2,
      );
      expect(tdee, closeTo(1800, 0.01));
    });

    test('returns null when bmr is null', () {
      final tdee = BodyMetricsService.calculateTdee(
        bmr: null,
        activityFactor: 1.55,
      );
      expect(tdee, isNull);
    });
  });

  group('BodyMetricsService.calculateWeightLossPercentage', () {
    test('positive percentage when weight decreases', () {
      final percentage = BodyMetricsService.calculateWeightLossPercentage(
        initialWeight: 100,
        currentWeight: 90,
      );
      expect(percentage, closeTo(10, 0.01));
    });

    test('negative percentage when weight increases', () {
      final percentage = BodyMetricsService.calculateWeightLossPercentage(
        initialWeight: 80,
        currentWeight: 88,
      );
      expect(percentage, closeTo(-10, 0.01));
    });
  });

  group('BodyMetricsService.calculateWeightDifference', () {
    test('negative when current weight is lower than initial', () {
      final difference = BodyMetricsService.calculateWeightDifference(
        initialWeight: 90,
        currentWeight: 85,
      );
      expect(difference, closeTo(-5, 0.01));
    });
  });
}
