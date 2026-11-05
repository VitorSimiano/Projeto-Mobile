import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/media_item.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';

/// Gerencia os favoritos e os mantém salvos com shared_preferences.
/// Usa ChangeNotifier para que as telas atualizem automaticamente.
class FavoritesService extends ChangeNotifier {
  FavoritesService._();

  static final FavoritesService instance = FavoritesService._();

  static const String _storageKey = 'cinefinder_favorites';

  final List<MediaItem> _items = [];

  List<MediaItem> get items => List.unmodifiable(_items);

  /// Carrega os favoritos salvos (chamado uma vez no início do app).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? const [];

    _items.clear();
    for (final entry in raw) {
      try {
        final map = json.decode(entry) as Map<String, dynamic>;
        _items.add(
          map['media_type'] == 'tv' ? TvShow.fromJson(map) : Movie.fromJson(map),
        );
      } catch (_) {
        // Ignora registros corrompidos.
      }
    }
    notifyListeners();
  }

  bool isFavorite(MediaItem item) =>
      _items.any((e) => e.uniqueKey == item.uniqueKey);

  /// Adiciona ou remove. Retorna true se o item agora é favorito.
  Future<bool> toggle(MediaItem item) async {
    final index = _items.indexWhere((e) => e.uniqueKey == item.uniqueKey);
    final nowFavorite = index == -1;
    if (nowFavorite) {
      _items.insert(0, item);
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
    await _save();
    return nowFavorite;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey,
      _items.map((e) => json.encode(e.toJson())).toList(),
    );
  }
}
