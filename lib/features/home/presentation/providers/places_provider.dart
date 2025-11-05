import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/features/home/data/models/place.dart';
import 'package:healer_map_flutter/features/home/data/repositories/places_repository.dart';

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  return PlacesRepository();
});

final placesProvider = FutureProvider.autoDispose<List<Place>>((ref) async {
  final repo = ref.watch(placesRepositoryProvider);
  return repo.fetchPlaces();
});
