import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/bookshelf_item.dart';
import 'book_cover.dart';
import 'status_chip.dart';

/// Grade responsiva: 1 coluna no celular, mais colunas em telas largas.
const SliverGridDelegate bookGridDelegate =
    SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 520,
  mainAxisExtent: 160,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
);

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.title,
    required this.authors,
    required this.onTap,
    this.year,
    this.coverUrl,
    this.status,
    this.trailing,
  });

  final String title;
  final String authors;
  final int? year;
  final String? coverUrl;
  final ReadingStatus? status;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(
                  url: coverUrl, width: 72, semanticLabel: 'Capa de $title'),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.cardTitle),
                    const SizedBox(height: 4),
                    Text(authors,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.secondary),
                    const SizedBox(height: 4),
                    Text(
                      year != null ? 'Publicado em $year' : 'Ano não informado',
                      style: AppText.caption,
                    ),
                    if (status != null) ...[
                      const SizedBox(height: 6),
                      StatusChip(status: status!),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

/// Card vertical usado no carrossel da Home.
class BookPosterCard extends StatelessWidget {
  const BookPosterCard({
    super.key,
    required this.title,
    required this.authors,
    required this.onTap,
    this.coverUrl,
    this.status,
    this.width = 132,
  });

  final String title;
  final String authors;
  final String? coverUrl;
  final ReadingStatus? status;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                BookCover(
                    url: coverUrl,
                    width: width,
                    semanticLabel: 'Capa de $title'),
                if (status != null)
                  Positioned(
                      top: 6, left: 6, child: StatusChip(status: status!)),
              ],
            ),
            const SizedBox(height: 8),
            Text(title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.cardTitle),
            const SizedBox(height: 2),
            Text(authors,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
