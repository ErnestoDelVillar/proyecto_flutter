import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../dtos/pokemon_dto.dart';
import '../mappers/pokemon_mapper.dart';

class PokemonLocalDataSource {
  PokemonLocalDataSource(this._db);

  final AppDatabase _db;

  Future<SyncMetadataRow?> getSyncMetadata(String key) {
    return (_db.select(_db.syncMetadata)
      ..where((m) => m.resourceKey.equals(key)))
        .getSingleOrNull();
  }

  Future<void> saveSyncState(
      String key, {
        required String status,
        int? nextOffset,
        DateTime? lastSuccessAt,
      }) {
    return _db.into(_db.syncMetadata).insertOnConflictUpdate(
      SyncMetadataCompanion(
        resourceKey: Value(key),
        status: Value(status),
        nextOffset:
        nextOffset == null ? const Value.absent() : Value(nextOffset),
        lastSuccessAt: lastSuccessAt == null
            ? const Value.absent()
            : Value(lastSuccessAt),
      ),
    );
  }

  /// Guarda una página completa y su progreso en UNA transacción:
  /// o se guarda todo o no se guarda nada.
  /// Upsert por id remoto.
  Future<void> upsertPage({
    required String resourceKey,
    required List<PokemonDto> page,
    required int nextOffset,
  }) {
    final now = DateTime.now();
    final ids = page.map((d) => d.id).toList();
    final uniqueTypes = {
      for (final dto in page)
        for (final t in dto.types) t.id: t,
    };

    return _db.transaction(() async {
      // El orden importa por las claves foráneas: tipos, pokémon, relaciones.
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.types,
          uniqueTypes.values.map(PokemonMapper.toTypeCompanion).toList(),
        );
        b.insertAllOnConflictUpdate(
          _db.pokemons,
          page.map((d) => PokemonMapper.toPokemonCompanion(d, now)).toList(),
        );
        // Se reemplazan los tipos: si PokeAPI los cambió, prevalece el remoto.
        b.deleteWhere(_db.pokemonTypes, (t) => t.pokemonId.isIn(ids));
        b.insertAll(
          _db.pokemonTypes,
          [for (final d in page) ...PokemonMapper.toPokemonTypeCompanions(d)],
        );
      });

      await saveSyncState(
        resourceKey,
        status: 'in_progress',
        nextOffset: nextOffset,
      );
    });
  }
}