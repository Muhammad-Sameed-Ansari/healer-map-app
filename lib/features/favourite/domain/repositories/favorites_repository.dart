import 'package:healer_map_flutter/features/favourite/domain/entities/favorite_healer.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteHealer>> getFavorites();
  Future<bool> addFavorite(String placeId);
  Future<bool> removeFavorite(String placeId);
}
