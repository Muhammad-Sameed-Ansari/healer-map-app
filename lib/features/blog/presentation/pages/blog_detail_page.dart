import 'package:flutter/material.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/features/blog/data/models/blog_post.dart';

class BlogDetailPage extends StatelessWidget {
  const BlogDetailPage({super.key, required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: post.title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.featuredImage.isNotEmpty)
              Hero(
                tag: 'post-image-${post.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(post.featuredImage, fit: BoxFit.cover),
                ),
              ),
            const SizedBox(height: 16),
            Hero(
              tag: 'post-title-${post.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              post.author,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ColorConstants.secondary2,
              ),
            ),
            const SizedBox(height: 16),
            // Show HTML content as plain text for now
            Text(
              post.content.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
