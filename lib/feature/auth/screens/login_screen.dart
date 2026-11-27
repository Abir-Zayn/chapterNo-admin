// Admin sign-in screen hosting the centered LoginForm card.
// Uses solid #FFFFFF card on #FCFCFB canvas with 1dp #E4E4E7 border.
import 'imports/login_screen_imports.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.canvas,
      body: SelectionArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: const LoginForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
