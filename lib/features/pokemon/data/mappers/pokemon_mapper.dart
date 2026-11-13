import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../dtos/pokemon_dto.dart';

/// Convierte DTOs en filas de Drift.
class PokemonMapper {
  const PokemonMapper._();

  static PokemonsCompanion toPokemonCompanion(PokemonDto dto, DateTime now) {
    return PokemonsCompanion(
      id: Value(dto.id),
      name: Value(dto.name),
      // Con is_default = true, el id coincide con el número nacional.
      nationalDexNumber: Value(dto.id),
      height: Value(dto.height),
      weight: Value(dto.weight),
      spriteUrl: Value(dto.spriteUrl ?? _fallbackSprite(dto.id)),
      updatedAt: Value(now),
    );
  }

  static TypesCompanion toTypeCompanion(PokemonTypeDto dto) {
    return TypesCompanion(id: Value(dto.id), name: Value(dto.name));
  }

  static List<PokemonTypesCompanion> toPokemonTypeCompanions(PokemonDto dto) {
    return [
      for (final t in dto.types)
        PokemonTypesCompanion(
          pokemonId: Value(dto.id),
          typeId: Value(t.id),
          slot: Value(t.slot),
        ),
    ];
  }

  /// Misma ruta que usa PokeAPI para `front_default`.
  static String _fallbackSprite(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
}