import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Carregando...'});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, style: AppText.secondary),
          ],
        ),
      );
}

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    color: AppColors.surface, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.accent, size: 30),
              ),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: AppText.section),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center, style: AppText.secondary),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 20),
                FilledButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      );
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.screenTitle),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: AppText.secondary),
            ],
          ],
        ),
      );
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: actionLabel != null ? 5 : 3),
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: AppColors.accent,
              onPressed: onAction)
          : null,
    ),
  );
}
