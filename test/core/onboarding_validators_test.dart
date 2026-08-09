import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/validation/onboarding_validators.dart';

void main() {
  group('OnboardingValidators.heightCm', () {
    test('rejects zero or negative height', () {
      expect(OnboardingValidators.heightCm(0), isNotNull);
      expect(OnboardingValidators.heightCm(-10), isNotNull);
    });

    test('rejects implausibly large height', () {
      expect(OnboardingValidators.heightCm(301), isNotNull);
    });

    test('accepts a plausible height', () {
      expect(OnboardingValidators.heightCm(175), isNull);
    });
  });

  group('OnboardingValidators.weightKg', () {
    test('rejects zero or negative weight', () {
      expect(OnboardingValidators.weightKg(0), isNotNull);
      expect(OnboardingValidators.weightKg(-5), isNotNull);
    });

    test('accepts a plausible weight', () {
      expect(OnboardingValidators.weightKg(72.5), isNull);
    });
  });

  group('OnboardingValidators.targetWeightKg', () {
    test('is optional: null is always valid', () {
      expect(OnboardingValidators.targetWeightKg(null), isNull);
    });

    test('rejects a non-positive target when provided', () {
      expect(OnboardingValidators.targetWeightKg(0), isNotNull);
    });
  });

  group('OnboardingValidators.birthDate', () {
    test('rejects a future birth date', () {
      final future = DateTime.now().add(const Duration(days: 1));
      expect(OnboardingValidators.birthDate(future), isNotNull);
    });

    test('accepts a past birth date', () {
      final past = DateTime(1990, 1, 1);
      expect(OnboardingValidators.birthDate(past), isNull);
    });
  });

  group('OnboardingValidators.preferredWalkMinutes', () {
    test('rejects zero or negative minutes', () {
      expect(OnboardingValidators.preferredWalkMinutes(0), isNotNull);
    });

    test('accepts positive minutes', () {
      expect(OnboardingValidators.preferredWalkMinutes(30), isNull);
    });
  });

  group('OnboardingValidators.equipmentBudgetLimit', () {
    test('rejects negative budget', () {
      expect(OnboardingValidators.equipmentBudgetLimit(-1), isNotNull);
    });

    test('accepts zero budget', () {
      expect(OnboardingValidators.equipmentBudgetLimit(0), isNull);
    });
  });

  group('OnboardingValidators.systolicOverDiastolic', () {
    test('rejects systolic not greater than diastolic', () {
      expect(OnboardingValidators.systolicOverDiastolic(80, 80), isNotNull);
      expect(OnboardingValidators.systolicOverDiastolic(70, 80), isNotNull);
    });

    test('accepts a plausible reading', () {
      expect(OnboardingValidators.systolicOverDiastolic(120, 80), isNull);
    });
  });
}
