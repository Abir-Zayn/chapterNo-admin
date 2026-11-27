// Lightweight Supabase pg_graphql client with dynamic JWT header injection.
// Sends queries and mutations to /graphql/v1 and maps errors into AppFailure.
import 'imports/graphql_service_imports.dart';

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

    final opLabel = operationName ?? 'AnonymousOperation';
    final payload = <String, dynamic>{
      'query': document,
      'variables': variables,
      'operationName': ?operationName,
    };

    AppLogger.log(
      '[GraphQL] -> $opLabel | endpoint=$_endpoint | variables=${jsonEncode(variables)}',
    );
    final stopwatch = Stopwatch()..start();

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
      stopwatch.stop();
      AppLogger.log(
        '[GraphQL][TIMEOUT] $opLabel (${stopwatch.elapsedMilliseconds}ms)',
      );
      throw const NetworkFailure(
        'Request timed out. Please check your connection and try again.',
        code: 'timeout',
        statusCode: 504,
      );
    } on ClientException catch (error) {
      stopwatch.stop();
      AppLogger.log(
        '[GraphQL][NETWORK_ERROR] $opLabel (${stopwatch.elapsedMilliseconds}ms): ${error.message}',
      );
      throw const NetworkFailure(
        'Unable to connect to the server. Please check your network and try again.',
        code: 'client_error',
        statusCode: 503,
      );
    } catch (error) {
      stopwatch.stop();
      AppLogger.log(
        '[GraphQL][ERROR] $opLabel (${stopwatch.elapsedMilliseconds}ms): $error',
      );
      throw const NetworkFailure(
        'Unable to connect to the server. Please try again.',
        code: 'network_error',
        statusCode: 503,
      );
    }

    stopwatch.stop();
    AppLogger.log(
      '[GraphQL] <- $opLabel (${stopwatch.elapsedMilliseconds}ms) | HTTP ${response.statusCode}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      AppLogger.log(
        '[GraphQL][HTTP_ERROR] $opLabel | status=${response.statusCode} | body=${response.body}',
      );
      throw GraphQLErrorMapper.mapHttpStatus(
        response.statusCode,
        response.body,
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      AppLogger.log(
        '[GraphQL][JSON_ERROR] $opLabel | rawBody=${response.body}',
      );
      throw const UnexpectedFailure(
        'Something went wrong while reading the server response.',
        code: 'invalid_json',
        statusCode: 500,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      AppLogger.log('[GraphQL][ENVELOPE_ERROR] $opLabel | decoded=$decoded');
      throw const UnexpectedFailure(
        'Something went wrong while reading the server response.',
        code: 'invalid_envelope',
        statusCode: 500,
      );
    }

    final errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      AppLogger.log(
        '[GraphQL][GRAPHQL_ERRORS] $opLabel | errors=${jsonEncode(errors)}',
      );
      throw GraphQLErrorMapper.mapErrors(errors);
    }

    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      AppLogger.log('[GraphQL][DATA_ERROR] $opLabel | body=${response.body}');
      throw const UnexpectedFailure(
        'Something went wrong while loading data. Please try again.',
        code: 'missing_data',
        statusCode: 500,
      );
    }

    return data;
  }
}
