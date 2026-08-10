import 'package:flutter/material.dart';

import 'workout_list_page.dart';

/// Voce "Programma" della bottom navigation: punto di ingresso alle schede
/// allenamento (Milestone 4.3).
class ProgramPage extends StatelessWidget {
  const ProgramPage({super.key});

  @override
  Widget build(BuildContext context) => const WorkoutListPage();
}
