import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/bookshelf_item.dart';
import '../repositories/bookshelf_repository.dart';

enum ShelfFilter {
  all('Todas'),
  read('Lidos'),
  reading('Lendo agora'),
  saved('Salvos');

  const ShelfFilter(this.label);
  final String label;

  ReadingStatus? get status => switch (this) {
        ShelfFilter.all => null,
        ShelfFilter.read => ReadingStatus.read,
        ShelfFilter.reading => ReadingStatus.reading,
        ShelfFilter.saved => ReadingStatus.saved,
      };
}

class BookshelfController extends ChangeNotifier {
  BookshelfController(this._repository);

  final BookshelfRepository _repository;
  List<BookshelfItem> _items = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get errorMessage => _error;
  int get total => _items.length;

  List<BookshelfItem> get items => _sorted(_items);

  List<BookshelfItem> filtered(ShelfFilter filter) {
    final status = filter.status;
    final list =
        status == null ? _items : _items.where((i) => i.status == status);
    return _sorted(list);
  }

  int countOf(ReadingStatus status) =>
      _items.where((i) => i.status == status).length;

  BookshelfItem? find(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  bool contains(String id) => find(id) != null;
  ReadingStatus? statusOf(String id) => find(id)?.status;

  List<BookshelfItem> _sorted(Iterable<BookshelfItem> source) =>
      List<BookshelfItem>.of(source)
        ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _repository.load();
      _error = null;
    } catch (_) {
      _items = [];
      _error = 'Não foi possível ler a estante salva.';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Adiciona a obra ou, se já existir (mesmo id), apenas atualiza o status.
  Future<bool> addOrUpdate(Book book, ReadingStatus status) {
    final next = List<BookshelfItem>.of(_items);
    final index = next.indexWhere((i) => i.id == book.id);
    if (index >= 0) {
      next[index] = next[index].copyWith(status: status);
    } else {
      next.add(BookshelfItem.fromBook(book, status));
    }
    return _commit(next);
  }

  Future<bool> setStatus(String id, ReadingStatus status) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index < 0) return Future.value(false);
    final next = List<BookshelfItem>.of(_items);
    next[index] = next[index].copyWith(status: status);
    return _commit(next);
  }

  Future<bool> remove(String id) {
    if (!contains(id)) return Future.value(false);
    return _commit(_items.where((i) => i.id != id).toList());
  }

  /// Usado pelo "Desfazer" da remoção.
  Future<bool> restore(BookshelfItem item) {
    if (contains(item.id)) return Future.value(true);
    return _commit([..._items, item]);
  }

  void dismissError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> _commit(List<BookshelfItem> next) async {
    final previous = _items;
    _items = next;
    notifyListeners();
    try {
      await _repository.save(next);
      _error = null;
      return true;
    } catch (_) {
      _items = previous;
      _error = 'Não foi possível salvar a alteração.';
      notifyListeners();
      return false;
    }
  }
}
