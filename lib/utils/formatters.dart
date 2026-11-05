/// Funções auxiliares para formatar dados vindos da API.
class Formatters {
  Formatters._();

  /// Converte "2024-03-25" em "25/03/2024".
  static String date(String? iso) {
    if (iso == null || iso.length < 10) return 'Não informado';
    final parts = iso.split('-');
    if (parts.length != 3) return iso;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  /// Converte minutos em "2h 15min".
  static String runtime(int? minutes) {
    if (minutes == null || minutes <= 0) return 'Não informada';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  /// "3 temporadas · 45 episódios".
  static String seasons(int? seasons, int? episodes) {
    final parts = <String>[];
    if (seasons != null && seasons > 0) {
      parts.add('$seasons ${seasons == 1 ? 'temporada' : 'temporadas'}');
    }
    if (episodes != null && episodes > 0) {
      parts.add('$episodes ${episodes == 1 ? 'episódio' : 'episódios'}');
    }
    return parts.isEmpty ? 'Não informado' : parts.join(' · ');
  }

  static String rating(double value) => value.toStringAsFixed(1);

  static const Map<String, String> _languages = {
    'en': 'Inglês',
    'pt': 'Português',
    'es': 'Espanhol',
    'fr': 'Francês',
    'de': 'Alemão',
    'it': 'Italiano',
    'ja': 'Japonês',
    'ko': 'Coreano',
    'zh': 'Chinês',
    'cn': 'Cantonês',
    'hi': 'Hindi',
    'ru': 'Russo',
    'tr': 'Turco',
    'sv': 'Sueco',
    'da': 'Dinamarquês',
    'th': 'Tailandês',
  };

  static String language(String code) {
    if (code.isEmpty) return 'Não informado';
    return _languages[code.toLowerCase()] ?? code.toUpperCase();
  }
}
