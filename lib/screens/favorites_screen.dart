import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/favorites_service.dart';
import '../utils/theme.dart';
import '../widgets/movie_card.dart';

enum _Filter { all, movies, series }

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _service = FavoritesService.instance;
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: ListenableBuilder(
        listenable: _service,
        builder: (context, _) {
          final all = _service.items;
          if (all.isEmpty) return const _EmptyFavorites();

          final movies = all.where((e) => !e.isTv).toList();
          final series = all.where((e) => e.isTv).toList();

          final List<MediaItem> visible;
          switch (_filter) {
            case _Filter.movies:
              visible = movies;
            case _Filter.series:
              visible = series;
            case _Filter.all:
              visible = all;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  children: [
                    _chip('Todos (${all.length})', _Filter.all),
                    const SizedBox(width: 8),
                    _chip('Filmes (${movies.length})', _Filter.movies),
                    const SizedBox(width: 8),
                    _chip('Séries (${series.length})', _Filter.series),
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum favorito nesta categoria.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          childAspectRatio: 0.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          return MediaCard(
                            key: ValueKey(item.uniqueKey),
                            item: item,
                            onRemove: () => _service.toggle(item),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, _Filter value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceLight,
      side: BorderSide.none,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.surfaceLight),
            const SizedBox(height: 16),
            Text(
              'Sua lista está vazia',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no coração na tela de detalhes para salvar filmes e séries aqui.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
