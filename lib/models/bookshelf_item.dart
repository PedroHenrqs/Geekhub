import 'book.dart';
import 'json_utils.dart';

enum ReadingStatus {
  saved,
  reading,
  read;

  String get label => switch (this) {
        ReadingStatus.saved => 'Salvo',
        ReadingStatus.reading => 'Lendo agora',
        ReadingStatus.read => 'Lido',
      };

  static ReadingStatus fromName(String? name) => ReadingStatus.values
      .firstWhere((s) => s.name == name, orElse: () => ReadingStatus.saved);
}

class BookshelfItem {
  const BookshelfItem({
    required this.id,
    required this.title,
    required this.authors,
    required this.status,
    required this.savedAt,
    this.coverId,
    this.firstPublishYear,
  });

  final String id;
  final String title;
  final List<String> authors;
  final int? coverId;
  final int? firstPublishYear;
  final ReadingStatus status;
  final DateTime savedAt;

  String get authorsLabel =>
      authors.isEmpty ? 'Autor não informado' : authors.join(', ');

  String? coverUrl([String size = 'M']) => toBook().coverUrl(size);

  factory BookshelfItem.fromBook(Book book, ReadingStatus status,
      {DateTime? savedAt}) {
    return BookshelfItem(
      id: book.id,
      title: book.title,
      authors: book.authors,
      coverId: book.coverId,
      firstPublishYear: book.firstPublishYear,
      status: status,
      savedAt: savedAt ?? DateTime.now(),
    );
  }

  Book toBook() => Book(
        key: '/works/$id',
        title: title,
        authors: authors,
        coverId: coverId,
        firstPublishYear: firstPublishYear,
      );

  BookshelfItem copyWith({ReadingStatus? status}) => BookshelfItem(
        id: id,
        title: title,
        authors: authors,
        coverId: coverId,
        firstPublishYear: firstPublishYear,
        status: status ?? this.status,
        savedAt: savedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'authors': authors,
        'coverId': coverId,
        'firstPublishYear': firstPublishYear,
        'status': status.name,
        'savedAt': savedAt.toIso8601String(),
      };

  factory BookshelfItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    if (id is! String || id.isEmpty || title is! String) {
      throw const FormatException('Registro inválido da estante');
    }
    return BookshelfItem(
      id: id,
      title: title,
      authors: asStringList(json['authors']),
      coverId: asPositiveInt(json['coverId']),
      firstPublishYear: asPositiveInt(json['firstPublishYear']),
      status: ReadingStatus.fromName(
          json['status'] is String ? json['status'] as String : null),
      savedAt: DateTime.tryParse(
              json['savedAt'] is String ? json['savedAt'] as String : '') ??
          DateTime.now(),
    );
  }
}
