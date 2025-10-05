import 'package:dio/dio.dart';
import 'package:healer_map_flutter/core/constants/api_constants.dart';
import 'package:healer_map_flutter/core/network/dio_client.dart';
import 'package:healer_map_flutter/features/home/data/models/place.dart';
import 'package:healer_map_flutter/features/home/data/models/place_detail.dart';
import 'package:healer_map_flutter/features/home/presentation/models/search_filters.dart';

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

  Future<List<Place>> searchPlaces(SearchFilters filters) async {
    final Response? res = await _client.get(APIEndpoints.places, queryParameters: filters.toQuery());
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

  Future<PlaceDetail?> fetchPlaceDetail(int id) async {
    final Response? res = await _client.get('place/$id');
    if (res == null) return null;

    final data = res.data;
    if (data is Map<String, dynamic>) {
      final status = data['status'] == true;
      if (!status) return null;
      final Map<String, dynamic>? item = data['data'] as Map<String, dynamic>?;
      if (item == null) return null;
      return PlaceDetail.fromJson(item);
    }

    return null;
  }

  Future<SubmitReviewResult> submitPlaceReview({
    required int id,
    required double rating,
    required String content,
  }) async {
    final Response? res = await _client.post('place/$id/review', data: {
      'rating': rating.toString(),
      'comment': content,
    });
    if (res == null) return const SubmitReviewResult(success: false, message: 'No response');
    final data = res.data;
    if (data is Map<String, dynamic>) {
      final bool status = data['status'] == true;
      final bool inner = (data['data'] is Map<String, dynamic>) ? ((data['data'] as Map<String, dynamic>)['success'] == true) : false;
      final String msg = (data['message'] ?? '').toString().trim();
      return SubmitReviewResult(success: status && inner, message: msg.isEmpty ? (status ? 'Review posted' : 'Failed to post review') : msg);
    }
    return const SubmitReviewResult(success: false, message: 'Unexpected response');
  }

}

class SubmitReviewResult {
  final bool success;
  final String message;
  const SubmitReviewResult({required this.success, required this.message});
}
