import 'package:flutter_test/flutter_test.dart';

import 'package:cinefinder/models/movie.dart';
import 'package:cinefinder/models/tv_show.dart';
import 'package:cinefinder/utils/formatters.dart';

void main() {
  group('Interpretação de JSON', () {
    test('Movie.fromJson lê os campos da lista do TMDB', () {
      final movie = Movie.fromJson({
        'id': 550,
        'title': 'Clube da Luta',
        'poster_path': '/poster.jpg',
        'backdrop_path': null,
        'vote_average': 8.4,
        'overview': 'Sinopse',
        'release_date': '1999-10-15',
        'original_language': 'en',
      });

      expect(movie.id, 550);
      expect(movie.title, 'Clube da Luta');
      expect(movie.backdropPath, isNull);
      expect(movie.voteAverage, 8.4);
      expect(movie.year, '1999');
      expect(movie.isTv, isFalse);
    });

    test('TvShow.fromJson usa name e first_air_date', () {
      final show = TvShow.fromJson({
        'id': 1396,
        'name': 'Breaking Bad',
        'first_air_date': '2008-01-20',
        'number_of_seasons': 5,
        'number_of_episodes': 62,
        'genres': [
          {'id': 18, 'name': 'Drama'},
        ],
      });

      expect(show.title, 'Breaking Bad');
      expect(show.year, '2008');
      expect(show.genres, ['Drama']);
      expect(show.isTv, isTrue);
    });

    test('toJson e fromJson preservam os dados (favoritos)', () {
      const original = Movie(
        id: 1,
        title: 'Teste',
        voteAverage: 7.5,
        date: '2020-05-01',
        genres: ['Ação', 'Drama'],
        runtime: 125,
      );
      final restored = Movie.fromJson(original.toJson());

      expect(restored.title, original.title);
      expect(restored.genres, original.genres);
      expect(restored.runtime, 125);
    });
  });

  group('Formatters', () {
    test('formata data, duração e temporadas', () {
      expect(Formatters.date('2024-03-25'), '25/03/2024');
      expect(Formatters.runtime(135), '2h 15min');
      expect(Formatters.seasons(1, 10), '1 temporada · 10 episódios');
      expect(Formatters.language('en'), 'Inglês');
    });
  });
}
