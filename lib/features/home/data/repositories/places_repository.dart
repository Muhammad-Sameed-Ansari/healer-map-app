import 'package:dio/dio.dart';
import 'package:healer_map_flutter/core/constants/api_constants.dart';
import 'package:healer_map_flutter/core/network/dio_client.dart';
import 'package:healer_map_flutter/features/home/data/models/place.dart';

class PlacesRepository {
  PlacesRepository({DioClient? client}) : _client = client ?? DioClient.instance;

  final DioClient _client;

  Future<List<Place>> fetchPlaces() async {
    final Response? res = await _client.get(APIEndpoints.places);
    if (res == null) return [];

    final data = res.data;
    if (data is Map<String, dynamic>) {
      final status = data['status'] == true;
      if (!status) return [];
      final List<dynamic> items = (data['data'] as List<dynamic>? ?? <dynamic>[]);
      return items
          .whereType<Map<String, dynamic>>()
          .map((e) => Place.fromJson(e))
          .toList();
    }

    return [];
  }
}
