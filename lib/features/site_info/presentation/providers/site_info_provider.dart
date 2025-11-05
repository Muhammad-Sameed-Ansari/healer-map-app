import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/features/site_info/data/models/site_info.dart';
import 'package:healer_map_flutter/features/site_info/data/repositories/site_info_repository.dart';

final siteInfoRepositoryProvider = Provider<SiteInfoRepository>((ref) {
  return SiteInfoRepository();
});

final siteInfoProvider = FutureProvider<SiteInfo>((ref) async {
  final repo = ref.watch(siteInfoRepositoryProvider);
  final res = await repo.fetchSiteInfo();
  if (res == null) {
    return SiteInfo(languages: const [], categories: const []);
  }
  return res;
});
