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

  static const catalogSyncKey = 'pokemon_catalog';

  final PokemonRemoteDataSource remote;
  final PokemonLocalDataSource local;
  final int pageSize;

  /// Si ya hay una sync en curso, se reutiliza (RNF-RES-03).
  Future<void>? _ongoingSync;

  @override
  Future<void> syncCatalogFromRemote() {
    return _ongoingSync ??= _runCatalogSync().whenComplete(() => _ongoingSync = null);
  }

  Future<void> _runCatalogSync() async {
    final meta = await local.getSyncMetadata(catalogSyncKey);
    // Éxito previo: refresco completo desde 0.
    // Interrumpida o fallida: reanuda donde quedó.
    var offset = (meta == null || meta.status == 'success') ? 0 : meta.nextOffset;

    await local.saveSyncState(
      catalogSyncKey,
      status: 'in_progress',
      nextOffset: offset,
    );

    try {
      while (true) {
        final page = await remote.fetchPage(limit: pageSize, offset: offset);
        offset += page.length;
        if (page.isNotEmpty) {
          await local.upsertCatalogPage(
            resourceKey: catalogSyncKey,
            page: page,
            nextOffset: offset,
          );
        }
        if (page.length < pageSize) break; // última página
      }
      await local.saveSyncState(
        catalogSyncKey,
        status: 'success',
        nextOffset: 0,
        lastSuccessAt: DateTime.now(),
      );
    } on Failure {
      // Las páginas ya guardadas son válidas y se conservan.
      await local.saveSyncState(catalogSyncKey, status: 'failed');
      rethrow;
    } catch (_) {
      await local.saveSyncState(catalogSyncKey, status: 'failed');
      throw const UnknownFailure();
    }
  }
}