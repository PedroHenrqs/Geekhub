import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'repositories/bookshelf_repository.dart';
import 'services/open_library_service.dart';
import 'state/bookshelf_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = BookshelfController(BookshelfRepository());
  await controller.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<BookshelfController>.value(value: controller),
        Provider<OpenLibraryService>(
          create: (_) => OpenLibraryService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: const GeekHubApp(),
    ),
  );
}
