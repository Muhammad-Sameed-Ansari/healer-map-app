import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/features/favourite/domain/entities/favorite_healer.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<FavoriteHealer>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<List<FavoriteHealer>> {
  FavoritesNotifier() : super([]);

  void addToFavorites(FavoriteHealer healer) {
    if (!state.any((item) => item.id == healer.id)) {
      state = [...state, healer];
    }
  }

  void removeFromFavorites(String healerId) {
    state = state.where((item) => item.id != healerId).toList();
  }

  void toggleFavorite(FavoriteHealer healer) {
    if (state.any((item) => item.id == healer.id)) {
      removeFromFavorites(healer.id);
    } else {
      addToFavorites(healer);
    }
  }

  bool isFavorite(String healerId) {
    return state.any((item) => item.id == healerId);
  }
}
