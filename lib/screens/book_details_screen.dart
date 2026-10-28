import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/book.dart';
import '../models/bookshelf_item.dart';
import '../services/open_library_service.dart';
import '../state/bookshelf_controller.dart';
import '../widgets/book_cover.dart';
import '../widgets/state_views.dart';
import '../widgets/status_chip.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key, required this.book});
  final Book book;

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  late Book _book = widget.book;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final service = context.read<OpenLibraryService>();
    try {
      final detailed = await service.fetchDetails(_book);
      if (!mounted) return;
      setState(() {
        _book = detailed;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = friendlyError(e);
      });
    }
  }

  void _retry() {
    setState(() {
      _loading = true;
      _error = null;
    });
    _fetch();
  }

  Future<void> _setStatus(ReadingStatus target) async {
    final shelf = context.read<BookshelfController>();
    final wasSaved = shelf.contains(_book.id);
    final ok = await shelf.addOrUpdate(_book, target);
    if (!mounted) return;
    showAppSnackBar(
      context,
      !ok
          ? 'Não foi possível salvar. Tente novamente.'
          : !wasSaved
              ? 'Obra adicionada à estante (${target.label}).'
              : 'Status atualizado: ${target.label}.',
    );
  }

  // Tocar no status já ativo volta a obra para "Salvo".
  void _onStatusButton(ReadingStatus tapped, ReadingStatus? current) =>
      _setStatus(current == tapped ? ReadingStatus.saved : tapped);

  Future<void> _remove() async {
    final shelf = context.read<BookshelfController>();
    final item = shelf.find(_book.id);
    if (item == null) return;
    final ok = await shelf.remove(_book.id);
    if (!mounted) return;
    showAppSnackBar(
      context,
      ok ? 'Obra removida da estante.' : 'Não foi possível remover a obra.',
      actionLabel: ok ? 'Desfazer' : null,
      onAction: ok ? () => shelf.restore(item) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = context.watch<BookshelfController>().statusOf(_book.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const Text('Detalhes'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 640;
                  final info = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_book.title, style: AppText.title),
                      const SizedBox(height: 6),
                      Text(_book.authorsLabel, style: AppText.secondary),
                      if (current != null) ...[
                        const SizedBox(height: 10),
                        StatusChip(status: current),
                      ],
                      const SizedBox(height: 20),
                      _meta(),
                      const SizedBox(height: 20),
                      _actions(current),
                    ],
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BookCover(
                                url: _book.coverUrl('L'),
                                width: 240,
                                radius: 16,
                                semanticLabel: 'Capa de ${_book.title}'),
                            const SizedBox(width: 28),
                            Expanded(child: info),
                          ],
                        )
                      else ...[
                        Center(
                          child: BookCover(
                              url: _book.coverUrl('L'),
                              width: 180,
                              radius: 16,
                              semanticLabel: 'Capa de ${_book.title}'),
                        ),
                        const SizedBox(height: 20),
                        info,
                      ],
                      const SizedBox(height: 28),
                      _synopsis(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta() {
    final waiting = _loading ? 'Carregando...' : null;
    return Column(
      children: [
        _MetaRow(
          icon: Icons.event_rounded,
          label: 'Ano de publicação',
          value: _book.firstPublishYear?.toString(),
        ),
        _MetaRow(
          icon: Icons.business_rounded,
          label: 'Editora',
          value: _book.publishers.isEmpty ? null : _book.publishers.join(', '),
          placeholder: waiting,
        ),
        _MetaRow(
          icon: Icons.menu_book_rounded,
          label: 'Páginas',
          value: _book.pages?.toString(),
          placeholder: waiting,
        ),
      ],
    );
  }

  Widget _actions(ReadingStatus? current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (current == null)
          FilledButton.icon(
            onPressed: () => _setStatus(ReadingStatus.saved),
            icon: const Icon(Icons.bookmark_add_rounded),
            label: const Text('Adicionar à estante'),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Esta obra está na sua estante',
                      style: AppText.body),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _statusButton(ReadingStatus.reading, current)),
            const SizedBox(width: 12),
            Expanded(child: _statusButton(ReadingStatus.read, current)),
          ],
        ),
        if (current != null)
          TextButton.icon(
            onPressed: _remove,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Remover da estante'),
          ),
      ],
    );
  }

  Widget _statusButton(ReadingStatus status, ReadingStatus? current) {
    final selected = current == status;
    final label = Text(status.label, textAlign: TextAlign.center);
    final icon = Icon(selected ? Icons.check_rounded : statusIcon(status));
    void onPressed() => _onStatusButton(status, current);
    return selected
        ? FilledButton.icon(onPressed: onPressed, icon: icon, label: label)
        : OutlinedButton.icon(onPressed: onPressed, icon: icon, label: label);
  }

  Widget _synopsis() {
    final Widget content;
    if (_book.description != null) {
      content = Text(_book.description!, style: AppText.body);
    } else if (_loading) {
      content = const Row(
        children: [
          SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 10),
          Text('Carregando sinopse...', style: AppText.secondary),
        ],
      );
    } else if (_error != null) {
      content = const Text('Não foi possível carregar a sinopse.',
          style: AppText.secondary);
    } else {
      content = const Text('Informação não disponível',
          style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: AppColors.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Detalhes incompletos: $_error',
                    style: AppText.secondary,
                  ),
                ),
                TextButton(
                    onPressed: _retry, child: const Text('Tentar de novo')),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Text('Sinopse', style: AppText.section),
        const SizedBox(height: 8),
        content,
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.placeholder,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppText.caption),
                const SizedBox(height: 2),
                value != null
                    ? Text(value!, style: AppText.body)
                    : Text(
                        placeholder ?? 'Informação não disponível',
                        style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
