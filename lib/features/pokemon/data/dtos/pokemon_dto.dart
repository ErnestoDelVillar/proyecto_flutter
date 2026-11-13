/// Representa la respuesta GraphQL.
class PokemonDto {
  const PokemonDto({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.spriteUrl,
  });

  final int id;
  final String name;
  final int height;
  final int weight;
  final List<PokemonTypeDto> types;
  final String? spriteUrl;

  factory PokemonDto.fromJson(Map<String, dynamic> json) {
    final typesJson = json['pokemontypes'] as List<dynamic>? ?? const [];
    return PokemonDto(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      types: typesJson
          .map((e) => PokemonTypeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      spriteUrl: _extractSpriteUrl(json['pokemonsprites']),
    );
  }

  /// `pokemonsprites` es una lista de un elemento. Con `sprites(path: ...)`
  /// llega la URL directa; sin `path`, llega el objeto completo.
  static String? _extractSpriteUrl(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    final first = raw.first;
    if (first is! Map) return null;
    final sprites = first['sprites'];
    if (sprites is String) return sprites;
    if (sprites is Map) return sprites['front_default'] as String?;
    return null;
  }
}

class PokemonTypeDto {
  const PokemonTypeDto({
    required this.id,
    required this.name,
    required this.slot,
  });

  final int id;
  final String name;
  final int slot;

  factory PokemonTypeDto.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as Map<String, dynamic>;
    return PokemonTypeDto(
      id: type['id'] as int,
      name: type['name'] as String,
      slot: json['slot'] as int,
    );
  }
}