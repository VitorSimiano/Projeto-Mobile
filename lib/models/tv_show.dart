import 'media_item.dart';

class TvShow extends MediaItem {
  const TvShow({
    required super.id,
    required super.title,
    super.posterPath,
    super.backdropPath,
    super.voteAverage = 0,
    super.overview = '',
    super.date,
    super.originalLanguage = '',
    super.genres = const [],
    this.numberOfSeasons,
    this.numberOfEpisodes,
  });

  /// Só vêm no endpoint de detalhes.
  final int? numberOfSeasons;
  final int? numberOfEpisodes;

  @override
  bool get isTv => true;

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'] as int,
      title: (json['name'] ?? json['original_name'] ?? 'Sem título').toString(),
      posterPath: MediaItem.emptyToNull(json['poster_path']),
      backdropPath: MediaItem.emptyToNull(json['backdrop_path']),
      voteAverage: MediaItem.parseRating(json['vote_average']),
      overview: (json['overview'] ?? '').toString(),
      date: MediaItem.emptyToNull(json['first_air_date']),
      originalLanguage: (json['original_language'] ?? '').toString(),
      genres: MediaItem.parseGenres(json['genres']),
      numberOfSeasons: MediaItem.parseInt(json['number_of_seasons']),
      numberOfEpisodes: MediaItem.parseInt(json['number_of_episodes']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'media_type': 'tv',
        'id': id,
        'name': title,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'vote_average': voteAverage,
        'overview': overview,
        'first_air_date': date,
        'original_language': originalLanguage,
        'genres': [for (final g in genres) {'name': g}],
        'number_of_seasons': numberOfSeasons,
        'number_of_episodes': numberOfEpisodes,
      };
}
