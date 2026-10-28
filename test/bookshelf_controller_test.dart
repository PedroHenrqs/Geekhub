import 'package:flutter_test/flutter_test.dart';
import 'package:geekhub/models/book.dart';
import 'package:geekhub/models/bookshelf_item.dart';
import 'package:geekhub/repositories/bookshelf_repository.dart';
import 'package:geekhub/state/bookshelf_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const book = Book(key: '/works/OL1W', title: 'Livro A');

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<BookshelfController> create() async {
    final c = BookshelfController(BookshelfRepository());
    await c.load();
    return c;
  }

  test('adiciona sem duplicar e atualiza status', () async {
    final c = await create();
    expect(await c.addOrUpdate(book, ReadingStatus.saved), isTrue);
    expect(await c.addOrUpdate(book, ReadingStatus.reading), isTrue);
    expect(c.total, 1);
    expect(c.statusOf('OL1W'), ReadingStatus.reading);
  });

  test('contadores e filtros refletem a estante', () async {
    final c = await create();
    await c.addOrUpdate(book, ReadingStatus.read);
    await c.addOrUpdate(
        const Book(key: '/works/OL2W', title: 'B'), ReadingStatus.reading);
    expect(c.countOf(ReadingStatus.read), 1);
    expect(c.countOf(ReadingStatus.reading), 1);
    expect(c.filtered(ShelfFilter.read).length, 1);
    expect(c.filtered(ShelfFilter.all).length, 2);
  });

  test('remove e restaura', () async {
    final c = await create();
    await c.addOrUpdate(book, ReadingStatus.saved);
    final item = c.find('OL1W')!;
    await c.remove('OL1W');
    expect(c.total, 0);
    await c.restore(item);
    expect(c.total, 1);
  });

  test('persiste após "reiniciar" (novo controller)', () async {
    final c1 = await create();
    await c1.addOrUpdate(book, ReadingStatus.read);
    final c2 = await create();
    expect(c2.total, 1);
    expect(c2.statusOf('OL1W'), ReadingStatus.read);
  });
}
