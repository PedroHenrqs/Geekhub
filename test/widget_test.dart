import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geekhub/app.dart';
import 'package:geekhub/repositories/bookshelf_repository.dart';
import 'package:geekhub/services/open_library_service.dart';
import 'package:geekhub/state/bookshelf_controller.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('navega entre Início, Estante e Estatísticas', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final client = MockClient((req) async => http.Response(
          '{"numFound":0,"docs":[]}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<BookshelfController>(
              create: (_) => BookshelfController(BookshelfRepository())),
          Provider<OpenLibraryService>(
              create: (_) => OpenLibraryService(client: client)),
        ],
        child: const GeekHubApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('O que vamos ler hoje?'), findsOneWidget);

    Finder navItem(String label) => find.descendant(
        of: find.byType(NavigationBar), matching: find.text(label));

    await tester.tap(navItem('Estante'));
    await tester.pumpAndSettle();
    expect(find.text('Sua estante está vazia'), findsOneWidget);

    await tester.tap(navItem('Estatísticas'));
    await tester.pumpAndSettle();
    expect(find.text('Ainda não há dados'), findsOneWidget);
  });
}
