class Place {
  final int id;
  final String title;
  final String excerpt;
  final String? featuredImage;
  final List<String> category;
  final String language;
  final String location;
  final bool isFavorite;
  final bool isPaid;
  final int? packageId;
  final bool isSubscribed;
  final String? planName;

  const Place({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.featuredImage,
    required this.category,
    required this.language,
    required this.location,
    required this.isFavorite,
    this.isPaid = false,
    this.packageId,
    this.isSubscribed = false,
    this.planName,
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
      packageId: json['package_id'] as int?,
      isSubscribed: (json['is_subscribed'] ?? false) as bool,
      planName: json['plan_name'] as String?,
      // isPaid is true only if subscribed AND packageId is 4 or 5
      isPaid: (json['is_subscribed'] ?? false) as bool && 
              (json['package_id'] == 4 || json['package_id'] == 5),
    );
  }
}
