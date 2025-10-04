import 'package:dio/dio.dart';
import 'package:healer_map_flutter/core/constants/api_constants.dart';
import 'package:healer_map_flutter/core/network/dio_client.dart';
import 'package:healer_map_flutter/features/blog/data/models/blog_post.dart';

class BlogRepository {
  BlogRepository({DioClient? client}) : _client = client ?? DioClient.instance;

  final DioClient _client;

  Future<List<BlogPost>> fetchPosts() async {
    final Response? res = await _client.get(APIEndpoints.posts);
    if (res == null) return [];

    final data = res.data;

    if (data is Map<String, dynamic>) {
      final status = data['status'] == true;
      final List<dynamic> items =
          (data['data'] as List<dynamic>? ?? <dynamic>[]);
      if (!status) return [];
      return items
          .whereType<Map<String, dynamic>>()
          .map((e) => BlogPost.fromJson(e))
          .toList();
    }

    return [];
  }
}
