import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/exercise_catalog_providers.dart';

/// Campo di ricerca del catalogo esercizi, con debounce. Riutilizzato sia
/// da `ExerciseCatalogPage` sia da `ExercisePickerPage` (Milestone 4.3):
/// entrambi leggono/scrivono lo stesso `exerciseFiltersProvider`, nessuna
/// seconda implementazione del filtro testuale.
class ExerciseSearchField extends ConsumerStatefulWidget {
  const ExerciseSearchField({super.key});

  @override
  ConsumerState<ExerciseSearchField> createState() =>
      _ExerciseSearchFieldState();
}

class _ExerciseSearchFieldState extends ConsumerState<ExerciseSearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(exerciseFiltersProvider).searchQuery ?? '',
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(exerciseFiltersProvider.notifier).setSearchQuery(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(exerciseFiltersProvider.notifier).setSearchQuery('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Se il testo viene azzerato dall'esterno (es. "Reimposta filtri"),
    // sincronizza il campo: altrimenti resterebbe con testo non più valido.
    ref.listen(exerciseFiltersProvider, (previous, next) {
      final resetExternally =
          (next.searchQuery == null || next.searchQuery!.isEmpty) &&
          _controller.text.isNotEmpty;
      if (resetExternally) {
        _debounce?.cancel();
        _controller.clear();
      }
    });

    return TextField(
      controller: _controller,
      onChanged: (value) {
        _onChanged(value);
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: 'Cerca esercizio',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
      ),
    );
  }
}
