// Thin abstraction over SupabaseClient for auth and RPC invocations.
// Allows data repositories to be unit-tested cleanly without live network calls.
import 'imports/supabase_service_imports.dart';

abstract interface class SupabaseService {
  Session? get currentSession;

  Stream<AuthState> get onAuthStateChange;

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params});
}

final class LiveSupabaseService implements SupabaseService {
  LiveSupabaseService(this._client);

  final SupabaseClient _client;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) {
    return _client.rpc(functionName, params: params);
  }
}
