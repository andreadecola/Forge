import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:forge/app.dart';
import 'package:forge/data/database/app_database.dart';
import 'package:forge/data/database/database_provider.dart';
import 'package:forge/data/repositories/body_metrics_repository_impl.dart';
import 'package:forge/data/repositories/pressure_repository_impl.dart';
import 'package:forge/data/repositories/forge_providers.dart';
import 'package:forge/domain/entities/body_measurement.dart';
import 'package:forge/domain/entities/pressure_measurement.dart';
import 'package:forge/domain/services/clock.dart';
import 'package:forge/features/progress/presentation/widgets/progress_charts_section.dart';

import 'exercise_test_fixtures.dart';

void main() {
  final now = DateTime(2026, 8, 29, 12);

  BodyMeasurement body({
    required DateTime measuredAt,
    double? weightKg,
    double? waistCm,
  }) {
    return BodyMeasurement(
      id: measuredAt.millisecondsSinceEpoch,
      profileId: 1,
      measuredAt: measuredAt,
      weightKg: weightKg,
      waistCm: waistCm,
    );
  }

  PressureMeasurement pressure({
    required DateTime measuredAt,
    required int systolic,
    required int diastolic,
  }) {
    return PressureMeasurement(
      id: measuredAt.millisecondsSinceEpoch,
      profileId: 1,
      measuredAt: measuredAt,
      systolic: systolic,
      diastolic: diastolic,
    );
  }

  Widget buildPage({
    List<BodyMeasurement> bodyMeasurements = const [],
    List<PressureMeasurement> pressureMeasurements = const [],
    DateTime? chartNow,
  }) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: ProgressChartsSection(
            bodyMeasurements: AsyncData(bodyMeasurements),
            pressureMeasurements: AsyncData(pressureMeasurements),
            now: chartNow ?? now,
          ),
        ),
      ),
    );
  }

  testWidgets('empty state and defaults are explicit', (tester) async {
    await tester.pumpWidget(buildPage());

    expect(find.text('Andamento'), findsOneWidget);
    expect(find.text('Peso (kg)'), findsNWidgets(2));
    expect(find.text('30 giorni'), findsOneWidget);
    expect(
      find.text('Nessun dato disponibile per questo intervallo'),
      findsOneWidget,
    );
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('metric and range selectors change the displayed data', (
    tester,
  ) async {
    final bodyMeasurements = [
      body(measuredAt: now.subtract(const Duration(days: 1)), weightKg: 145),
      body(measuredAt: now.subtract(const Duration(days: 10)), weightKg: 146),
      body(measuredAt: now.subtract(const Duration(days: 1)), waistCm: 132),
    ];
    final pressureMeasurements = [
      pressure(
        measuredAt: now.subtract(const Duration(days: 1)),
        systolic: 128,
        diastolic: 82,
      ),
      pressure(
        measuredAt: now.subtract(const Duration(days: 10)),
        systolic: 125,
        diastolic: 80,
      ),
    ];

    await tester.pumpWidget(
      buildPage(
        bodyMeasurements: bodyMeasurements,
        pressureMeasurements: pressureMeasurements,
      ),
    );

    expect(find.text('2 misurazioni nel periodo selezionato'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '7 giorni'));
    await tester.pumpAndSettle();
    expect(find.text('1 misurazione nel periodo selezionato'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Girovita (cm)'));
    await tester.pumpAndSettle();
    expect(find.text('Girovita (cm)'), findsNWidgets(2));
    expect(find.text('1 misurazione nel periodo selezionato'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Pressione (mmHg)'));
    await tester.pumpAndSettle();
    expect(find.text('Sistolica'), findsOneWidget);
    expect(find.text('Diastolica'), findsOneWidget);
    expect(find.text('128 / 82 mmHg'), findsNothing);
    expect(find.text('1 misurazione nel periodo selezionato'), findsOneWidget);
  });

  testWidgets('one point renders and partial metrics stay independent', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildPage(bodyMeasurements: [body(measuredAt: now, waistCm: 999.9)]),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Girovita (cm)'));
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('1 misurazione nel periodo selezionato'), findsOneWidget);
    expect(
      find.text('Nessun dato disponibile per questo intervallo'),
      findsNothing,
    );
  });

  testWidgets('is scrollable at 320x480 with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: buildPage(
          bodyMeasurements: [
            body(measuredAt: now, weightKg: 999.9, waistCm: 999.9),
          ],
          pressureMeasurements: [
            pressure(measuredAt: now, systolic: 999, diastolic: 999),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Andamento'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('renders without overflow in a landscape viewport '
      '(Milestone 7.7, sezione 24)', (tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildPage(
        bodyMeasurements: [
          body(measuredAt: now.subtract(const Duration(days: 1)), weightKg: 80),
          body(measuredAt: now, weightKg: 78),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('new AsyncData rebuild removes deleted chart points', (
    tester,
  ) async {
    final first = body(
      measuredAt: now.subtract(const Duration(days: 2)),
      weightKg: 145,
    );
    final second = body(
      measuredAt: now.subtract(const Duration(days: 1)),
      weightKg: 143,
    );

    await tester.pumpWidget(buildPage(bodyMeasurements: [first, second]));
    expect(find.text('2 misurazioni nel periodo selezionato'), findsOneWidget);

    await tester.pumpWidget(buildPage(bodyMeasurements: [first]));
    await tester.pumpAndSettle();
    expect(find.text('1 misurazione nel periodo selezionato'), findsOneWidget);
  });

  group('provider live updates', () {
    late AppDatabase database;

    setUp(() async {
      database = memoryDatabase();
      await seedAppWith(database);
    });

    tearDown(() => database.close());

    testWidgets('body and pressure CRUD updates the selected chart', (
      tester,
    ) async {
      final chartClock = _FixedClock(now);
      final profileId = (await database.userProfileDao.getCurrentProfile())!.id;
      final bodyRepository = BodyMetricsRepositoryImpl(
        database.bodyMeasurementsDao,
      );
      final pressureRepository = PressureRepositoryImpl(
        database.pressureMeasurementsDao,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            clockProvider.overrideWithValue(chartClock),
          ],
          child: const ForgeApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Progressi'));
      await tester.pumpAndSettle();

      expect(
        find.text('Nessun dato disponibile per questo intervallo'),
        findsOneWidget,
      );

      final bodyId = await bodyRepository.addMeasurement(
        BodyMeasurement(
          profileId: profileId,
          measuredAt: now.subtract(const Duration(days: 1)),
          weightKg: 145,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('1 misurazione nel periodo selezionato'),
        findsOneWidget,
      );

      await bodyRepository.updateMeasurement(
        BodyMeasurement(
          id: bodyId,
          profileId: profileId,
          measuredAt: now,
          weightKg: 143,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('1 misurazione nel periodo selezionato'),
        findsOneWidget,
      );

      await bodyRepository.deleteMeasurement(bodyId);
      await tester.pumpAndSettle();
      expect(
        find.text('Nessun dato disponibile per questo intervallo'),
        findsOneWidget,
      );

      final pressureId = await pressureRepository.addMeasurement(
        PressureMeasurement(
          profileId: profileId,
          measuredAt: now,
          systolic: 128,
          diastolic: 82,
        ),
      );
      await tester.pumpAndSettle();
      final pressureChip = find.widgetWithText(ChoiceChip, 'Pressione (mmHg)');
      await tester.ensureVisible(pressureChip);
      await tester.tap(pressureChip);
      await tester.pumpAndSettle();
      expect(
        find.text('1 misurazione nel periodo selezionato'),
        findsOneWidget,
      );

      await pressureRepository.updateMeasurement(
        PressureMeasurement(
          id: pressureId,
          profileId: profileId,
          measuredAt: now,
          systolic: 118,
          diastolic: 76,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('1 misurazione nel periodo selezionato'),
        findsOneWidget,
      );

      await pressureRepository.deleteMeasurement(pressureId);
      await tester.pumpAndSettle();
      expect(
        find.text('Nessun dato disponibile per questo intervallo'),
        findsOneWidget,
      );

      await disposeCleanly(tester);
    });
  });
}

class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}
