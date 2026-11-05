import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_widget.dart';
import '../widgets/movie_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/section_title.dart';
import 'details_screen.dart';
import 'search_screen.dart';

class _HomeData {
  const _HomeData({
    required this.featured,
    required this.popularMovies,
    required this.topRatedMovies,
    required this.popularTv,
  });

  final MediaItem? featured;
  final List<MediaItem> popularMovies;
  final List<MediaItem> topRatedMovies;
  final List<MediaItem> popularTv;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TmdbService _service = TmdbService.instance;
  late Future<_HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  /// Faz as três requisições em paralelo com async/await.
  Future<_HomeData> _load() async {
    final results = await Future.wait<List<MediaItem>>([
      _service.popularMovies(),
      _service.topRatedMovies(),
      _service.popularTvShows(),
    ]);

    final popular = results[0];
    final withBackdrop = popular.where((m) => m.backdropPath != null).take(5).toList();
    MediaItem? featured;
    if (withBackdrop.isNotEmpty) {
      featured = withBackdrop[math.Random().nextInt(withBackdrop.length)];
    } else if (popular.isNotEmpty) {
      featured = popular.first;
    }

    return _HomeData(
      featured: featured,
      popularMovies: popular,
      topRatedMovies: results[1],
      popularTv: results[2],
    );
  }

  void _retry() => setState(() => _future = _load());

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    try {
      await future;
    } catch (_) {
      // O erro é exibido pelo FutureBuilder.
    }
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                children: [
                  const Align(alignment: Alignment.centerLeft, child: AppLogo()),
                  const SizedBox(height: 14),
                  CineSearchBar(readOnly: true, onTap: _openSearch),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<_HomeData>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingWidget();
                  }
                  if (snapshot.hasError) {
                    return ErrorView(
                      message: errorMessage(snapshot.error),
                      onRetry: _retry,
                    );
                  }
                  final data = snapshot.data!;
                  return RefreshIndicator(
                    color: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        if (data.featured != null) _FeaturedBanner(item: data.featured!),
                        _section(context, 'Filmes populares', data.popularMovies),
                        _section(context, 'Mais bem avaliados', data.topRatedMovies),
                        _section(context, 'Séries populares', data.popularTv),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<MediaItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = math.min(170.0, math.max(118.0, screenWidth * 0.33));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        SizedBox(
          height: cardWidth * 1.5 + 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) => MediaCard(item: items[index], width: cardWidth),
          ),
        ),
      ],
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final imageUrl = AppConstants.backdropUrl(item.backdropPath) ??
        AppConstants.posterUrl(item.posterPath);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = math.min(460.0, math.max(300.0, constraints.maxWidth * 0.95));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PosterImage(url: imageUrl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.3, 0.7, 1],
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(130),
                          AppColors.background.withAlpha(245),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'EM DESTAQUE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (item.voteAverage > 0) ...[
                              RatingBadge(value: item.voteAverage),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              '${item.year} · ${item.isTv ? 'Série' : 'Filme'}',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        FilledButton.icon(
                          onPressed: () => openDetails(context, item),
                          icon: const Icon(Icons.info_outline_rounded, size: 20),
                          label: const Text('Ver detalhes'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
