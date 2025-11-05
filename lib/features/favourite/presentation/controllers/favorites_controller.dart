import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/features/favourite/data/repositories/favorites_repository_impl.dart';
import 'package:healer_map_flutter/features/favourite/domain/entities/favorite_healer.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepositoryImpl>((ref) {
  return FavoritesRepositoryImpl();
});

final favoritesControllerProvider = AsyncNotifierProvider<FavoritesController, List<FavoriteHealer>>(FavoritesController.new);

class FavoritesController extends AsyncNotifier<List<FavoriteHealer>> {
  @override
  Future<List<FavoriteHealer>> build() async {
    final repo = ref.read(favoritesRepositoryProvider);
    final list = await repo.getFavorites();
    return list;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(favoritesRepositoryProvider);
      return await repo.getFavorites();
    });
  }

  Future<bool> addFavorite(String placeId) async {
    final repo = ref.read(favoritesRepositoryProvider);
    final ok = await repo.addFavorite(placeId);
    if (ok) {
      // re-fetch favorites list
      await refresh();
    }
    return ok;
  }

  Future<bool> removeFavorite(String placeId) async {
    // Optimistic update: remove immediately from current state
    final previous = state.value ?? <FavoriteHealer>[];
    final updated = previous.where((e) => e.id != placeId).toList();
    state = AsyncData(updated);

    final repo = ref.read(favoritesRepositoryProvider);
    try {
      final ok = await repo.removeFavorite(placeId);
      if (!ok) {
        // revert on failure
        state = AsyncData(previous);
      }
      return ok;
    } catch (e) {
      // revert on error
      state = AsyncData(previous);
      return false;
    }
  }
}
