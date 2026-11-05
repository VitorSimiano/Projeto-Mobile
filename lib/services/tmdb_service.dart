import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie.dart';
import '../models/tv_show.dart';
import '../utils/constants.dart';

/// Erro amigável para ser exibido ao usuário.
class TmdbException implements Exception {
  const TmdbException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Converte qualquer erro em uma mensagem em português.
String errorMessage(Object? error) {
  if (error is TmdbException) return error.message;
  return 'Não foi possível carregar os dados. Tente novamente.';
}

/// Camada de acesso à API REST do TMDB.
class TmdbService {
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  static final TmdbService instance = TmdbService();

  final http.Client _client;

  // A chave v4 ("Token de Leitura") é um JWT que começa com "eyJ" e vai no
  // header Authorization. A chave v3 vai como parâmetro "api_key".
  bool get _usesBearer => AppConstants.apiKey.startsWith('eyJ');

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        if (_usesBearer) 'Authorization': 'Bearer ${AppConstants.apiKey}',
      };

  Uri _buildUri(String path, Map<String, String>? params) {
    final query = <String, String>{
      'language': AppConstants.language,
      ...?params,
      if (!_usesBearer) 'api_key': AppConstants.apiKey,
    };
    return Uri.parse('${AppConstants.apiBaseUrl}$path')
        .replace(queryParameters: query);
  }

  /// Faz a requisição GET, valida o status e decodifica o JSON.
  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? params,
  ]) async {
    if (!AppConstants.hasApiKey) {
      throw const TmdbException(
        'Chave da API do TMDB não configurada. Crie o arquivo .env a partir '
        'do .env.example e informe a sua chave.',
      );
    }

    try {
      final response = await _client
          .get(_buildUri(path, params), headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) return decoded;
        throw const TmdbException('Resposta inesperada da API.');
      }
      if (response.statusCode == 401) {
        throw const TmdbException(
          'Chave da API inválida. Verifique o arquivo .env.',
        );
      }
      if (response.statusCode == 404) {
        throw const TmdbException('Conteúdo não encontrado.');
      }
      if (response.statusCode == 429) {
        throw const TmdbException(
          'Muitas requisições. Aguarde um instante e tente de novo.',
        );
      }
      throw TmdbException(
        'Erro ao consultar a API (código ${response.statusCode}).',
      );
    } on TmdbException {
      rethrow;
    } on TimeoutException {
      throw const TmdbException('A conexão demorou demais. Tente novamente.');
    } on FormatException {
      throw const TmdbException('Não foi possível interpretar a resposta.');
    } catch (_) {
      throw const TmdbException(
        'Sem conexão com a internet. Verifique sua rede.',
      );
    }
  }

  Future<List<T>> _list<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    int page = 1,
    Map<String, String>? extra,
  }) async {
    final data = await _get(path, {'page': '$page', ...?extra});
    final results = data['results'];
    if (results is! List) return <T>[];
    return results.whereType<Map<String, dynamic>>().map(parse).toList();
  }

  // ---------------- Filmes ----------------

  Future<List<Movie>> popularMovies({int page = 1}) =>
      _list('/movie/popular', Movie.fromJson, page: page);

  Future<List<Movie>> topRatedMovies({int page = 1}) =>
      _list('/movie/top_rated', Movie.fromJson, page: page);

  Future<List<Movie>> nowPlayingMovies({int page = 1}) =>
      _list('/movie/now_playing', Movie.fromJson, page: page);

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return <Movie>[];
    return _list(
      '/search/movie',
      Movie.fromJson,
      page: page,
      extra: {'query': query.trim(), 'include_adult': 'false'},
    );
  }

  Future<Movie> movieDetails(int id) async =>
      Movie.fromJson(await _details('/movie/$id'));

  // ---------------- Séries ----------------

  Future<List<TvShow>> popularTvShows({int page = 1}) =>
      _list('/tv/popular', TvShow.fromJson, page: page);

  Future<List<TvShow>> topRatedTvShows({int page = 1}) =>
      _list('/tv/top_rated', TvShow.fromJson, page: page);

  Future<List<TvShow>> searchTvShows(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return <TvShow>[];
    return _list(
      '/search/tv',
      TvShow.fromJson,
      page: page,
      extra: {'query': query.trim(), 'include_adult': 'false'},
    );
  }

  Future<TvShow> tvDetails(int id) async =>
      TvShow.fromJson(await _details('/tv/$id'));

  /// Busca os detalhes em pt-BR. Se a sinopse estiver vazia (comum em
  /// títulos menos conhecidos), usa a sinopse em inglês como alternativa.
  Future<Map<String, dynamic>> _details(String path) async {
    var data = await _get(path);
    final overview = (data['overview'] ?? '').toString().trim();
    if (overview.isEmpty) {
      try {
        final en = await _get(path, {'language': 'en-US'});
        data = {...data, 'overview': en['overview'] ?? ''};
      } catch (_) {
        // Mantém os dados em pt-BR mesmo sem sinopse.
      }
    }
    return data;
  }
}
