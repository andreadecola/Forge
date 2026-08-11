import 'package:flutter/material.dart';

import '../walking_metrics.dart';

class WalkingMetricsSheet extends StatefulWidget {
  const WalkingMetricsSheet({super.key, this.distanceMeters, this.steps});

  final int? distanceMeters;
  final int? steps;

  static Future<WalkingMetricsInput?> show(
    BuildContext context, {
    int? distanceMeters,
    int? steps,
  }) {
    return showModalBottomSheet<WalkingMetricsInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) =>
          WalkingMetricsSheet(distanceMeters: distanceMeters, steps: steps),
    );
  }

  @override
  State<WalkingMetricsSheet> createState() => _WalkingMetricsSheetState();
}

class _WalkingMetricsSheetState extends State<WalkingMetricsSheet> {
  late final TextEditingController _distanceController;
  late final TextEditingController _stepsController;
  String? _distanceError;
  String? _stepsError;

  @override
  void initState() {
    super.initState();
    _distanceController = TextEditingController(
      text: widget.distanceMeters == null
          ? ''
          : formatWalkingDistanceForInput(widget.distanceMeters!),
    );
    _stepsController = TextEditingController(
      // Keep the editable value ungrouped: the parser intentionally accepts
      // only integer digits, while the read-only UI adds Italian separators.
      text: widget.steps == null ? '' : widget.steps.toString(),
    );
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  void _save() {
    final distanceText = _distanceController.text.trim();
    final stepsText = _stepsController.text.trim();
    final distance = parseWalkingDistanceKm(distanceText);
    final steps = parseWalkingSteps(stepsText);
    final distanceError = distanceText.isNotEmpty && distance == null
        ? 'Inserisci una distanza valida.'
        : null;
    final stepsError = stepsText.isNotEmpty && steps == null
        ? 'Inserisci un numero di passi valido.'
        : null;

    if (distanceError != null || stepsError != null) {
      setState(() {
        _distanceError = distanceError;
        _stepsError = stepsError;
      });
      return;
    }

    Navigator.of(
      context,
    ).pop(WalkingMetricsInput(distanceMeters: distance, steps: steps));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dati camminata',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _distanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Distanza (km)',
                hintText: 'es. 3,5',
                errorText: _distanceError,
              ),
              onChanged: (_) {
                if (_distanceError != null) {
                  setState(() => _distanceError = null);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _stepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Passi',
                hintText: 'es. 4200',
                errorText: _stepsError,
              ),
              onChanged: (_) {
                if (_stepsError != null) {
                  setState(() => _stepsError = null);
                }
              },
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _save, child: const Text('Salva')),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
          ],
        ),
      ),
    );
  }
}
