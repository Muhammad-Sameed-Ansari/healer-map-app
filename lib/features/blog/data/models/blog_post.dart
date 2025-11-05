class BlogPost {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final DateTime date;
  final String author;
  final String featuredImage;
  final String link;

  BlogPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    required this.author,
    required this.featuredImage,
    required this.link,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      id: json['id'] as int,
      title: (json['title'] ?? '').toString(),
      excerpt: (json['excerpt'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      author: (json['author'] ?? '').toString(),
      featuredImage: (json['featured_image'] ?? '').toString(),
      link: (json['link'] ?? '').toString(),
    );
  }
}
