import 'package:flutter/material.dart';

import '../services/tmdb_service.dart';
import '../widgets/cine_tab_bar.dart';
import '../widgets/paged_media_grid.dart';
import 'search_screen.dart';

class MoviesScreen extends StatelessWidget {
  const MoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TmdbService.instance;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Filmes'),
          actions: [
            IconButton(
              tooltip: 'Pesquisar',
              icon: const Icon(Icons.search_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              ),
            ),
          ],
          bottom: const CineTabBar(
            labels: ['Populares', 'Mais bem avaliados', 'Em cartaz'],
          ),
        ),
        body: TabBarView(
          children: [
            PagedMediaGrid(fetchPage: (page) => service.popularMovies(page: page)),
            PagedMediaGrid(fetchPage: (page) => service.topRatedMovies(page: page)),
            PagedMediaGrid(fetchPage: (page) => service.nowPlayingMovies(page: page)),
          ],
        ),
      ),
    );
  }
}
