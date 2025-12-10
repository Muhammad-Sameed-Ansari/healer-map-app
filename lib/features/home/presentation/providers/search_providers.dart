import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/features/home/data/models/place.dart';
import 'package:healer_map_flutter/features/home/presentation/models/search_filters.dart';
import 'package:healer_map_flutter/features/home/presentation/providers/places_provider.dart';

// Holds current search text
final searchTextProvider = StateProvider<String>((ref) => '');

// Holds current filters
final searchFiltersProvider = StateProvider<SearchFilters>((ref) => const SearchFilters());

// State for paginated search results
class PaginatedSearchState {
  final List<Place> places;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const PaginatedSearchState({
    this.places = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PaginatedSearchState copyWith({
    List<Place>? places,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedSearchState(
      places: places ?? this.places,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// Notifier for managing paginated search results
class PaginatedSearchNotifier extends StateNotifier<AsyncValue<PaginatedSearchState>> {
  PaginatedSearchNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadInitialResults();
  }

  final Ref ref;

  Future<void> loadInitialResults() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(placesRepositoryProvider);
      final text = ref.read(searchTextProvider);
      final filters = ref.read(searchFiltersProvider);
      
      final combined = SearchFilters(
        search: text.isEmpty ? null : text,
        categoryId: filters.categoryId,
        language: filters.language,
        distanceKm: filters.distanceKm,
        barterAgreement: filters.barterAgreement,
        nearToMe: filters.nearToMe,
        limit: 10,
        page: 1,
      );
      
      final places = await repo.searchPlaces(combined);
      state = AsyncValue.data(PaginatedSearchState(
        places: places,
        currentPage: 1,
        hasMore: places.length >= 10,
        isLoadingMore: false,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    // Set loading more flag
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final repo = ref.read(placesRepositoryProvider);
      final text = ref.read(searchTextProvider);
      final filters = ref.read(searchFiltersProvider);
      
      final nextPage = currentState.currentPage + 1;
      final combined = SearchFilters(
        search: text.isEmpty ? null : text,
        categoryId: filters.categoryId,
        language: filters.language,
        distanceKm: filters.distanceKm,
        barterAgreement: filters.barterAgreement,
        nearToMe: filters.nearToMe,
        limit: 10,
        page: nextPage,
      );
      
      final newPlaces = await repo.searchPlaces(combined);
      final allPlaces = [...currentState.places, ...newPlaces];
      
      state = AsyncValue.data(PaginatedSearchState(
        places: allPlaces,
        currentPage: nextPage,
        hasMore: newPlaces.length >= 10,
        isLoadingMore: false,
      ));
    } catch (e, st) {
      // On error, keep current data but stop loading
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
    }
  }

  void refresh() {
    loadInitialResults();
  }
}

// Provider for paginated search results
final paginatedSearchProvider = StateNotifierProvider.autoDispose<PaginatedSearchNotifier, AsyncValue<PaginatedSearchState>>((ref) {
  final notifier = PaginatedSearchNotifier(ref);
  
  // Watch for changes and trigger refresh
  ref.listen(searchTextProvider, (_, __) {
    notifier.refresh();
  });
  
  ref.listen(searchFiltersProvider, (_, __) {
    notifier.refresh();
  });
  
  return notifier;
});

// Search results based on search text + filters (kept for backward compatibility if needed elsewhere)
final searchResultsProvider = FutureProvider.autoDispose<List<Place>>((ref) async {
  final repo = ref.watch(placesRepositoryProvider);
  final text = ref.watch(searchTextProvider);
  final filters = ref.watch(searchFiltersProvider);
  final combined = SearchFilters(
    search: text.isEmpty ? null : text,
    categoryId: filters.categoryId,
    language: filters.language,
    distanceKm: filters.distanceKm,
    barterAgreement: filters.barterAgreement,
    nearToMe: filters.nearToMe,
    limit: filters.limit,
    page: filters.page,
  );
  return repo.searchPlaces(combined);
});
