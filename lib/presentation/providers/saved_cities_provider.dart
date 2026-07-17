import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/city_entity.dart';
import 'core_providers.dart';

enum SavedCitiesStatus { initial, loading, loaded, error }

class SavedCitiesState extends Equatable {
  final SavedCitiesStatus status;
  final List<CityEntity> allCities;
  final int visibleCount;
  final String? errorMessage;

  const SavedCitiesState({
    this.status = SavedCitiesStatus.initial,
    this.allCities = const [],
    this.visibleCount = AppConstants.pageSize,
    this.errorMessage,
  });

  List<CityEntity> get visibleCities =>
      allCities.take(visibleCount).toList(growable: false);

  bool get hasMore => visibleCount < allCities.length;

  List<CityEntity> get favorites =>
      allCities.where((c) => c.isFavorite).toList(growable: false);

  SavedCitiesState copyWith({
    SavedCitiesStatus? status,
    List<CityEntity>? allCities,
    int? visibleCount,
    String? errorMessage,
  }) {
    return SavedCitiesState(
      status: status ?? this.status,
      allCities: allCities ?? this.allCities,
      visibleCount: visibleCount ?? this.visibleCount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allCities, visibleCount, errorMessage];
}

class SavedCitiesNotifier extends StateNotifier<SavedCitiesState> {
  final Ref ref;
  SavedCitiesNotifier(this.ref) : super(const SavedCitiesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(status: SavedCitiesStatus.loading);
    final result = await ref.read(getSavedCitiesProvider).call();
    result.fold(
      (failure) => state = state.copyWith(
        status: SavedCitiesStatus.error,
        errorMessage: failure.message,
      ),
      (cities) => state = state.copyWith(
        status: SavedCitiesStatus.loaded,
        allCities: cities,
        visibleCount: AppConstants.pageSize,
      ),
    );
  }

  /// "Load more" / infinite scroll — purely local pagination since the
  /// weather API itself doesn't paginate saved cities.
  void loadMore() {
    if (!state.hasMore) return;
    state = state.copyWith(
      visibleCount: state.visibleCount + AppConstants.pageSize,
    );
  }

  Future<void> addCity(CityEntity city) async {
    await ref.read(saveCityProvider).call(city);
    await load();
  }

  Future<void> renameCity(int id, String nickname) async {
    await ref.read(updateCityNicknameProvider).call(id, nickname);
    await load();
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    await ref.read(toggleFavoriteCityProvider).call(id, isFavorite);
    await load();
  }

  Future<void> deleteCity(int id) async {
    await ref.read(deleteCityProvider).call(id);
    await load();
  }
}

final savedCitiesNotifierProvider =
    StateNotifierProvider<SavedCitiesNotifier, SavedCitiesState>(
  (ref) => SavedCitiesNotifier(ref),
);

/// Recently viewed cities (separate, smaller list capped at 10 by the DB layer).
final recentlyViewedProvider = FutureProvider<List<CityEntity>>((ref) async {
  final result = await ref.read(weatherRepositoryProvider).getRecentlyViewed();
  return result.fold((_) => <CityEntity>[], (list) => list);
});
