import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/format.dart';
import '../models/bookshelf_item.dart';
import '../services/open_library_service.dart';
import '../state/bookshelf_controller.dart';
import '../widgets/app_chip.dart';
import '../widgets/book_card.dart';
import '../widgets/search_field.dart';
import '../widgets/state_views.dart';
import 'book_details_screen.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenTab});
  final ValueChanged<int> onOpenTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  SearchType _type = SearchType.title;
  String? _errorText;
  int _categoryIndex = 0;
  late Future<SearchResult> _discoveryFuture;

  @override
  void initState() {
    super.initState();
    _discoveryFuture = _fetchDiscovery();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<SearchResult> _fetchDiscovery() => context
      .read<OpenLibraryService>()
      .discover(AppConstants.categories[_categoryIndex].subject);

  void _submit([String? _]) {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() => _errorText = 'Digite um título ou autor para pesquisar.');
      return;
    }
    setState(() => _errorText = null);
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => SearchResultsScreen(query: query, type: _type),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final shelf = context.watch<BookshelfController>();

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.auto_stories_rounded,
                        color: AppColors.accent),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppConstants.appName, style: AppText.section),
                      Text('Livros, mangás e quadrinhos',
                          style: AppText.caption),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('O que vamos ler hoje?', style: AppText.title),
              const SizedBox(height: 16),
              SearchField(
                controller: _controller,
                errorText: _errorText,
                onSubmitted: _submit,
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
              ),
              const SizedBox(height: 12),
              SearchTypeSelector(
                value: _type,
                onChanged: (t) => setState(() => _type = t),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ShortcutCard(
                      icon: Icons.collections_bookmark_rounded,
                      title: 'Minha estante',
                      subtitle: obrasLabel(shelf.total),
                      onTap: () => widget.onOpenTab(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ShortcutCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'Estatísticas',
                      subtitle:
                          '${shelf.countOf(ReadingStatus.read)} lidos · ${shelf.countOf(ReadingStatus.reading)} lendo',
                      onTap: () => widget.onOpenTab(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text('Em destaque', style: AppText.section),
              const SizedBox(height: 4),
              const Text('Obras bem avaliadas na Open Library',
                  style: AppText.secondary),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < AppConstants.categories.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChipButton(
                          label: AppConstants.categories[i].label,
                          selected: i == _categoryIndex,
                          onTap: () => setState(() {
                            _categoryIndex = i;
                            _discoveryFuture = _fetchDiscovery();
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDiscovery(shelf),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscovery(BookshelfController shelf) {
    return FutureBuilder<SearchResult>(
      future: _discoveryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
              height: 240, child: LoadingView(message: 'Buscando sugestões...'));
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 260,
            child: MessageView(
              icon: Icons.wifi_off_rounded,
              title: 'Não foi possível carregar as sugestões',
              message: friendlyError(snapshot.error),
              actionLabel: 'Tentar novamente',
              onAction: () =>
                  setState(() => _discoveryFuture = _fetchDiscovery()),
            ),
          );
        }
        final books = snapshot.data?.books ?? const [];
        if (books.isEmpty) {
          return const SizedBox(
            height: 220,
            child: MessageView(
              icon: Icons.search_off_rounded,
              title: 'Sem sugestões agora',
              message: 'Use a busca acima para encontrar um título ou autor.',
            ),
          );
        }
        return SizedBox(
          height: 320,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final b = books[i];
              return BookPosterCard(
                title: b.title,
                authors: b.authorsLabel,
                coverUrl: b.coverUrl('M'),
                status: shelf.statusOf(b.id),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => BookDetailsScreen(book: b),
                )),
              );
            },
          ),
        );
      },
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(height: 10),
              Text(title, style: AppText.cardTitle),
              const SizedBox(height: 2),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption),
            ],
          ),
        ),
      ),
    );
  }
}
