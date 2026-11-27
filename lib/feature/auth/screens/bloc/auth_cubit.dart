// Cubit managing admin login, session restoration, and unauthorized blocking.
// Keeps auth transitions predictable for go_router redirects and LoginScreen.
import 'imports/auth_cubit_imports.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  Future<void> restoreSession() async {
    emit(state.copyWith(status: AuthStatus.checking, clearError: true));
    try {
      final admin = await _repository.restoreSession();
      if (admin == null) {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            clearAdminUser: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          adminUser: admin,
          clearError: true,
        ),
      );
    } on UnauthorizedAdminFailure catch (failure) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthorized,
          clearAdminUser: true,
          errorMessage: failure.message,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearAdminUser: true,
          errorMessage: failure.message,
        ),
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final admin = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          adminUser: admin,
          isSubmitting: false,
          clearError: true,
        ),
      );
    } on UnauthorizedAdminFailure catch (failure) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthorized,
          clearAdminUser: true,
          isSubmitting: false,
          errorMessage: failure.message,
        ),
      );
    } on AppFailure catch (failure) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearAdminUser: true,
          isSubmitting: false,
          errorMessage: failure.message,
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _repository.signOut();
    } finally {
      emit(
        const AuthState(
          status: AuthStatus.unauthenticated,
          isSubmitting: false,
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
