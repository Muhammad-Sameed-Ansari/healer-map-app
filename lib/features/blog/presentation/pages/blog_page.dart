import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:healer_map_flutter/features/blog/data/models/blog_post.dart';
import 'package:healer_map_flutter/features/blog/data/repositories/blog_repository.dart';

final blogPostsProvider = FutureProvider<List<BlogPost>>((ref) async {
  return BlogRepository().fetchPosts();
});

class BlogPage extends ConsumerWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final postsAsync = ref.watch(blogPostsProvider);
    return AppScaffold(
      title: localizations.blog,
      showBack: false,
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Failed to load posts',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        data: (posts) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return _BlogCard(post: posts[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  const _BlogCard({required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/blog-detail', extra: post);
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColorConstants.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Hero(
                  tag: 'post-image-${post.id}',
                  child: post.featuredImage.isNotEmpty
                      ? Image.network(post.featuredImage, fit: BoxFit.cover)
                      : Image.asset(
                          'assets/images/blog_bannar.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Hero(
                  tag: 'post-title-${post.id}',
                  flightShuttleBuilder:
                      (context, animation, direction, fromContext, toContext) {
                        return DefaultTextStyle(
                          style: DefaultTextStyle.of(toContext).style,
                          child: (direction == HeroFlightDirection.push
                              ? toContext.widget
                              : fromContext.widget),
                        );
                      },
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(
                      post.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  post.excerpt
                      .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
                      .trim(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ColorConstants.secondary2,
                    fontSize: 10,
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Read More',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ColorConstants.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.chevron_right,
                      color: ColorConstants.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
