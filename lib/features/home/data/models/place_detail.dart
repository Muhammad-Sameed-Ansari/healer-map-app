class PlaceDetail {
  final int id;
  final String title;
  final String excerpt;
  final String? featuredImage;
  final List<String> category;
  final String language;
  final String location;
  final bool isFavorite;
  final String content;
  final String date;
  final String author;
  final String link;
  final List<String> tags;
  final String? barterAgreement;
  final String? rating; // keep as string to mirror API
  final String? reviews; // keep as string to mirror API
  final String? typeOfAppointment;
  final List<PlaceReview> allReviews;

  const PlaceDetail({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.featuredImage,
    required this.category,
    required this.language,
    required this.location,
    required this.isFavorite,
    required this.content,
    required this.date,
    required this.author,
    required this.link,
    required this.tags,
    required this.barterAgreement,
    required this.rating,
    required this.reviews,
    required this.typeOfAppointment,
    required this.allReviews,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    return PlaceDetail(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      excerpt: (json['excerpt'] ?? '') as String,
      featuredImage: json['featured_image'] as String?,
      category: (json['category'] as List?)?.whereType<String>().toList() ?? const <String>[],
      language: (json['language'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      isFavorite: (json['is_favorite'] ?? false) as bool,
      content: (json['content'] ?? '') as String,
      date: (json['date'] ?? '') as String,
      author: (json['author'] ?? '') as String,
      link: (json['link'] ?? '') as String,
      tags: (json['tags'] as String? ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      barterAgreement: json['barter_agreement'] as String?,
      rating: json['rating']?.toString(),
      reviews: json['reviews']?.toString(),
      typeOfAppointment: json['type_of_appointment'] as String?,
      allReviews: (json['all_reviews'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => PlaceReview.fromJson(e))
              .toList() ??
          const <PlaceReview>[],
    );
  }
}

class PlaceReview {
  final String id;
  final String author;
  final String? image;
  final String content;
  final String date;
  final String rating; // string per API

  const PlaceReview({
    required this.id,
    required this.author,
    required this.image,
    required this.content,
    required this.date,
    required this.rating,
  });

  factory PlaceReview.fromJson(Map<String, dynamic> json) {
    return PlaceReview(
      id: (json['id'] ?? '').toString(),
      author: (json['author'] ?? '') as String,
      image: json['image'] as String?,
      content: (json['content'] ?? '') as String,
      date: (json['date'] ?? '') as String,
      rating: (json['rating'] ?? '').toString(),
    );
  }
}
