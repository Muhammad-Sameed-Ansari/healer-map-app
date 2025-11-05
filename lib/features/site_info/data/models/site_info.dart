class SiteLanguage {
  final String code;
  final String name; // prefer translated_name, fallback to native_name

  SiteLanguage({required this.code, required this.name});

  factory SiteLanguage.fromJson(Map<String, dynamic> json) {
    return SiteLanguage(
      code: (json['code'] ?? '').toString(),
      name: (json['translated_name'] ?? json['native_name'] ?? '').toString(),
    );
  }
}

class SiteCategoryItem {
  final int id;
  final String slug;
  final String name;

  SiteCategoryItem({required this.id, required this.slug, required this.name});

  factory SiteCategoryItem.fromJson(Map<String, dynamic> json) {
    return SiteCategoryItem(
      id: (json['id'] as num).toInt(),
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class SiteCategoryGroup {
  final int id;
  final String slug; // e.g., 'animals' or 'humans'
  final String name;
  final List<SiteCategoryItem> children;

  SiteCategoryGroup({
    required this.id,
    required this.slug,
    required this.name,
    required this.children,
  });

  factory SiteCategoryGroup.fromJson(Map<String, dynamic> json) {
    final childrenJson = (json['children'] as List?) ?? const [];
    return SiteCategoryGroup(
      id: (json['id'] as num).toInt(),
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      children: childrenJson
          .whereType<Map<String, dynamic>>()
          .map(SiteCategoryItem.fromJson)
          .toList(),
    );
  }
}

class SiteInfo {
  final List<SiteLanguage> languages;
  final List<SiteCategoryGroup> categories;

  SiteInfo({required this.languages, required this.categories});

  factory SiteInfo.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?);
    final langs = (data?['languages'] as List?) ?? const [];
    final cats = (data?['categories'] as List?) ?? const [];

    return SiteInfo(
      languages: langs.whereType<Map<String, dynamic>>()
          .map(SiteLanguage.fromJson)
          .toList(),
      categories: cats.whereType<Map<String, dynamic>>()
          .map(SiteCategoryGroup.fromJson)
          .toList(),
    );
  }
}
