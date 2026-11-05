import 'package:flutter/material.dart';

import '../services/tmdb_service.dart';
import '../widgets/cine_tab_bar.dart';
import '../widgets/paged_media_grid.dart';
import 'search_screen.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TmdbService.instance;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Séries'),
          actions: [
            IconButton(
              tooltip: 'Pesquisar',
              icon: const Icon(Icons.search_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SearchScreen(initialTv: true),
                ),
              ),
            ),
          ],
          bottom: const CineTabBar(labels: ['Populares', 'Mais bem avaliadas']),
        ),
        body: TabBarView(
          children: [
            PagedMediaGrid(fetchPage: (page) => service.popularTvShows(page: page)),
            PagedMediaGrid(fetchPage: (page) => service.topRatedTvShows(page: page)),
          ],
        ),
      ),
    );
  }
}
