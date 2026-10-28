class DiscoveryCategory {
  const DiscoveryCategory(this.label, this.subject);
  final String label;
  final String subject;
}

class AppConstants {
  AppConstants._();

  static const String appName = 'GeekHub';
  static const String apiHost = 'openlibrary.org';
  static const String coversBaseUrl = 'https://covers.openlibrary.org/b/id';

  // TROQUE o e-mail pelo seu: a Open Library pede um User-Agent com contato.
  static const String userAgent =
      'GeekHub/1.0 (projeto academico; contato: SEU_EMAIL@exemplo.com)';

  static const int searchLimit = 30;
  static const int discoveryLimit = 12;
  static const Duration requestTimeout = Duration(seconds: 15);
  static const String shelfStorageKey = 'geekhub_bookshelf_v1';
  static const double maxContentWidth = 1000;

  static const List<DiscoveryCategory> categories = [
    DiscoveryCategory('Fantasia', 'fantasy'),
    DiscoveryCategory('Ficção científica', 'science fiction'),
    DiscoveryCategory('Quadrinhos', 'comics'),
    DiscoveryCategory('Mangá', 'manga'),
    DiscoveryCategory('Clássicos', 'classics'),
  ];
}
