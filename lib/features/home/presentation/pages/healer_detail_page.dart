import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/common/widgets/custom_text_form_field.dart';
import 'package:healer_map_flutter/common/widgets/custom_button.dart';
import 'package:healer_map_flutter/features/home/data/models/place.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/features/favourite/presentation/controllers/favorites_controller.dart';
import 'package:healer_map_flutter/features/home/presentation/providers/places_provider.dart';
import 'package:healer_map_flutter/features/home/presentation/providers/place_detail_provider.dart';
import 'package:healer_map_flutter/features/home/data/models/place_detail.dart';
import 'package:shimmer/shimmer.dart';
import 'package:healer_map_flutter/features/home/data/repositories/places_repository.dart';

class HealerDetailPage extends ConsumerStatefulWidget {
  final Place place;
  const HealerDetailPage({super.key, required this.place});

  @override
  ConsumerState<HealerDetailPage> createState() => _HealerDetailPageState();
}

class _HealerDetailPageState extends ConsumerState<HealerDetailPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  late bool _isFavorite;
  double _userRating = 0.0; // supports halves
  final TextEditingController _reviewController = TextEditingController();
  bool _postingReview = false;
  bool _postingMessage = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.place.isFavorite;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  String _cleanText(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&hellip;', '…')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('\u00a0', ' ')
        .trim();
  }

  List<String> _languages(String s) {
    return s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  Future<void> _openDirections(String destination) async {
    final encoded = Uri.encodeComponent(destination);
    // Google Maps directions URL; uses current location as origin by default.
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encoded&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to Apple Maps on iOS if available
      final apple = Uri.parse('http://maps.apple.com/?daddr=$encoded');
      if (await canLaunchUrl(apple)) {
        await launchUrl(apple, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.place;
    final detailAsync = ref.watch(placeDetailProvider(p.id));
    final PlaceDetail? detail = detailAsync.value;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Header image (Hero)
          Hero(
            tag: 'healer_${p.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: (p.featuredImage != null && p.featuredImage!.isNotEmpty)
                  ? Image.network(
                      p.featuredImage!,
                      height: 450,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/doctor.png',
                        height: 450,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/doctor.png',
                      height: 450,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          // Overlapping white info card
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 400,),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, -2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Builder(builder: (context) {
                        return detailAsync.when(
                          loading: () => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Row(
                              children: [
                                Container(height: 14, width: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
                              ],
                            ),
                          ),
                          error: (e, st) => Row(
                            children: const [
                              Icon(Icons.star_border, size: 16, color: Colors.amber),
                              SizedBox(width: 6),
                              Text('-'),
                            ],
                          ),
                          data: (d) {
                            final rating = double.tryParse(d?.rating ?? '') ?? 0.0;
                            final reviews = int.tryParse(d?.reviews ?? '') ?? 0;
                            final full = rating.floor().clamp(0, 5);
                            final hasHalf = (rating - full) >= 0.5 && full < 5;
                            final stars = <Widget>[];
                            for (int i = 0; i < full; i++) {
                              stars.add(const Icon(Icons.star, size: 16, color: Colors.amber));
                            }
                            if (hasHalf) {
                              stars.add(const Icon(Icons.star_half, size: 16, color: Colors.amber));
                            }
                            while (stars.length < 5) {
                              stars.add(const Icon(Icons.star_border, size: 16, color: Colors.amber));
                            }
                            return Row(
                              children: [
                                ...stars,
                                const SizedBox(width: 6),
                                Text(rating.toStringAsFixed(1), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(width: 4),
                                Text('(${reviews.toString()})', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45)),
                              ],
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.place, size: 18, color: Color(0xFF7B3A8E)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              p.location,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                              maxLines: 2,)
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset("assets/icons/profile_language.png",height: 18,color: Colors.purple,),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _languages(p.language).join(', '),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Category row
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Category: ',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF7B3A8E),
                                    ),
                              ),
                              TextSpan(
                                text: (p.category.isNotEmpty ? p.category.join(', ') : '—'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Session types row (from detail.typeOfAppointment)
                        Builder(builder: (context) {
                          final types = (detail != null && detail.typeOfAppointment != null && detail.typeOfAppointment!.isNotEmpty)
                              ? detail.typeOfAppointment!
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .join(', ')
                              : '';
                          return RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Session types: ',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF7B3A8E),
                                      ),
                                ),
                                TextSpan(
                                  text: types.isNotEmpty ? types : '—',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 10),

                      // About (shadow card, no border)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Text(
                          (() {
                            final about = (detail != null && detail.content.isNotEmpty) ? detail.content : p.excerpt;
                            final cleaned = _cleanText(about);
                            return cleaned.isEmpty ? 'No description available.' : cleaned;
                          })(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Contact form
                      CustomTextFormField(
                        title: 'Name',
                        hintText: 'Name',
                        controller: _nameController,
                        isForm: true,
                        textInputType: TextInputType.text,
                      ),
                      CustomTextFormField(
                        title: 'Email Address',
                        hintText: 'hello@email.com',
                        controller: _emailController,
                        isForm: true,
                        textFormFieldType: TextFormFieldType.email,
                        textInputType: TextInputType.emailAddress,
                      ),
                      CustomTextFormField(
                        title: 'Message',
                        hintText: 'Write your message here...',
                        controller: _messageController,
                        isForm: true,
                        maxLines: 4,
                        multiLine: true,
                        textInputType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 6),
                      CustomAppButton(
                        width: double.infinity,
                        height: 48,
                        title: 'SUBMIT',
                        loader: _postingMessage,
                        onPressed: () async {
                          setState(() => _postingMessage = true);
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          final msg = _messageController.text.trim();
                          if (name.isEmpty || email.isEmpty || msg.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill name, email and message')),
                            );
                            setState(() => _postingMessage = false);
                            return;
                          }

                          final repo = ref.read(placesRepositoryProvider);
                          try {
                            final SubmitReviewResult result = await repo.submitPlaceMessage(
                              id: widget.place.id,
                              name: name,
                              email: email,
                              message: msg,
                            );
                            if (!mounted) return;
                            if (result.success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result.message), backgroundColor: Colors.green),
                              );
                              _nameController.clear();
                              _emailController.clear();
                              _messageController.clear();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result.message)),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _postingMessage = false);
                          }
                        },
                      ),

                      const SizedBox(height: 20),
                      // Services section (use detail.tags when available, otherwise fallback to p.category)
                      Text('Services', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Builder(builder: (context) {
                        final List<String> services = (detail != null && detail.tags.isNotEmpty)
                            ? detail.tags
                            : p.category;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final c in services) ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle, color: Color(0xFF4A184B), size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      c,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        );
                      }),
                      // Map card
                      Text('Map', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: InAppWebView(
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                              mediaPlaybackRequiresUserGesture: true,
                              allowsInlineMediaPlayback: true,
                              isInspectable: true,
                              useHybridComposition: true,
                              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                              thirdPartyCookiesEnabled: true,
                              geolocationEnabled: true,
                            ),
                            initialUrlRequest: URLRequest(url: WebUri('https://healer-map.com/hm-map-view/${widget.place.id}')),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CustomAppButton(
                        width: double.infinity,
                        height: 48,
                        title: 'Get Directions',
                        onPressed: () => _openDirections(p.location),
                      ),

                      const SizedBox(height: 20),
                      // Reviews header + list from API
                      Builder(builder: (context) {
                        return detailAsync.when(
                          loading: () => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              children: [
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                                ),
                                const SizedBox(height: 8),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                                ),
                                const SizedBox(height: 8),
                                Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(height: 60, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                                ),
                              ],
                            ),
                          ),
                          error: (e, st) => const SizedBox.shrink(),
                          data: (d) {
                            if (d == null) return const SizedBox.shrink();
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Reviews', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.star, size: 18, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text('${d.rating ?? '-'} (${d.reviews ?? '0'})', style: Theme.of(context).textTheme.bodyMedium),
                                    const Spacer(),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (d.allReviews.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                                    child: Text('No reviews yet', style: Theme.of(context).textTheme.bodySmall),
                                  )
                                else ...[
                                  for (final r in d.allReviews) ...[
                                    _ReviewTile(
                                      name: r.author,
                                      timeAgo: r.date,
                                      rating: int.tryParse(r.rating) ?? 0,
                                      comment: r.content,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ],
                              ],
                            );
                          },
                        );
                      }),

                      // Rating selector (interactive, supports half-stars)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            Row(
                              children: List.generate(5, (i) {
                                  final base = i + 1;
                                  IconData icon;
                                  if (_userRating >= base) {
                                    icon = Icons.star;
                                  } else if (_userRating >= base - 0.5) {
                                    icon = Icons.star_half;
                                  } else {
                                    icon = Icons.star_border;
                                  }
                                  return GestureDetector(
                                    onTapDown: (details) {
                                      final localX = details.localPosition.dx;
                                      final half = localX < 12; // approx half width
                                      setState(() {
                                        _userRating = half ? (i + 0.5) : (i + 1).toDouble();
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Icon(icon, color: Colors.amber, size: 22),
                                    ),
                                  );
                                }),
                            ),
                            const SizedBox(width: 8),
                            Text(_userRating == 0 ? 'Select a rating' : _userRating.toStringAsFixed(1)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Leave a Review', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        title: '',
                        hintText: 'Write your review here...',
                        maxLines: 6,
                        multiLine: true,
                        isForm: false,
                        borderRadius: 12,
                        controller: _reviewController,
                      ),
                      const SizedBox(height: 10),
                      CustomAppButton(
                        width: double.infinity,
                        height: 48,
                        title: 'POST REVIEW',
                        loader: _postingReview,
                        onPressed: () async {
                          setState(() => _postingReview = true);
                          if (_userRating == 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a rating')),
                            );
                            setState(() => _postingReview = false);
                            return;
                          }
                          if (_reviewController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please write a review message')),
                            );
                            setState(() => _postingReview = false);
                            return;
                          }

                          // Submit review via repository
                          final repo = ref.read(placesRepositoryProvider);
                          try {
                            final SubmitReviewResult result = await repo.submitPlaceReview(
                              id: widget.place.id,
                              rating: _userRating,
                              content: _reviewController.text.trim(),
                            );
                            if (!mounted) return;
                            if (result.success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result.message),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _reviewController.clear();
                              setState(() {
                                _userRating = 0.0;
                              });
                              // Refresh details to show the new review
                              ref.invalidate(placeDetailProvider(widget.place.id));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result.message)),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _postingReview = false);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Top-left back (placed last to be on top)
          Positioned(
            top: 50,
            left: 25,
            child: _HeaderActionButton(
              icon: Icons.arrow_back,
              onTap: () => context.pop(),
            ),
          ),
          // Top-right favorite (placed last to be on top)
          Positioned(
            top: 50,
            right: 25,
            child: _HeaderActionButton(
              icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
              onTap: () async {
                final favCtrl = ref.read(favoritesControllerProvider.notifier);
                final id = widget.place.id.toString();
                final next = !_isFavorite;
                setState(() {
                  _isFavorite = next; // Optimistic UI
                });
                try {
                  bool ok;
                  if (next) {
                    ok = await favCtrl.addFavorite(id);
                  } else {
                    ok = await favCtrl.removeFavorite(id);
                  }
                  if (!ok) {
                    setState(() {
                      _isFavorite = !next; // revert
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(next ? 'Failed to add to favorites' : 'Failed to remove from favorites')),
                      );
                    }
                  }
                } catch (e) {
                  setState(() {
                    _isFavorite = !next; // revert
                  });
                } finally {
                  // Refresh lists so server truth syncs
                  ref.invalidate(placesProvider);
                  try {
                    await ref.read(placesProvider.future);
                  } catch (_) {}
                  await ref.read(favoritesControllerProvider.notifier).refresh();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey,width: 0.3)
      ),
      child: Material(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Icon(icon, color: icon==Icons.favorite?Colors.red:Colors.black87, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final String timeAgo;
  final int rating; // 1-5
  final String comment;

  const _ReviewTile({
    required this.name,
    required this.timeAgo,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/images/doctor.png')),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                    Text(timeAgo, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (i) => Icon(
                        i < rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      )),
                ),
                const SizedBox(height: 6),
                Text(comment),
              ],
            ),
          )
        ],
      ),
    );
  }
}
