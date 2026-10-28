import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:geekhub/models/book.dart';
import 'package:geekhub/services/open_library_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  test('search converte resultados e codifica o termo', () async {
    late Uri captured;
    final service = OpenLibraryService(client: MockClient((req) async {
      captured = req.url;
      return _json({
        'numFound': 1,
        'docs': [
          {
            'key': '/works/OL1W',
            'title': 'Harry Potter',
            'author_name': ['J. K. Rowling'],
            'cover_i': 5,
          }
        ],
      });
    }));

    final result = await service.search('harry potter', SearchType.title);

    expect(captured.host, 'openlibrary.org');
    expect(captured.path, '/search.json');
    expect(captured.queryParameters['title'], 'harry potter');
    expect(result.total, 1);
    expect(result.books.single.id, 'OL1W');
    expect(result.books.single.coverId, 5);
  });

  test('search vazio não faz requisição', () async {
    var calls = 0;
    final service = OpenLibraryService(client: MockClient((req) async {
      calls++;
      return _json({'docs': []});
    }));
    final result = await service.search('   ', SearchType.title);
    expect(result.books, isEmpty);
    expect(calls, 0);
  });

  test('erro HTTP vira OpenLibraryException', () async {
    final service =
        OpenLibraryService(client: MockClient((req) async => _json({}, 500)));
    await expectLater(service.search('x', SearchType.title),
        throwsA(isA<OpenLibraryException>()));
  });

  test('falha de conexão vira OpenLibraryException', () async {
    final service = OpenLibraryService(
        client: MockClient((req) async => throw http.ClientException('sem rede')));
    await expectLater(service.search('x', SearchType.author),
        throwsA(isA<OpenLibraryException>()));
  });

  test('fetchDetails lê descrição em objeto, páginas e editoras', () async {
    final service = OpenLibraryService(client: MockClient((req) async {
      if (req.url.path.endsWith('/editions.json')) {
        return _json({
          'entries': [
            {'number_of_pages': 320, 'publishers': ['Rocco']},
          ],
        });
      }
      return _json({
        'description': {'type': '/type/text', 'value': 'Uma sinopse.'},
        'covers': [77],
      });
    }));

    final book = await service
        .fetchDetails(const Book(key: '/works/OL1W', title: 'Livro'));
    expect(book.description, 'Uma sinopse.');
    expect(book.pages, 320);
    expect(book.publishers, ['Rocco']);
    expect(book.coverId, 77);
  });
}
