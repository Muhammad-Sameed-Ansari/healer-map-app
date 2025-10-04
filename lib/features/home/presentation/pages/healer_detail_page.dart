import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/common/widgets/custom_text_form_field.dart';
import 'package:healer_map_flutter/common/widgets/custom_button.dart';
import 'package:healer_map_flutter/features/home/data/models/place.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HealerDetailPage extends StatefulWidget {
  final Place place;
  const HealerDetailPage({super.key, required this.place});

  @override
  State<HealerDetailPage> createState() => _HealerDetailPageState();
}

class _HealerDetailPageState extends State<HealerDetailPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
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
                        height: 230,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/doctor.png',
                      height: 230,
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
                      Row(
                        children: [
                          ...List.generate(5, (i) => Icon(i < 4 ? Icons.star : Icons.star_half, size: 16, color: Colors.amber)),
                          const SizedBox(width: 6),
                          Text('4.5', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 4),
                          Text('Ratings', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45)),
                        ],
                      ),
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
                            const Icon(Icons.translate, size: 18, color: Color(0xFF7B3A8E)),
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
                        // Session types row (using remaining categories as placeholder if provided)
                        if (p.category.isNotEmpty)
                          RichText(
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
                                  text: (p.category.length > 1
                                      ? p.category.sublist(1).join(', ')
                                      : '—'),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
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
                          _cleanText(p.excerpt).isEmpty ? 'No description available.' : _cleanText(p.excerpt),
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Your message has been submitted.')),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                      // Services section
                      Text('Services', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: p.category
                            .map((c) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF4A184B), size: 18),
                            const SizedBox(width: 6),
                            Text(c),
                          ],
                        ))
                            .toList(),
                      ),

                      const SizedBox(height: 20),
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
                            initialUrlRequest: URLRequest(url: WebUri('https://healer-map.com/hm-map-view/')),
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
                      // Reviews header
                      Row(
                        children: [
                          Text('Review', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, size: 18, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('4.9 (34)', style: Theme.of(context).textTheme.bodyMedium),
                          const Spacer(),
                          TextButton(onPressed: () {}, child: const Text('VIEW ALL')),
                        ],
                      ),
                      _ReviewTile(
                        name: 'Mosarraf hosain',
                        timeAgo: '1 day ago',
                        rating: 5,
                        comment: 'Dr. Muhammad is really a nice Doctor. He is very careful & responsible.',
                      ),
                      const SizedBox(height: 12),
                      // Rating selector placeholder
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('Select a rating'),
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
                      ),
                      const SizedBox(height: 10),
                      CustomAppButton(
                        width: double.infinity,
                        height: 48,
                        title: 'POST REVIEW',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review posted')),
                          );
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
              icon: Icons.favorite_border,
              onTap: () {},
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
    return Material(
      color: Colors.white.withOpacity(0.6),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Icon(icon, color: Colors.black87, size: 20),
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
