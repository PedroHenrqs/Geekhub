import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/bookshelf_item.dart';
import '../state/bookshelf_controller.dart';
import '../widgets/stat_widgets.dart';
import '../widgets/state_views.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key, required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final shelf = context.watch<BookshelfController>();
    final total = shelf.total;
    final read = shelf.countOf(ReadingStatus.read);
    final reading = shelf.countOf(ReadingStatus.reading);
    final saved = shelf.countOf(ReadingStatus.saved);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                  title: 'Estatísticas', subtitle: 'Seu progresso de leitura'),
              Expanded(
                child: total == 0
                    ? MessageView(
                        icon: Icons.bar_chart_rounded,
                        title: 'Ainda não há dados',
                        message:
                            'Adicione obras à estante para acompanhar suas estatísticas.',
                        actionLabel: 'Descobrir livros',
                        onAction: () => onOpenTab(0),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        children: [
                          GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 260,
                              mainAxisExtent: 104,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            children: [
                              StatCard(
                                  label: 'Obras salvas',
                                  value: total,
                                  icon: Icons.collections_bookmark_rounded,
                                  color: AppColors.textPrimary),
                              StatCard(
                                  label: 'Lidas',
                                  value: read,
                                  icon: Icons.check_circle_rounded,
                                  color: AppColors.success),
                              StatCard(
                                  label: 'Lendo agora',
                                  value: reading,
                                  icon: Icons.auto_stories_rounded,
                                  color: AppColors.accent),
                              StatCard(
                                  label: 'Salvas (sem status)',
                                  value: saved,
                                  icon: Icons.bookmark_rounded,
                                  color: AppColors.warning),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _Panel(
                            title: 'Progresso geral',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: read / total,
                                    minHeight: 10,
                                    backgroundColor: AppColors.border,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$read de $total obras lidas (${(read / total * 100).round()}%)',
                                  style: AppText.secondary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Panel(
                            title: 'Distribuição por status',
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 32,
                              runSpacing: 20,
                              children: [
                                StatusDonutChart(
                                    read: read, reading: reading, saved: saved),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _LegendRow(
                                        color: AppColors.success,
                                        label: 'Lidas',
                                        value: read),
                                    _LegendRow(
                                        color: AppColors.accent,
                                        label: 'Lendo agora',
                                        value: reading),
                                    _LegendRow(
                                        color: AppColors.warning,
                                        label: 'Salvas (sem status)',
                                        value: saved),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.section),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

class _LegendRow extends StatelessWidget {
  const _LegendRow(
      {required this.color, required this.label, required this.value});
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text('$label: ', style: AppText.secondary),
            Text('$value', style: AppText.cardTitle),
          ],
        ),
      );
}
