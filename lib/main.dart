import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/movies_screen.dart';
import 'screens/series_screen.dart';
import 'services/favorites_service.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega a chave da API do arquivo .env (fora do GitHub).
  await dotenv.load(fileName: '.env', isOptional: true);

  // Recupera os favoritos salvos no aparelho.
  await FavoritesService.instance.load();

  runApp(const CineFinderApp());
}

class CineFinderApp extends StatelessWidget {
  const CineFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainShell(),
    );
  }
}

/// Estrutura principal com a barra de navegação inferior.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // As abas só são construídas na primeira visita (evita requisições à toa).
  final Set<int> _visited = {0};

  static final List<Widget Function()> _builders = [
    () => const HomeScreen(),
    () => const MoviesScreen(),
    () => const SeriesScreen(),
    () => const FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < _builders.length; i++)
            _visited.contains(i) ? _builders[i]() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() {
          _index = i;
          _visited.add(i);
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie_rounded),
            label: 'Filmes',
          ),
          NavigationDestination(
            icon: Icon(Icons.tv_outlined),
            selectedIcon: Icon(Icons.tv_rounded),
            label: 'Séries',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
