/// Base comum para filmes e séries. Permite que cards, listas e favoritos
/// trabalhem com os dois tipos sem duplicar código.
abstract class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0,
    this.overview = '',
    this.date,
    this.originalLanguage = '',
    this.genres = const [],
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String overview;

  /// Data de lançamento (filme) ou de estreia (série), formato yyyy-MM-dd.
  final String? date;
  final String originalLanguage;
  final List<String> genres;

  bool get isTv;

  String get mediaType => isTv ? 'tv' : 'movie';

  /// Chave única: o mesmo id pode existir como filme e como série.
  String get uniqueKey => '$mediaType-$id';

  String get year =>
      (date != null && date!.length >= 4) ? date!.substring(0, 4) : '—';

  Map<String, dynamic> toJson();

  // ---- Helpers de parsing usados pelos modelos ----

  /// Aceita tanto [{"id": 1, "name": "Ação"}] (detalhes) quanto
  /// [{"name": "Ação"}] (favoritos salvos).
  static List<String> parseGenres(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((g) => g is Map ? (g['name'] ?? '').toString() : '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  static double parseRating(dynamic value) =>
      value is num ? value.toDouble() : 0.0;

  static String? emptyToNull(dynamic value) {
    final text = value?.toString();
    return (text == null || text.isEmpty) ? null : text;
  }

  static int? parseInt(dynamic value) => value is num ? value.toInt() : null;
}
