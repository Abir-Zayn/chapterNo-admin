// Branding header displayed at the top of the admin sign-in card.
// Renders the ChapterNo badge, workspace title, and subtitle.
import 'imports/login_header_imports.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final text = context.theme.typography.body;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            FPhosphorIcons.graduationCap,
            size: 22,
            color: colors.primaryForeground,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ChapterNo Admin',
                style: text.xl.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.foreground,
                ),
              ),
              Text(
                'Internal Curriculum & MCQ Authoring',
                style: text.sm.copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
