# GeekHub — Buscador de Livros e Quadrinhos

Aplicativo Flutter (Dart) para pesquisar livros, mangás e quadrinhos na
**Open Library API**, consultar detalhes, organizar uma estante pessoal
(status *Lido* / *Lendo agora* / *Salvo*) e acompanhar estatísticas de leitura.
Projeto acadêmico.

> **Status honesto:** o código foi escrito e revisado manualmente, mas **ainda não foi
> compilado nem executado**. Veja "Validação pendente" abaixo.

## Tecnologias
Flutter · Dart · `http` · `provider` (ChangeNotifier) · `shared_preferences` (JSON).
O gráfico de rosca é desenhado com `CustomPaint` (sem pacote de gráficos).

## Instalação (Windows + VS Code)
Pré-requisito: Flutter instalado (`flutter doctor`).

1. Extraia o zip e abra a pasta `geekhub` no terminal.
2. Rode o script de preparação:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\setup.ps1
   ```
   Ele executa `flutter create .` (gera android/web/windows sem sobrescrever `lib/`),
   `flutter pub get`, adiciona a permissão INTERNET ao Android, e roda `flutter analyze` e `flutter test`.
   Manualmente: `flutter create . --project-name geekhub --platforms=android,web,windows` e `flutter pub get`.
3. **Edite o e-mail** do `userAgent` em `lib/core/constants/app_constants.dart`
   (a Open Library pede identificação com contato).
4. Execute: `flutter devices` e depois `flutter run -d chrome` (ou `-d windows`, ou um Android).

## Estrutura
```
lib/
  main.dart, app.dart
  core/ (theme, constants, utils)
  models/ (book, bookshelf_item, json_utils)
  services/open_library_service.dart
  repositories/bookshelf_repository.dart
  state/bookshelf_controller.dart
  screens/ (main_shell, home, search_results, book_details, bookshelf, statistics)
  widgets/ (book_cover, book_card, search_field, state_views, stat_widgets, ...)
test/ (models, controller, service com http mockado, widget de navegação)
```

## Funcionalidades
- Home com busca por título/autor, atalhos e sugestões reais (por assunto) da API.
- Lista de resultados com capa, autores, ano, carregamento, erro com "Tentar novamente" e estado vazio.
- Detalhes com sinopse, editora e páginas (consulta de obra + edições), campos ausentes tratados.
- Estante persistente, filtros (Todas/Lidos/Lendo agora/Salvos), mudança de status, remoção com "Desfazer", sem duplicatas.
- Estatísticas calculadas da estante: cards, progresso e gráfico de rosca.
- Tema escuro, navegação inferior, layout responsivo (grades em telas largas).

## Validação pendente (preencher após executar)
- [ ] `flutter analyze` sem erros
- [ ] `flutter test` passando
- [ ] Busca por título e por autor com dados reais
- [ ] Sugestões da Home (`subject` + `sort=rating` não testados com a API real)
- [ ] Capas no Chrome (possível limitação de CORS; teste também em Windows/Android)
- [ ] Persistência após fechar e reabrir o app
- [ ] Erro de rede (modo avião) e "Tentar novamente"

## Limitações conhecidas
- Nem toda obra possui sinopse, editora, páginas ou capa (exibe "Informação não disponível" / fallback).
- Páginas e editoras vêm das edições (melhor esforço), não da obra.
- A busca ocorre ao confirmar (Enter/botão), sem debounce.
- Sem login nem sincronização em nuvem (fora do escopo).
