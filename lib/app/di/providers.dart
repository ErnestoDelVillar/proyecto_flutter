import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql/client.dart';

import '../../core/database/app_database.dart';
import '../../core/network/graphql_client_factory.dart';
import '../../features/pokemon/data/datasources/pokemon_local_datasource.dart';
import '../../features/pokemon/data/datasources/pokemon_remote_datasource.dart';
import '../../features/pokemon/data/repositories/pokemon_repository_impl.dart';
import '../../features/pokemon/domain/repositories/pokemon_repository.dart';

/// Raíz de composición: único lugar que une data con el resto de la app.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final graphQLClientProvider =
Provider<GraphQLClient>((ref) => createGraphQLClient());

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return PokemonRepositoryImpl(
    remote: PokemonRemoteDataSource(ref.watch(graphQLClientProvider)),
    local: PokemonLocalDataSource(ref.watch(appDatabaseProvider)),
  );
});