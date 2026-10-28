import 'package:flutter_test/flutter_test.dart';
import 'package:geekhub/models/book.dart';
import 'package:geekhub/models/bookshelf_item.dart';
import 'package:geekhub/models/json_utils.dart';

void main() {
  group('Book.fromSearchJson', () {
    test('converte campos completos', () {
      final b = Book.fromSearchJson({
        'key': '/works/OL1W',
        'title': 'Batman',
        'author_name': ['Bob Kane', 'Bill Finger'],
        'first_publish_year': 1940,
        'cover_i': 123,
        'number_of_pages_median': 200,
        'publisher': ['DC'],
      });
      expect(b.id, 'OL1W');
      expect(b.authors.length, 2);
      expect(b.coverUrl('M'), 'https://covers.openlibrary.org/b/id/123-M.jpg');
      expect(b.pages, 200);
    });

    test('aceita campos ausentes sem lançar erro', () {
      final b = Book.fromSearchJson({'key': '/works/OL2W'});
      expect(b.title, 'Título não informado');
      expect(b.authorsLabel, 'Autor não informado');
      expect(b.coverUrl(), isNull);
      expect(b.firstPublishYear, isNull);
    });

    test('ignora cover_i inválido', () {
      final b = Book.fromSearchJson({'key': '/works/OL3W', 'cover_i': -1});
      expect(b.coverId, isNull);
    });
  });

  group('parseDescription', () {
    test('texto simples', () => expect(parseDescription(' Olá '), 'Olá'));
    test(
        'objeto com value',
        () => expect(
            parseDescription({'type': '/type/text', 'value': 'Texto'}),
            'Texto'));
    test('nulo, vazio e tipo inválido', () {
      expect(parseDescription(null), isNull);
      expect(parseDescription('  '), isNull);
      expect(parseDescription(42), isNull);
    });
  });

  group('BookshelfItem', () {
    test('serializa e desserializa', () {
      final item = BookshelfItem.fromBook(
          const Book(key: '/works/OL9W', title: 'X', authors: ['A']),
          ReadingStatus.read);
      final copy = BookshelfItem.fromJson(item.toJson());
      expect(copy.id, 'OL9W');
      expect(copy.status, ReadingStatus.read);
    });

    test('status desconhecido vira saved', () {
      expect(ReadingStatus.fromName('xyz'), ReadingStatus.saved);
    });

    test('registro inválido lança FormatException', () {
      expect(() => BookshelfItem.fromJson({'title': 'sem id'}),
          throwsFormatException);
    });
  });
}
