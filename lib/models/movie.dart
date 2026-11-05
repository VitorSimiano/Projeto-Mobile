import 'media_item.dart';

class Movie extends MediaItem {
  const Movie({
    required super.id,
    required super.title,
    super.posterPath,
    super.backdropPath,
    super.voteAverage = 0,
    super.overview = '',
    super.date,
    super.originalLanguage = '',
    super.genres = const [],
    this.runtime,
  });

  /// Duração em minutos (só vem no endpoint de detalhes).
  final int? runtime;

  @override
  bool get isTv => false;

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['original_title'] ?? 'Sem título').toString(),
      posterPath: MediaItem.emptyToNull(json['poster_path']),
      backdropPath: MediaItem.emptyToNull(json['backdrop_path']),
      voteAverage: MediaItem.parseRating(json['vote_average']),
      overview: (json['overview'] ?? '').toString(),
      date: MediaItem.emptyToNull(json['release_date']),
      originalLanguage: (json['original_language'] ?? '').toString(),
      genres: MediaItem.parseGenres(json['genres']),
      runtime: MediaItem.parseInt(json['runtime']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'media_type': 'movie',
        'id': id,
        'title': title,
        'poster_path': posterPath,
        'backdrop_path': backdropPath,
        'vote_average': voteAverage,
        'overview': overview,
        'release_date': date,
        'original_language': originalLanguage,
        'genres': [for (final g in genres) {'name': g}],
        'runtime': runtime,
      };
}
