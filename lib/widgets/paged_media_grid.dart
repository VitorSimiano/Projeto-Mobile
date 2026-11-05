import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../services/tmdb_service.dart';
import '../utils/theme.dart';
import 'error_view.dart';
import 'loading_widget.dart';
import 'movie_card.dart';

/// Grade com rolagem infinita: busca a próxima página da API quando o
/// usuário chega perto do fim da lista.
class PagedMediaGrid extends StatefulWidget {
  const PagedMediaGrid({
    super.key,
    required this.fetchPage,
    this.emptyMessage = 'Nada encontrado.',
  });

  final Future<List<MediaItem>> Function(int page) fetchPage;
  final String emptyMessage;

  @override
  State<PagedMediaGrid> createState() => _PagedMediaGridState();
}

class _PagedMediaGridState extends State<PagedMediaGrid>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _controller = ScrollController();
  final List<MediaItem> _items = [];

  int _page = 1;
  bool _loading = true; // a primeira página começa a carregar no initState
  bool _hasMore = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
    _fetch();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients || _error != null) return;
    final position = _controller.position;
    if (position.pixels >= position.maxScrollExtent - 500) _loadMore();
  }

  void _loadMore() {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final result = await widget.fetchPage(_page);
      if (!mounted) return;
      setState(() {
        final known = _items.map((e) => e.uniqueKey).toSet();
        _items.addAll(result.where((e) => !known.contains(e.uniqueKey)));
        _page++;
        _hasMore = result.isNotEmpty && _page <= 500;
        _loading = false;
      });
      _fillIfNeeded();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  /// Em telas grandes a primeira página pode não gerar rolagem;
  /// nesse caso carrega mais itens automaticamente.
  void _fillIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      if (_controller.position.maxScrollExtent <= 0 &&
          _hasMore &&
          !_loading &&
          _error == null) {
        _loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_items.isEmpty) {
      if (_loading) return const LoadingWidget();
      if (_error != null) {
        return ErrorView(message: _error!, onRetry: _loadMore);
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            widget.emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final showFooter = _loading || _error != null;

    return GridView.builder(
      controller: _controller,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 0.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: _items.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return Center(
            child: _loading
                ? const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  )
                : IconButton(
                    tooltip: 'Tentar novamente',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _loadMore,
                  ),
          );
        }
        return MediaCard(item: _items[index]);
      },
    );
  }
}
