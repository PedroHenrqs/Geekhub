import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../services/open_library_service.dart';
import '../state/bookshelf_controller.dart';
import '../widgets/book_card.dart';
import '../widgets/search_field.dart';
import '../widgets/state_views.dart';
import 'book_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen(
      {super.key, required this.query, required this.type});
  final String query;
  final SearchType type;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.query);
  late SearchType _type = widget.type;
  late String _activeQuery = widget.query;
  late SearchType _activeType = widget.type;
  late Future<SearchResult> _future;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _future = _run();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<SearchResult> _run() =>
      context.read<OpenLibraryService>().search(_activeQuery, _activeType);

  // Pesquisa só na confirmação (Enter/botão): evita requisições a cada tecla.
  void _submit([String? _]) {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() => _errorText = 'Digite um título ou autor para pesquisar.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _errorText = null;
      _activeQuery = query;
      _activeType = _type;
      _future = _run();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shelf = context.watch<BookshelfController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text('Busca por ${_activeType.label.toLowerCase()}'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SearchField(
                        controller: _controller,
                        errorText: _errorText,
                        onSubmitted: _submit,
                        onChanged: (_) {
                          if (_errorText != null) {
                            setState(() => _errorText = null);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      SearchTypeSelector(
                        value: _type,
                        onChanged: (t) => setState(() => _type = t),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<SearchResult>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const LoadingView(message: 'Buscando obras...');
                      }
                      if (snapshot.hasError) {
                        return MessageView(
                          icon: Icons.wifi_off_rounded,
                          title: 'Não foi possível buscar',
                          message: friendlyError(snapshot.error),
                          actionLabel: 'Tentar novamente',
                          onAction: () => setState(() => _future = _run()),
                        );
                      }
                      final result = snapshot.data;
                      final books = result?.books ?? const [];
                      if (result == null || books.isEmpty) {
                        return const MessageView(
                          icon: Icons.search_off_rounded,
                          title: 'Nenhuma obra encontrada',
                          message:
                              'Nenhuma obra encontrada. Tente outro título ou autor.',
                        );
                      }
                      final total = result.total;
                      final header = total > books.length
                          ? 'Mostrando ${books.length} de $total resultados para “$_activeQuery”'
                          : '$total ${total == 1 ? 'resultado' : 'resultados'} para “$_activeQuery”';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                            child: Text(header, style: AppText.secondary),
                          ),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                              gridDelegate: bookGridDelegate,
                              itemCount: books.length,
                              itemBuilder: (context, i) {
                                final b = books[i];
                                return BookCard(
                                  title: b.title,
                                  authors: b.authorsLabel,
                                  year: b.firstPublishYear,
                                  coverUrl: b.coverUrl('M'),
                                  status: shelf.statusOf(b.id),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          BookDetailsScreen(book: b),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
