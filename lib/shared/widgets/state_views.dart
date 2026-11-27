// Shared loading, empty, validation-error banner, and retry widgets.
import 'imports/state_views_imports.dart';

class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, this.message = 'Loading workspace...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FCircularProgress(),
          const SizedBox(height: 14),
          Text(
            message,
            style: context.theme.typography.body.sm.copyWith(
              color: colors.mutedForeground,
            ),
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
    this.icon = FPhosphorIcons.tray,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 32, color: colors.mutedForeground),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: context.theme.typography.body.sm.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
                if (action != null) ...[const SizedBox(height: 18), action!],
              ],
              ),
            ),
          ),
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
    return Stack(
      children: [
        FAlert(
          variant: .destructive,
          icon: const Icon(FPhosphorIcons.warningCircle),
          title: Text(title ?? 'Error'),
          subtitle: Text(message),
        ),
        if (onDismiss != null)
          Positioned(
            top: 0,
            right: 0,
            child: FButton(
              variant: .ghost,
              size: .sm,
              mainAxisSize: MainAxisSize.min,
              onPress: onDismiss,
              child: const Icon(FPhosphorIcons.x, size: 14),
            ),
          ),
      ],
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
      icon: FPhosphorIcons.warningOctagon,
      action: FButton(
        prefix: const Icon(FPhosphorIcons.arrowClockwise, size: 16),
        onPress: onRetry,
        child: const Text('Retry'),
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
      401 => ('Session Expired (401)', FPhosphorIcons.lockKey),
      403 => ('Access Denied (403)', FPhosphorIcons.shieldWarning),
      404 => ('Not Found (404)', FPhosphorIcons.magnifyingGlassMinus),
      503 ||
      504 => ('Connection Unavailable ($code)', FPhosphorIcons.wifiSlash),
      _ => ('Something Went Wrong ($code)', FPhosphorIcons.warningOctagon),
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
            FButton(
              prefix: const Icon(FPhosphorIcons.signOut, size: 16),
              onPress: onSignOut,
              child: const Text('Sign In Again'),
            )
          else
            FButton(
              prefix: const Icon(FPhosphorIcons.arrowClockwise, size: 16),
              onPress: onRetry,
              child: const Text('Retry'),
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
  showFToast(
    context: context,
    variant: .destructive,
    title: Text(statusCode == null ? message : 'Error $statusCode: $message'),
  );
}
