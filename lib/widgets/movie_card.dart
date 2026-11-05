import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../screens/details_screen.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/theme.dart';

/// Imagem de pôster/backdrop com placeholder e fade-in.
class PosterImage extends StatelessWidget {
  const PosterImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surfaceLight,
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, color: AppColors.textSecondary, size: 36),
    );

    if (url == null) return placeholder;

    return Container(
      color: AppColors.surfaceLight,
      child: Image.network(
        url!,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}

/// Selo com a nota (estrela + valor).
class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(170),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.star, size: 14),
          const SizedBox(width: 3),
          Text(
            Formatters.rating(value),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de filme/série: pôster, nota, título e ano.
class MediaCard extends StatelessWidget {
  const MediaCard({super.key, required this.item, this.width, this.onRemove});

  final MediaItem item;
  final double? width;

  /// Se informado, mostra um botão de coração para remover (tela Favoritos).
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => openDetails(context, item),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterImage(url: AppConstants.posterUrl(item.posterPath)),
                      if (item.voteAverage > 0)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: RatingBadge(value: item.voteAverage),
                        ),
                      if (onRemove != null)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: onRemove,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(170),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: AppColors.accent,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.year} · ${item.isTv ? 'Série' : 'Filme'}',
                style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
