import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/features/home/data/models/place.dart';
import 'package:healer_map_flutter/features/home/presentation/models/search_filters.dart';
import 'package:healer_map_flutter/features/home/presentation/providers/places_provider.dart';

// Holds current search text
final searchTextProvider = StateProvider<String>((ref) => '');

// Holds current filters
final searchFiltersProvider = StateProvider<SearchFilters>((ref) => const SearchFilters());

// Search results based on search text + filters
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
