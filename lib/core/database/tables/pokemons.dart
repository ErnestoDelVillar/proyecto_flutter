import 'package:drift/drift.dart';

/// Catálogo de Pokémon. Datos de PokeAPI.
@DataClassName('PokemonRow')
@TableIndex(name: 'idx_pokemons_name', columns: {#name})
@TableIndex(name: 'idx_pokemons_dex', columns: {#nationalDexNumber})
class Pokemons extends Table {
  /// Id remoto de PokeAPI. No es autoincremental.
  IntColumn get id => integer()();
  TextColumn get name => text()();
  IntColumn get nationalDexNumber => integer()();

  /// Altura del pokemon en Decímetros (tal como lo entrega la API).
  IntColumn get height => integer()();

  /// Peso Hectogramos (tal como lo entrega la API).
  IntColumn get weight => integer()();

  /// Sprite pequeño (front_default) para el listado. Ligero y rápido de cargar.
  TextColumn get spriteUrl => text()();

  /// Hash del contenido remoto. Se usará para detectar cambios.
  TextColumn get contentHash => text().nullable()();

  /// Momento de la última sincronización de este registro.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}