class FavoriteHealer {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final String language;
  final String? imageUrl;
  final List<String> category;
  final bool isFavorite;

  const FavoriteHealer({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.language,
    this.imageUrl,
    this.category = const <String>[],
    this.isFavorite = true,
  });

  factory FavoriteHealer.fromHealerCard({
    required String id,
    required String name,
    required String specialty,
    required String location,
    required String language,
    String? imageUrl,
  }) {
    return FavoriteHealer(
      id: id,
      name: name,
      specialty: specialty,
      location: location,
      language: language,
      imageUrl: imageUrl,
    );
  }

  factory FavoriteHealer.fromJson(Map<String, dynamic> json) {
    return FavoriteHealer(
      id: (json['id'] ?? '').toString(),
      name: (json['title'] ?? '') as String,
      specialty: (json['excerpt'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      language: (json['language'] ?? '') as String,
      imageUrl: json['featured_image'] as String?,
      category: (json['category'] as List?)?.whereType<String>().toList() ?? const <String>[],
      isFavorite: true,
    );
  }
}
