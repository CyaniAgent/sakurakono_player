/// Riverpod-based alternative to the GetX search controllers.
///
/// This is additive — the existing GetX [BaseSearchController] and
/// [SSearchController] remain untouched. This Riverpod variant mirrors
/// the essential search state for incremental migration.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/utils/storage.dart';

// ---------------------------------------------------------------------------
// Immutable state
// ---------------------------------------------------------------------------

/// Immutable snapshot of the search page state.
class SearchPageState {
  const SearchPageState({
    this.searchKeyword = '',
    this.searchHistory = const [],
    this.searchResults,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Current search keyword.
  final String searchKeyword;

  /// Persisted search history (most-recent first).
  final List<String> searchHistory;

  /// Search results (dynamic to keep adapter-agnostic).
  final dynamic searchResults;

  /// Whether a search operation is in progress.
  final bool isLoading;

  /// Error message from the last failed operation, if any.
  final String? errorMessage;

  SearchPageState copyWith({
    String? searchKeyword,
    List<String>? searchHistory,
    dynamic searchResults,
    bool? isLoading,
    String? errorMessage,
    bool clearResults = false,
    bool clearError = false,
  }) {
    return SearchPageState(
      searchKeyword: searchKeyword ?? this.searchKeyword,
      searchHistory: searchHistory ?? this.searchHistory,
      searchResults: clearResults ? null : (searchResults ?? this.searchResults),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// StateNotifier that manages the search page state.
///
/// Reads [SearchRepository] from a Riverpod provider and delegates persistence
/// to [GStorage.historyWord] — the same Hive box the GetX controller uses.
class SearchPageController extends StateNotifier<SearchPageState> {
  SearchPageController(this._ref) : super(const SearchPageState()) {
    loadHistory();
  }

  final Ref _ref;

  /// Hive key used by the existing GetX controller for history persistence.
  static const _historyCacheKey = 'cacheList';

  // -- Convenience accessors --

  SearchRepository get _searchRepo =>
      _ref.read(searchRepositoryProvider);

  // -- History --

  /// Load search history from Hive storage.
  void loadHistory() {
    final cached = GStorage.historyWord.get(_historyCacheKey);
    final list = List<String>.from(cached as List<dynamic>? ?? const <String>[]);
    state = state.copyWith(searchHistory: list);
  }

  /// Persist a keyword to the front of the history list and save to Hive.
  void _recordToHistory(String keyword) {
    final updated = [keyword, ...state.searchHistory.where((w) => w != keyword)];
    GStorage.historyWord.put(_historyCacheKey, updated);
    state = state.copyWith(searchHistory: updated);
  }

  /// Clear all search history from state and Hive storage.
  void clearHistory() {
    GStorage.historyWord.delete(_historyCacheKey);
    state = state.copyWith(searchHistory: const []);
  }

  /// Remove a single keyword from history.
  void removeFromHistory(String keyword) {
    final updated = [...state.searchHistory]..remove(keyword);
    GStorage.historyWord.put(_historyCacheKey, updated);
    state = state.copyWith(searchHistory: updated);
  }

  // -- Search --

  /// Update the current keyword without triggering a search.
  void setKeyword(String keyword) {
    state = state.copyWith(searchKeyword: keyword);
  }

  /// Execute a search for the given [keyword].
  ///
  /// Records the keyword to history, then delegates to [SearchRepository.searchAll].
  Future<void> search(String keyword) async {
    if (keyword.isEmpty) return;

    state = state.copyWith(
      searchKeyword: keyword,
      isLoading: true,
      clearError: true,
    );

    _recordToHistory(keyword);

    try {
      final result = await _searchRepo.searchAll(
        keyword: keyword,
        page: 1,
      );
      state = switch (result) {
        Loading() => state.copyWith(isLoading: true),
        Success(:final response) => state.copyWith(
          searchResults: response,
          isLoading: false,
        ),
        Error(:final errMsg) => state.copyWith(
          errorMessage: errMsg,
          isLoading: false,
        ),
      };
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Fetch search suggestions for the given [term].
  Future<List<CoreSearchSuggestItem>> fetchSuggestions(String term) async {
    if (term.isEmpty) return const [];

    final result = await _searchRepo.searchSuggest(term: term);
    return switch (result) {
      Success(:final response) => response.tag ?? const [],
      _ => const [],
    };
  }

  /// Fetch trending search terms.
  Future<LoadingState<CoreSearchTrendingData>> fetchTrending({
    int limit = 10,
  }) {
    return _searchRepo.searchTrending(limit: limit);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Provider for the [SearchRepository] — resolved from the active adapter.
///
/// This allows the controller to remain adapter-agnostic while still
/// accessing the correct search implementation.
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  throw UnimplementedError(
    'searchRepositoryProvider must be overridden by the adapter layer.',
  );
});

/// Provider for the search page controller.
final searchPageProvider =
    StateNotifierProvider.autoDispose<SearchPageController, SearchPageState>(
  SearchPageController.new,
);
