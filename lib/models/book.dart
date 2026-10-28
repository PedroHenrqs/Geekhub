import '../core/constants/app_constants.dart';
import 'json_utils.dart';

/// Obra (work) da Open Library. Todos os campos opcionais podem faltar.
class Book {
  const Book({
    required this.key,
    required this.title,
    this.authors = const [],
    this.firstPublishYear,
    this.coverId,
    this.pages,
    this.publishers = const [],
    this.description,
  });

  /// Ex.: "/works/OL45804W"
  final String key;
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;
  final int? pages;
  final List<String> publishers;
  final String? description;

  /// Identificador estável (ex.: "OL45804W"), usado para evitar duplicatas.
  String get id {
    final i = key.lastIndexOf('/');
    return i == -1 ? key : key.substring(i + 1);
  }

  String get authorsLabel =>
      authors.isEmpty ? 'Autor não informado' : authors.join(', ');

  /// size: S, M ou L.
  String? coverUrl([String size = 'M']) => coverId == null
      ? null
      : '${AppConstants.coversBaseUrl}/$coverId-$size.jpg';

  factory Book.fromSearchJson(Map<String, dynamic> json) {
    final rawTitle = json['title'];
    return Book(
      key: json['key'] is String ? json['key'] as String : '',
      title: rawTitle is String && rawTitle.trim().isNotEmpty
          ? rawTitle.trim()
          : 'Título não informado',
      authors: asStringList(json['author_name']),
      firstPublishYear: asPositiveInt(json['first_publish_year']),
      coverId: asPositiveInt(json['cover_i']),
      pages: asPositiveInt(json['number_of_pages_median']),
      publishers: asStringList(json['publisher']).take(3).toList(),
    );
  }

  Book copyWith({
    int? coverId,
    int? pages,
    List<String>? publishers,
    String? description,
  }) {
    return Book(
      key: key,
      title: title,
      authors: authors,
      firstPublishYear: firstPublishYear,
      coverId: coverId ?? this.coverId,
      pages: pages ?? this.pages,
      publishers: publishers ?? this.publishers,
      description: description ?? this.description,
    );
  }
}
