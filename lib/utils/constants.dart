import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Constantes globais e configuração da API do TMDB.
class AppConstants {
  AppConstants._();

  static const String appName = 'CineFinder';
  static const String apiBaseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';
  static const String language = 'pt-BR';

  /// Chave lida do arquivo .env (que não vai para o GitHub).
  static String get apiKey => dotenv.maybeGet('TMDB_API_KEY')?.trim() ?? '';

  static bool get hasApiKey => apiKey.isNotEmpty && apiKey != 'sua_chave_aqui';

  static String? posterUrl(String? path, {String size = 'w500'}) =>
      path == null ? null : '$imageBaseUrl/$size$path';

  static String? backdropUrl(String? path, {String size = 'w1280'}) =>
      path == null ? null : '$imageBaseUrl/$size$path';
}
