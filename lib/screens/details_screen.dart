import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import '../services/favorites_service.dart';
import '../services/tmdb_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';
import '../widgets/movie_card.dart';

/// Abre a tela de detalhes com uma transição suave.
void openDetails(BuildContext context, MediaItem item) {
  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => DetailsScreen(item: item),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.item});

  final MediaItem item;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Future<MediaItem> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<MediaItem> _load() {
    if (widget.item.isTv) return TmdbService.instance.tvDetails(widget.item.id);
    return TmdbService.instance.movieDetails(widget.item.id);
  }

  Future<void> _toggleFavorite(MediaItem item) async {
    final added = await FavoritesService.instance.toggle(item);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1500),
        content: Text(added ? 'Adicionado aos favoritos' : 'Removido dos favoritos'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MediaItem>(
        future: _future,
        builder: (context, snapshot) {
          // Mostra de imediato os dados da lista e completa quando a API responde.
          final item = snapshot.data ?? widget.item;
          final loading = snapshot.connectionState != ConnectionState.done;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, item),
              SliverToBoxAdapter(
                child: _buildBody(context, item, loading, snapshot.error),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, MediaItem item) {
    final width = MediaQuery.sizeOf(context).width;
    final expandedHeight = math.min(360.0, math.max(220.0, width * 0.62));
    final imageUrl = AppConstants.backdropUrl(item.backdropPath) ??
        AppConstants.posterUrl(item.posterPath);

    return SliverAppBar(
      pinned: true,
      expandedHeight: expandedHeight,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leading: _CircleButton(
        icon: Icons.arrow_back_rounded,
        tooltip: 'Voltar',
        onTap: () => Navigator.of(context).pop(),
      ),
      actions: [
        ListenableBuilder(
          listenable: FavoritesService.instance,
          builder: (context, _) {
            final isFav = FavoritesService.instance.isFavorite(item);
            return _CircleButton(
              icon: isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? AppColors.accent : Colors.white,
              tooltip: isFav ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
              onTap: () => _toggleFavorite(item),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage(url: imageUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1],
                  colors: [Colors.transparent, AppColors.background],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MediaItem item,
    bool loading,
    Object? error,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final overview = item.overview.trim();

    // Campos específicos de cada tipo.
    final String extraLabel;
    final String extraValue;
    if (item is Movie) {
      extraLabel = 'Duração';
      extraValue = (loading && item.runtime == null)
          ? '—'
          : Formatters.runtime(item.runtime);
    } else if (item is TvShow) {
      extraLabel = 'Temporadas e episódios';
      extraValue = (loading && item.numberOfSeasons == null)
          ? '—'
          : Formatters.seasons(item.numberOfSeasons, item.numberOfEpisodes);
    } else {
      extraLabel = '';
      extraValue = '';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 2,
            child: loading
                ? const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primary,
                    backgroundColor: Colors.transparent,
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 112,
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: PosterImage(url: AppConstants.posterUrl(item.posterPath)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Rating(value: item.voteAverage),
                    const SizedBox(height: 14),
                    _InfoTile(
                      icon: Icons.calendar_today_rounded,
                      label: item.isTv ? 'Estreia' : 'Lançamento',
                      value: Formatters.date(item.date),
                    ),
                    _InfoTile(
                      icon: item.isTv ? Icons.tv_rounded : Icons.schedule_rounded,
                      label: extraLabel,
                      value: extraValue,
                    ),
                    _InfoTile(
                      icon: Icons.translate_rounded,
                      label: 'Idioma original',
                      value: Formatters.language(item.originalLanguage),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.genres.isNotEmpty) ...[
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final genre in item.genres) _GenrePill(genre)],
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Sinopse',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            overview.isEmpty ? 'Sinopse não disponível.' : overview,
            style: textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: AppColors.textPrimary.withAlpha(215),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage(error),
                      style: textTheme.bodySmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _future = _load()),
                    child: const Text('Tentar de novo'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.black.withAlpha(150),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Tooltip(
            message: tooltip ?? '',
            child: Center(child: Icon(icon, color: color, size: 22)),
          ),
        ),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    if (value <= 0) {
      return const Text(
        'Sem avaliação',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: AppColors.star, size: 22),
        const SizedBox(width: 4),
        Text(
          Formatters.rating(value),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const Text(' / 10', style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenrePill extends StatelessWidget {
  const _GenrePill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.wine.withAlpha(90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(140)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
