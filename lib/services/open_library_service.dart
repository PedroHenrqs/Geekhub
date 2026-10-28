import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/book.dart';
import '../models/json_utils.dart';

enum SearchType {
  title('title', 'Título'),
  author('author', 'Autor'),
  subject('subject', 'Assunto');

  const SearchType(this.param, this.label);
  final String param;
  final String label;
}

class SearchResult {
  const SearchResult({required this.books, required this.total});
  final List<Book> books;
  final int total;
}

class OpenLibraryException implements Exception {
  const OpenLibraryException(this.message);
  final String message;

  @override
  String toString() => message;
}

String friendlyError(Object? error) => error is OpenLibraryException
    ? error.message
    : 'Algo deu errado. Tente novamente.';

class OpenLibraryService {
  OpenLibraryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final Map<String, SearchResult> _cache = {};

  static const String _searchFields =
      'key,title,author_name,first_publish_year,cover_i,number_of_pages_median,publisher';

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        // Navegadores proíbem definir User-Agent.
        if (!kIsWeb) 'User-Agent': AppConstants.userAgent,
      };

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConstants.requestTimeout);
      if (response.statusCode == 429) {
        throw const OpenLibraryException(
            'Muitas requisições. Aguarde um instante e tente novamente.');
      }
      if (response.statusCode != 200) {
        throw OpenLibraryException(
            'O servidor respondeu com erro (${response.statusCode}). Tente novamente.');
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const OpenLibraryException('Resposta inesperada do servidor.');
      }
      return decoded;
    } on OpenLibraryException {
      rethrow;
    } on TimeoutException {
      throw const OpenLibraryException(
          'A conexão demorou demais. Verifique sua internet e tente novamente.');
    } on http.ClientException {
      throw const OpenLibraryException(
          'Sem conexão com a Open Library. Verifique sua internet.');
    } on FormatException {
      throw const OpenLibraryException('Resposta inválida do servidor.');
    } catch (_) {
      throw const OpenLibraryException(
          'Não foi possível concluir a requisição.');
    }
  }

  /// Pesquisa obras. Termos são codificados por Uri.https.
  Future<SearchResult> search(String query, SearchType type,
      {String? sort}) async {
    final term = query.trim();
    if (term.isEmpty) return const SearchResult(books: [], total: 0);

    final cacheKey = '${type.name}|${term.toLowerCase()}|${sort ?? ''}';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final limit = type == SearchType.subject
        ? AppConstants.discoveryLimit
        : AppConstants.searchLimit;
    final uri = Uri.https(AppConstants.apiHost, '/search.json', {
      type.param: term,
      'limit': '$limit',
      'fields': _searchFields,
      if (sort != null) 'sort': sort,
    });

    final json = await _getJson(uri);
    final docs = json['docs'];
    final books = docs is List
        ? docs
            .whereType<Map<String, dynamic>>()
            .map(Book.fromSearchJson)
            .where((b) => b.id.isNotEmpty)
            .toList()
        : <Book>[];
    final numFound = json['numFound'];
    final result = SearchResult(
      books: books,
      total: numFound is int ? numFound : books.length,
    );
    _cache[cacheKey] = result;
    return result;
  }

  /// Sugestões da Home: obras reais por assunto, ordenadas por avaliação.
  Future<SearchResult> discover(String subject) =>
      search(subject, SearchType.subject, sort: 'rating');

  /// Complementa a obra com sinopse, capa, editoras e páginas.
  /// Falha ao buscar a obra lança exceção; falha nas edições é ignorada
  /// (informação editorial é "melhor esforço").
  Future<Book> fetchDetails(Book book) async {
    final work = await _getJson(
        Uri.https(AppConstants.apiHost, '/works/${book.id}.json'));

    var coverId = book.coverId;
    if (coverId == null && work['covers'] is List) {
      for (final c in work['covers'] as List) {
        final v = asPositiveInt(c);
        if (v != null) {
          coverId = v;
          break;
        }
      }
    }

    int? pages = book.pages;
    var publishers = book.publishers;
    try {
      final editions = await _getJson(Uri.https(
          AppConstants.apiHost,
          '/works/${book.id}/editions.json',
          {'limit': '20'}));
      final entries = editions['entries'];
      if (entries is List) {
        final found = <String>[];
        for (final e in entries) {
          if (e is! Map<String, dynamic>) continue;
          pages ??= asPositiveInt(e['number_of_pages']);
          for (final p in asStringList(e['publishers'])) {
            if (found.length < 3 && !found.contains(p)) found.add(p);
          }
        }
        if (found.isNotEmpty) publishers = found;
      }
    } on OpenLibraryException {
      // Mantém os dados já conhecidos.
    }

    return book.copyWith(
      coverId: coverId,
      pages: pages,
      publishers: publishers,
      description: parseDescription(work['description']),
    );
  }

  void dispose() => _client.close();
}
