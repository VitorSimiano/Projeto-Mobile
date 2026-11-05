import 'dart:async';

import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../utils/theme.dart';
import '../widgets/paged_media_grid.dart';
import '../widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialTv = false});

  /// Define se a pesquisa começa em "Séries" em vez de "Filmes".
  final bool initialTv;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final TmdbService _service = TmdbService.instance;

  Timer? _debounce;
  late bool _tv = widget.initialTv;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Espera o usuário parar de digitar antes de consultar a API.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _apply(value));
  }

  void _onSubmitted(String value) {
    _debounce?.cancel();
    _apply(value);
  }

  void _apply(String value) {
    final query = value.trim();
    if (query == _query || !mounted) return;
    setState(() => _query = query);
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _query = '');
  }

  Future<List<MediaItem>> _fetch(int page) {
    if (_tv) return _service.searchTvShows(_query, page: page);
    return _service.searchMovies(_query, page: page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CineSearchBar(
            controller: _controller,
            autofocus: true,
            onChanged: _onChanged,
            onSubmitted: _onSubmitted,
            onClear: _clear,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: false,
                    label: Text('Filmes'),
                    icon: Icon(Icons.movie_outlined),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text('Séries'),
                    icon: Icon(Icons.tv_rounded),
                  ),
                ],
                selected: {_tv},
                onSelectionChanged: (selection) =>
                    setState(() => _tv = selection.first),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.primary
                        : AppColors.surfaceLight,
                  ),
                  foregroundColor: const WidgetStatePropertyAll(Colors.white),
                  side: const WidgetStatePropertyAll(BorderSide.none),
                ),
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? const _SearchHint()
                : PagedMediaGrid(
                    // A chave recria a grade quando a busca ou o tipo mudam.
                    key: ValueKey('${_tv ? 'tv' : 'movie'}_$_query'),
                    fetchPage: _fetch,
                    emptyMessage: 'Nenhum resultado para "$_query".',
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_rounded, size: 64, color: AppColors.surfaceLight),
            const SizedBox(height: 12),
            Text(
              'Digite o nome de um filme ou série',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
