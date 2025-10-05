import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/features/home/data/models/place_detail.dart';
import 'package:healer_map_flutter/features/home/presentation/providers/places_provider.dart';

final placeDetailProvider = FutureProvider.family.autoDispose<PlaceDetail?, int>((ref, id) async {
  final repo = ref.watch(placesRepositoryProvider);
  return repo.fetchPlaceDetail(id);
});
