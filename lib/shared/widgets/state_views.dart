// Shared loading, empty, validation-error banner, and retry widgets.
// Uses solid white #FFFFFF cards with 1dp #E4E4E7 borders and zero blur.
import 'imports/state_views_imports.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message = 'Loading workspace...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = PhosphorIconsRegular.tray,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: palette.textSecondary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: palette.textSecondary),
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({
    super.key,
    required this.message,
    this.title,
    this.onDismiss,
  });

  final String message;
  final String? title;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.errorTint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: palette.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              PhosphorIconsRegular.warningCircle,
              size: 18,
              color: palette.error,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      color: palette.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(color: palette.textPrimary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(PhosphorIconsRegular.x, size: 16),
              visualDensity: VisualDensity.compact,
              tooltip: 'Dismiss',
            ),
        ],
      ),
    );
  }
}

class AppRetryView extends StatelessWidget {
  const AppRetryView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Unable to load data',
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyView(
      title: title,
      subtitle: message,
      icon: PhosphorIconsRegular.warningOctagon,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(PhosphorIconsRegular.arrowClockwise, size: 16),
        label: const Text('Retry'),
      ),
    );
  }
}

class AppErrorScene extends StatelessWidget {
  const AppErrorScene({
    super.key,
    required this.message,
    required this.onRetry,
    this.statusCode,
    this.onSignOut,
  });

  final int? statusCode;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final code = statusCode ?? 500;
    final (title, icon) = switch (code) {
      401 => ('Session Expired (401)', PhosphorIconsRegular.lockKey),
      403 => ('Access Denied (403)', PhosphorIconsRegular.shieldWarning),
      404 => ('Not Found (404)', PhosphorIconsRegular.magnifyingGlassMinus),
      503 ||
      504 => ('Connection Unavailable ($code)', PhosphorIconsRegular.wifiSlash),
      _ => (
        'Something Went Wrong ($code)',
        PhosphorIconsRegular.warningOctagon,
      ),
    };

    return AppEmptyView(
      title: title,
      subtitle: message,
      icon: icon,
      action: Wrap(
        spacing: 10,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          if (code == 401 && onSignOut != null)
            FilledButton.icon(
              onPressed: onSignOut,
              icon: const Icon(PhosphorIconsRegular.signOut, size: 16),
              label: const Text('Sign In Again'),
            )
          else
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(PhosphorIconsRegular.arrowClockwise, size: 16),
              label: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}

void showAppErrorSnackBar(
  BuildContext context, {
  required String message,
  int? statusCode,
}) {
  final palette = AppPalette.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final prefix = statusCode != null ? 'Error $statusCode: ' : 'Error: ';
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.primary,
        content: Row(
          children: [
            Icon(
              PhosphorIconsRegular.warningCircle,
              size: 18,
              color: palette.onPrimary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$prefix$message',
                style: TextStyle(color: palette.onPrimary, fontSize: 13),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: palette.onPrimary,
          onPressed: () => messenger.hideCurrentSnackBar(),
        ),
      ),
    );
}
