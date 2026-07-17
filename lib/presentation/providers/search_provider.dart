import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/city_entity.dart';
import 'core_providers.dart';

enum SearchStatus { idle, loading, loaded, error, empty }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<CityEntity> results;
  final List<String> history;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.idle,
    this.results = const [],
    this.history = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<CityEntity>? results,
    List<String>? history,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, results, history, errorMessage];
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref ref;
  Timer? _debounce;

  SearchNotifier(this.ref) : super(const SearchState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final result = await ref.read(weatherRepositoryProvider).getSearchHistory();
    result.fold((_) {}, (history) {
      state = state.copyWith(history: history);
    });
  }

  /// Debounced search — cancels the previous timer on every keystroke.
  void onQueryChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(status: SearchStatus.idle, results: []);
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () => _performSearch(query),
    );
  }

  Future<void> _performSearch(String query) async {
    final searchUseCase = ref.read(searchCityProvider);
    final result = await searchUseCase.call(query);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: SearchStatus.error,
          errorMessage: failure.message,
          results: [],
        );
      },
      (cities) {
        state = state.copyWith(
          status: cities.isEmpty ? SearchStatus.empty : SearchStatus.loaded,
          results: cities,
        );
      },
    );
  }

  Future<void> commitToHistory(String query) async {
    await ref.read(weatherRepositoryProvider).addSearchHistory(query);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await ref.read(weatherRepositoryProvider).clearSearchHistory();
    state = state.copyWith(history: []);
  }

  void clearResults() {
    _debounce?.cancel();
    state = state.copyWith(status: SearchStatus.idle, results: []);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(ref),
);
