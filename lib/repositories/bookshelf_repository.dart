import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../models/bookshelf_item.dart';

class BookshelfStorageException implements Exception {
  const BookshelfStorageException(this.message);
  final String message;

  @override
  String toString() => message;
}

class BookshelfRepository {
  Future<List<BookshelfItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.shelfStorageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const BookshelfStorageException('Formato de estante inválido.');
    }
    final items = <BookshelfItem>[];
    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) continue;
      try {
        items.add(BookshelfItem.fromJson(entry));
      } on FormatException {
        // Ignora registros corrompidos sem perder os demais.
      }
    }
    return items;
  }

  Future<void> save(List<BookshelfItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setString(
      AppConstants.shelfStorageKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
    if (!ok) {
      throw const BookshelfStorageException('Falha ao gravar a estante.');
    }
  }
}
