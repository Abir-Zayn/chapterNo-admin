// Lightweight Supabase pg_graphql client with dynamic JWT header injection.
// Sends queries and mutations to /graphql/v1 and maps errors into AppFailure.
import 'graphql_service_imports.dart';

abstract interface class GraphQLService {
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? operationName,
  });
}

final class SupabaseGraphQLService implements GraphQLService {
  SupabaseGraphQLService({
    required this.envConfig,
    required this.supabaseService,
    Client? httpClient,
  }) : _httpClient = httpClient ?? Client();

  final EnvConfig envConfig;
  final SupabaseService supabaseService;
  final Client _httpClient;

  Uri get _endpoint {
    final base = envConfig.supabaseUrl.replaceAll(RegExp(r'/+$'), '');
    return Uri.parse('$base/graphql/v1');
  }

  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? operationName,
  }) async {
    final accessToken = supabaseService.currentSession?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthFailure(
        'Your admin session has expired. Please sign in again.',
        code: 'session_missing',
      );
    }

    final payload = <String, dynamic>{
      'query': document,
      'variables': variables,
      'operationName': ?operationName,
    };

    late final Response response;
    try {
      response = await _httpClient
          .post(
            _endpoint,
            headers: {
              'apikey': envConfig.supabasePublishableKey,
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw const NetworkFailure(
        'Request timed out while contacting Supabase GraphQL.',
        code: 'timeout',
      );
    } on ClientException catch (error) {
      throw NetworkFailure(
        'Network error contacting Supabase GraphQL: ${error.message}',
        code: 'client_error',
      );
    } catch (error) {
      throw NetworkFailure(
        'Failed to contact Supabase GraphQL: $error',
        code: 'network_error',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GraphQLErrorMapper.mapHttpStatus(
        response.statusCode,
        response.body,
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw const UnexpectedFailure('Invalid JSON returned from GraphQL API.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const UnexpectedFailure('Unexpected GraphQL response envelope.');
    }

    final errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      throw GraphQLErrorMapper.mapErrors(errors);
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw const UnexpectedFailure('GraphQL response did not include data.');
    }

    return data;
  }
}
