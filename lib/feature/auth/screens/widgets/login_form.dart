// Keyboard-friendly admin sign-in form with error banner and submit state.
// Dispatches sign-in and error-clear actions to AuthCubit.
import 'imports/login_form_imports.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
                FTextFormField(
                  control: .managed(controller: _emailController),
                  enabled: !state.isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  label: const Text('Admin Email'),
                  hint: 'editor@chapterno.com',
                  validator: LoginValidators.email,
                ),
                const SizedBox(height: 14),
                FTextFormField.password(
                  control: .managed(controller: _passwordController),
                  enabled: !state.isSubmitting,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  label: const Text('Password'),
                  onSubmit: (_) => _submit(),
                  validator: LoginValidators.password,
                ),
                const SizedBox(height: 20),
                FButton(
                  onPress: state.isSubmitting ? null : _submit,
                  child: state.isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.theme.colors.primaryForeground,
                          ),
                        )
                      : const Flexible(
                          child: Text(
                            'Sign In to Admin Workspace',
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Student accounts are blocked automatically. Access is verified via server-side Postgres RLS.',
                  textAlign: TextAlign.center,
                  style: context.theme.typography.body.sm.copyWith(
                    color: context.theme.colors.mutedForeground,
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
