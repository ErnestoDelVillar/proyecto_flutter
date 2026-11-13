import 'package:graphql/client.dart';

const pokeApiGraphqlUrl = 'https://graphql.pokeapi.co/v1beta2';

/// Cliente GraphQL sin caché propia.
GraphQLClient createGraphQLClient({String url = pokeApiGraphqlUrl}) {
  return GraphQLClient(
    link: HttpLink(url),
    cache: GraphQLCache(),
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.noCache),
    ),
  );
}