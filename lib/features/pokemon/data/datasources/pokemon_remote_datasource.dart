import 'dart:async';

import 'package:graphql/client.dart';

import '../../../../core/errors/failures.dart';
import '../dtos/pokemon_dto.dart';

/// Solo pedimos los campos que usamos.
const _catalogQuery = r'''
query CatalogPage($limit: Int!, $offset: Int!) {
  pokemon(
    where: {is_default: {_eq: true}}
    order_by: {id: asc}
    limit: $limit
    offset: $offset
  ) {
    id
    name
    height
    weight
    pokemontypes {
      slot
      type { id name }
    }
    pokemonsprites {
      sprites(path: "front_default")
    }
  }
}
''';

class PokemonRemoteDataSource {
  PokemonRemoteDataSource(
      this._client, {
        this.timeout = const Duration(seconds: 15),
      });

  final GraphQLClient _client;
  final Duration timeout;

  Future<List<PokemonDto>> fetchPage({
    required int limit,
    required int offset,
  }) async {
    final QueryResult<Object?> result;
    try {
      result = await _client
          .query(
        QueryOptions(
          document: gql(_catalogQuery),
          variables: {'limit': limit, 'offset': offset},
          fetchPolicy: FetchPolicy.noCache,
        ),
      )
          .timeout(timeout);
    } on TimeoutException {
      throw const TimeoutFailure();
    }

    final exception = result.exception;
    if (exception != null) throw _mapException(exception);

    try {
      final rows = result.data!['pokemon'] as List<dynamic>;
      return rows
          .map((r) => PokemonDto.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const InvalidDataFailure();
    }
  }

  /// Traduce excepciones del cliente a fallos del dominio.
  Failure _mapException(OperationException e) {
    final link = e.linkException;
    if (link is HttpLinkServerException) {
      final status = link.response.statusCode;
      return status == 429
          ? const RateLimitFailure()
          : ServerFailure(statusCode: status);
    }
    if (link != null) return const NetworkFailure();
    if (e.graphqlErrors.isNotEmpty) {
      return GraphqlFailure(e.graphqlErrors.first.message);
    }
    return const UnknownFailure();
  }
}