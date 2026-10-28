import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';
import '../models/bookshelf_item.dart';
import '../state/bookshelf_controller.dart';
import '../widgets/app_chip.dart';
import '../widgets/book_card.dart';
import '../widgets/state_views.dart';
import 'book_details_screen.dart';

enum _Op { read, reading, saved, remove }

class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key, required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  ShelfFilter _filter = ShelfFilter.all;

  ReadingStatus? _statusFor(_Op op) => switch (op) {
        _Op.read => ReadingStatus.read,
        _Op.reading => ReadingStatus.reading,
        _Op.saved => ReadingStatus.saved,
        _Op.remove => null,
      };

  String _labelFor(_Op op) => switch (op) {
        _Op.read => 'Marcar como Lido',
        _Op.reading => 'Marcar como Lendo agora',
        _Op.saved => 'Marcar como apenas Salvo',
        _Op.remove => 'Remover da estante',
      };

  Future<void> _handle(_Op op, BookshelfItem item) async {
    final shelf = context.read<BookshelfController>();
    if (op == _Op.remove) {
      final ok = await shelf.remove(item.id);
      if (!mounted) return;
      showAppSnackBar(
        context,
        ok
            ? '“${item.title}” removida da estante.'
            : 'Não foi possível remover a obra.',
        actionLabel: ok ? 'Desfazer' : null,
        onAction: ok ? () => shelf.restore(item) : null,
      );
      return;
    }
    final status = _statusFor(op)!;
    final ok = await shelf.setStatus(item.id, status);
    if (!mounted) return;
    showAppSnackBar(
      context,
      ok
          ? 'Status atualizado: ${status.label}.'
          : 'Não foi possível atualizar o status.',
    );
  }

  int _countFor(BookshelfController shelf, ShelfFilter f) {
    final status = f.status;
    return status == null ? shelf.total : shelf.countOf(status);
  }

  @override
  Widget build(BuildContext context) {
    final shelf = context.watch<BookshelfController>();
    final items = shelf.filtered(_filter);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Minha Estante',
                subtitle: '${obrasLabel(shelf.total)} salvas',
              ),
              if (shelf.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(shelf.errorMessage!,
                                style: AppText.secondary)),
                        TextButton(
                            onPressed: shelf.dismissError,
                            child: const Text('Fechar')),
                      ],
                    ),
                  ),
                ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    for (final f in ShelfFilter.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChipButton(
                          label: '${f.label} (${_countFor(shelf, f)})',
                          selected: f == _filter,
                          onTap: () => setState(() => _filter = f),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _content(shelf, items)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BookshelfController shelf, List<BookshelfItem> items) {
    if (shelf.isLoading) {
      return const LoadingView(message: 'Abrindo estante...');
    }
    if (shelf.total == 0) {
      return MessageView(
        icon: Icons.collections_bookmark_outlined,
        title: 'Sua estante está vazia',
        message:
            'Pesquise livros e quadrinhos e adicione os que quiser acompanhar.',
        actionLabel: 'Descobrir livros',
        onAction: () => widget.onOpenTab(0),
      );
    }
    if (items.isEmpty) {
      return MessageView(
        icon: Icons.filter_list_off_rounded,
        title: 'Nenhuma obra aqui',
        message: 'Não há obras com o filtro “${_filter.label}”.',
        actionLabel: 'Ver todas',
        onAction: () => setState(() => _filter = ShelfFilter.all),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      gridDelegate: bookGridDelegate,
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return BookCard(
          title: item.title,
          authors: item.authorsLabel,
          year: item.firstPublishYear,
          coverUrl: item.coverUrl('M'),
          status: item.status,
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => BookDetailsScreen(book: item.toBook()),
          )),
          trailing: PopupMenuButton<_Op>(
            tooltip: 'Opções da obra',
            color: AppColors.surface,
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            onSelected: (op) => _handle(op, item),
            itemBuilder: (_) => [
              for (final op in _Op.values)
                if (_statusFor(op) != item.status)
                  PopupMenuItem<_Op>(
                    value: op,
                    child: Text(_labelFor(op), style: AppText.body),
                  ),
            ],
          ),
        );
      },
    );
  }
}
