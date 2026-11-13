import '../../../../core/errors/failures.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokemon_local_datasource.dart';
import '../datasources/pokemon_remote_datasource.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  PokemonRepositoryImpl({
    required this.remote,
    required this.local,
    this.pageSize = 50,
  });

  static const catalogKey = 'pokemon_catalog';

  final PokemonRemoteDataSource remote;
  final PokemonLocalDataSource local;
  final int pageSize;

  /// Si ya hay una sync en curso, se reutiliza (RNF-RES-03).
  Future<void>? _inFlight;

  @override
  Future<void> refreshCatalog() {
    return _inFlight ??= _sync().whenComplete(() => _inFlight = null);
  }

  Future<void> _sync() async {
    final meta = await local.getSyncMetadata(catalogKey);
    // Éxito previo: refresco completo desde 0.
    // Interrumpida o fallida: reanuda donde quedó (PS-07).
    var offset = (meta == null || meta.status == 'success') ? 0 : meta.nextOffset;

    await local.saveSyncState(
      catalogKey,
      status: 'in_progress',
      nextOffset: offset,
    );

    try {
      while (true) {
        final page = await remote.fetchPage(limit: pageSize, offset: offset);
        offset += page.length;
        if (page.isNotEmpty) {
          await local.upsertPage(
            resourceKey: catalogKey,
            page: page,
            nextOffset: offset,
          );
        }
        if (page.length < pageSize) break; // última página
      }
      await local.saveSyncState(
        catalogKey,
        status: 'success',
        nextOffset: 0,
        lastSuccessAt: DateTime.now(),
      );
    } on Failure {
      // Las páginas ya guardadas son válidas y se conservan (OF-04).
      await local.saveSyncState(catalogKey, status: 'failed');
      rethrow;
    } catch (_) {
      await local.saveSyncState(catalogKey, status: 'failed');
      throw const UnknownFailure();
    }
  }
}