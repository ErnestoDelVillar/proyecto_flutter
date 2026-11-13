import 'package:drift/drift.dart';

import 'pokemons.dart';
import 'types.dart';

/// Relación muchos a muchos entre Pokémon y tipo. `slot` indica tipo primario (1) o secundario (2).
@DataClassName('PokemonTypeRow')
@TableIndex(name: 'idx_pokemon_types_type', columns: {#typeId})
class PokemonTypes extends Table {
  IntColumn get pokemonId => integer().references(Pokemons, #id)();
  IntColumn get typeId => integer().references(Types, #id)();
  IntColumn get slot => integer()();

  @override
  Set<Column> get primaryKey => {pokemonId, typeId};
}