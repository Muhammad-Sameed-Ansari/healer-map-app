import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:healer_map_flutter/common/widgets/healer_card_skeleton.dart';
import 'package:healer_map_flutter/features/home/presentation/providers/places_provider.dart';
import 'package:healer_map_flutter/features/home/data/models/place.dart';
import 'package:healer_map_flutter/features/favourite/presentation/controllers/favorites_controller.dart';
import 'package:healer_map_flutter/features/site_info/presentation/providers/site_info_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentPage = 0;
  // Optimistic favorite overrides: placeId -> isFavorite
  final Map<int, bool> _favOverrides = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  // Basic cleaner for common HTML entities from API excerpts
  String _cleanText(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&hellip;', '…')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('\u00a0', ' ')
        .trim();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Function to get time-based greeting
  String _getTimeBasedGreeting(AppLocalizations localizations) {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return localizations.goodMorning;
    } else if (hour >= 12 && hour < 17) {
      return localizations.goodAfternoon;
    } else if (hour >= 17 && hour < 21) {
      return localizations.goodEvening;
    } else {
      return localizations.goodNight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 55,),
            // Header with avatar, greeting and Add Business
            Consumer(
              builder: (context, ref, child) {
                // Prefetch site-info so filters have data ready
                ref.watch(siteInfoProvider);
                final authUser = ref.watch(authControllerProvider).value;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: (authUser?.avatarUrl != null && authUser!.avatarUrl!.isNotEmpty)
                          ? NetworkImage(authUser.avatarUrl!)
                          : const AssetImage('assets/images/Welcome.png') as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getTimeBasedGreeting(localizations), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                          Text(
                            "${authUser?.firstName ?? ''} ${authUser?.lastName ?? ''}".trim(),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: ()async {
                        // context.push(AppRoutes.search);
                        await launchUrl(Uri.parse("https://healer-map.com/join/"));
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: ColorConstants.primary,
                        foregroundColor: ColorConstants.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      child: Text(localizations.addBusiness),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Search + Filter
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      context.push(AppRoutes.search);
                    },
                    child: AbsorbPointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Image.asset("assets/icons/search.png",scale: 1.5,),
                            hintText: localizations.findHealers,
                            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(14))),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: ColorConstants.primary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      context.push(AppRoutes.search);
                    },
                    icon: Image.asset("assets/icons/filter.png",height: 20,width: 20,),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 8),

            // Section header
            Row(
              children: [
                Text(localizations.healers, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.push(AppRoutes.search);
                  },
                  child: Text(localizations.seeAll),
                )
              ],
            ),

            // Healer list
            Consumer(
              builder: (context, ref, child) {
                final placesAsync = ref.watch(placesProvider);

                return placesAsync.when(
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: const [
                        ShimmerHealerCardSkeleton(),
                        ShimmerHealerCardSkeleton(),
                        ShimmerHealerCardSkeleton(),
                        ShimmerHealerCardSkeleton(),
                        ShimmerHealerCardSkeleton(),
                      ],
                    ),
                  ),
                  error: (e, st) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Failed to load healers',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                    ),
                  ),
                  data: (List<Place> places) {
                    if (places.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No healers found',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (final p in places) ...[
                          GestureDetector(
                            onTap: () {
                              context.push(AppRoutes.healerDetail, extra: p);
                            },
                            child: HealerCard(
                              name: p.title,
                              specialty: _cleanText(p.excerpt),
                              location: p.location,
                              language: p.language,
                              imageUrl: p.featuredImage,
                              isFavorite: _favOverrides[p.id] ?? p.isFavorite,
                              isPaid: p.isPaid,
                              heroTag: 'healer_${p.id}',
                              onFavoriteToggle: () async {
                                final favCtrl = ref.read(favoritesControllerProvider.notifier);
                                final id = p.id.toString();
                                final previous = _favOverrides.containsKey(p.id)
                                    ? _favOverrides[p.id]!
                                    : p.isFavorite;
                                final next = !previous;
                                setState(() {
                                  _favOverrides[p.id] = next; // Optimistic UI
                                });
                                try {
                                  bool ok;
                                  if (next) {
                                    ok = await favCtrl.addFavorite(id);
                                  } else {
                                    ok = await favCtrl.removeFavorite(id);
                                  }
                                  if (!ok) {
                                    // Revert and inform user on failure
                                    setState(() {
                                      _favOverrides[p.id] = previous;
                                    });
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(next ? 'Failed to add to favorites' : 'Failed to remove from favorites')),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  // Revert on exception
                                  setState(() {
                                    _favOverrides[p.id] = previous;
                                  });
                                } finally {
                                  // Refresh lists from API so UI reflects server state
                                  ref.invalidate(placesProvider);
                                  try {
                                    await ref.read(placesProvider.future);
                                  } catch (_) {}
                                  await ref.read(favoritesControllerProvider.notifier).refresh();
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ]
                      ],
                    );
                  }
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 10 : 6,
      height: active ? 10 : 6,
      decoration: BoxDecoration(
        color: active ? ColorConstants.primary : Colors.black26,
        shape: BoxShape.circle,
      ),
    );
  }
}

class HealerCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String location;
  final String language;
  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;
  final String? imageUrl;
  final String? heroTag;
  final bool isPaid;

  const HealerCard({
    required this.name,
    required this.specialty,
    required this.location,
    required this.language,
    this.isFavorite,
    this.onFavoriteToggle,
    this.imageUrl,
    this.heroTag,
    this.isPaid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 8),
      // padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPaid ? Border.all(color: const Color(0xFFFFD700), width: 2.5) : null,
        boxShadow: [
          BoxShadow(
            color: isPaid ? const Color(0xFFFFD700).withOpacity(0.3) : Colors.black.withOpacity(0.1), 
            blurRadius: isPaid ? 16 : 12, 
            offset: const Offset(0, 6)
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: heroTag != null
                    ? Hero(
                        tag: heroTag!,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl != null && imageUrl!.isNotEmpty
                              ? Image.network(
                                  imageUrl!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    'assets/images/doctor.png',
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset('assets/images/doctor.png', width: 90, height: 90, fit: BoxFit.cover),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl != null && imageUrl!.isNotEmpty
                            ? Image.network(
                                imageUrl!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/doctor.png',
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset('assets/images/doctor.png', width: 90, height: 90, fit: BoxFit.cover),
                      ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0,bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                          IconButton(
                            onPressed: onFavoriteToggle,
                            icon: Icon(
                              isFavorite == true ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite == true ? Colors.red : null,
                            ),
                          )
                        ],
                      ),
                      Text(
                        specialty,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54,fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.place, size: 14, color: Colors.purple),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              location,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset("assets/icons/profile_language.png",height: 14,color: Colors.purple,),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              language,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          // Premium/Paid badge
          if (isPaid)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'PREMIUM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
