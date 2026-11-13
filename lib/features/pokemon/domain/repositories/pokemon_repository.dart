/// Contrato del repositorio. En el paso 4 se agrega la lectura reactiva.
abstract class PokemonRepository {
  /// Descarga el catálogo desde PokeAPI y lo guarda en la base local.
  /// Lanza un `Failure` si algo falla; los datos ya guardados se conservan.
  Future<void> refreshCatalog();
}