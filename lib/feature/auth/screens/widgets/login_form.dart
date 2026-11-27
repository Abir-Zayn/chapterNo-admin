// Keyboard-friendly admin sign-in form with error banner and submit state.
// Dispatches sign-in and error-clear actions to AuthCubit.
import 'login_form_imports.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isUnauthorized = state.status == AuthStatus.unauthorized;
        return Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LoginHeader(),
                const SizedBox(height: 22),
                if (state.errorMessage != null) ...[
                  AppErrorBanner(
                    title: isUnauthorized
                        ? 'Unauthorized Account'
                        : 'Sign-In Error',
                    message: state.errorMessage!,
                    onDismiss: () => context.read<AuthCubit>().clearError(),
                  ),
                  const SizedBox(height: 18),
                ],
                TextFormField(
                  controller: _emailController,
                  enabled: !state.isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'Admin Email',
                    hintText: 'editor@chapterno.com',
                    prefixIcon: Icon(
                      PhosphorIconsRegular.envelopeSimple,
                      size: 18,
                    ),
                  ),
                  validator: LoginValidators.email,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  enabled: !state.isSubmitting,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      PhosphorIconsRegular.lockSimple,
                      size: 18,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? PhosphorIconsRegular.eye
                            : PhosphorIconsRegular.eyeSlash,
                        size: 18,
                      ),
                    ),
                  ),
                  validator: LoginValidators.password,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Sign In to Admin Workspace'),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Student accounts are blocked automatically. Access is verified via server-side Postgres RLS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
