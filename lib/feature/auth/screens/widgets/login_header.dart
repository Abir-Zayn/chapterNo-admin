// Branding header displayed at the top of the admin sign-in card.
// Renders the ChapterNo badge, workspace title, and subtitle.
import 'imports/login_header_imports.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: palette.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            PhosphorIconsFill.graduationCap,
            size: 22,
            color: palette.onPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ChapterNo Admin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: palette.textPrimary,
                ),
              ),
              Text(
                'Internal Curriculum & MCQ Authoring',
                style: TextStyle(fontSize: 12.5, color: palette.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
