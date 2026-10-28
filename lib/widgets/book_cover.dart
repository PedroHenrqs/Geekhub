import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.url,
    this.width,
    this.radius = 10,
    this.semanticLabel,
  });

  final String? url;
  final double? width;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Widget content = url == null
        ? const _CoverFallback()
        : Image.network(
            url!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const _CoverPlaceholder(),
            errorBuilder: (context, error, stack) => const _CoverFallback(),
          );

    final cover = Semantics(
      image: true,
      label: semanticLabel ?? 'Capa do livro',
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: ColoredBox(color: AppColors.surfaceSecondary, child: content),
        ),
      ),
    );
    return width == null ? cover : SizedBox(width: width, child: cover);
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) => const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) => const Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded,
                    color: AppColors.textSecondary, size: 32),
                SizedBox(height: 4),
                Text('Sem capa', style: AppText.caption),
              ],
            ),
          ),
        ),
      );
}
