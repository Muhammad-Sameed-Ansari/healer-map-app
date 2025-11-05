import 'package:dio/dio.dart';
import 'package:healer_map_flutter/core/network/dio_client.dart';
import 'package:healer_map_flutter/features/favourite/domain/entities/favorite_healer.dart';
import 'package:healer_map_flutter/features/favourite/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final DioClient _client;
  FavoritesRepositoryImpl({DioClient? client}) : _client = client ?? DioClient.instance;

  @override
  Future<List<FavoriteHealer>> getFavorites() async {
    final Response? res = await _client.get('favorites');
    if (res == null) return [];

    final data = res.data;
    if (data is Map<String, dynamic>) {
      final status = data['status'] == true;
      final list = data['data'];
      if (status && list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(FavoriteHealer.fromJson)
            .toList();
      }
    }
    return [];
  }

  @override
  Future<bool> addFavorite(String placeId) async {
    final Response? res = await _client.post('favorite/add', data: {
      'id': placeId,
    });
    if (res == null) return false;
    final data = res.data;
    if (data is Map<String, dynamic>) {
      final status = data['status'] == true;
      final success = (data['data'] is Map) ? (data['data']['success'] == true) : false;
      return status && success;
    }
    return false;
  }

  @override
  Future<bool> removeFavorite(String placeId) async {
    final Response? res = await _client.delete('favorites/$placeId');
    if (res == null) return false;
    final data = res.data;
    if (data is Map<String, dynamic>) {
      final status = data['status'] == true;
      final success = (data['data'] is Map) ? (data['data']['success'] == true) : false;
      return status && success;
    }
    return false;
  }
}
