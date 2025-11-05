class Place {
  final int id;
  final String title;
  final String excerpt;
  final String? featuredImage;
  final List<String> category;
  final String language;
  final String location;
  final bool isFavorite;

  const Place({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.featuredImage,
    required this.category,
    required this.language,
    required this.location,
    required this.isFavorite,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      excerpt: (json['excerpt'] ?? '') as String,
      featuredImage: json['featured_image'] as String?,
      category: (json['category'] as List?)
              ?.whereType<String>()
              .toList() ??
          const <String>[],
      language: (json['language'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      isFavorite: (json['is_favorite'] ?? false) as bool,
    );
  }
}
