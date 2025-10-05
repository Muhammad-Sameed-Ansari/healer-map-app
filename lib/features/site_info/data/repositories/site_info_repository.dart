import 'package:dio/dio.dart';
import 'package:healer_map_flutter/core/network/dio_client.dart';
import 'package:healer_map_flutter/features/site_info/data/models/site_info.dart';

class SiteInfoRepository {
  final DioClient _client;
  SiteInfoRepository({DioClient? client}) : _client = client ?? DioClient.instance;

  Future<SiteInfo?> fetchSiteInfo() async {
    final Response? res = await _client.get('site-info');
    if (res == null) return null;
    final data = res.data;
    if (data is Map<String, dynamic> && data['status'] == true) {
      return SiteInfo.fromJson(data);
    }
    return null;
  }
}
