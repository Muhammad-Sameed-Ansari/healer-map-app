class FavoriteHealer {
  final String id;
  final String name;
  final String specialty;
  final String location;
  final String language;
  final String? imageUrl;

  const FavoriteHealer({
    required this.id,
    required this.name,
    required this.specialty,
    required this.location,
    required this.language,
    this.imageUrl,
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
}
