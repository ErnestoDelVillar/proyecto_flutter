import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/di/providers.dart';
import 'core/errors/failures.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  final db = container.read(appDatabaseProvider);

  var syncResult = 'SYNC OK';
  try {
    await container.read(pokemonRepositoryProvider).refreshCatalog();
  } on Failure catch (f) {
    syncResult = 'SYNC FALLO: $f';
  }

  final rows = await db.select(db.pokemons).get();

  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$syncResult\nPokémon en la base: ${rows.length}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  ));
}