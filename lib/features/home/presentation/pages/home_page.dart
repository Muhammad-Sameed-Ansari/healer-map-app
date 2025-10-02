import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/core/utils/shared_pref_instance.dart';
import 'package:healer_map_flutter/features/auth/presentation/controllers/auth_controller.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:healer_map_flutter/features/favourite/presentation/providers/favorites_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
    final List<String> bannerImages = [
      'assets/images/banner1.png',
      'assets/images/banner1.png',
      'assets/images/banner1.png', // Add more images as needed
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 70,),
            // Header with avatar, greeting and Add Business
            Consumer(
              builder: (context, ref, child) {
                final auth = ref.watch(authControllerProvider).value;
                return Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage('assets/images/Welcome.png'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_getTimeBasedGreeting(localizations), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                          Text("${SharedPreference.instance.getString("first_name")} ${SharedPreference.instance.getString("last_name")}",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                      context.push(AppRoutes.search);
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

            // Carousel
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: bannerImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(bannerImages[index]),
                        // fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(bannerImages.length, (index) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: _Dot(active: _currentPage == index),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Section header
            Row(
              children: [
                Text(localizations.healers, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(localizations.seeAll),
                )
              ],
            ),

            // Healer list
            Consumer(
              builder: (context, ref, child) {
                final favoritesNotifier = ref.read(favoritesProvider.notifier);

                return Column(
                  children: [
                    HealerCard(
                      name: 'Dr. John',
                      specialty: 'Dhaka medical (Neur specialist)',
                      location: 'Magnolia, United States',
                      language: 'English',
                      isFavorite: favoritesNotifier.isFavorite('dr_john'),
                      onFavoriteToggle: () {
                        // final healer = FavoriteHealer.fromHealerCard(
                        //   id: 'dr_john',
                        //   name: 'Dr. John',
                        //   specialty: 'Dhaka medical (Neur specialist)',
                        //   location: 'Magnolia, United States',
                        //   language: 'English',
                        // );
                        // favoritesNotifier.toggleFavorite(healer);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
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

  const HealerCard({
    required this.name,
    required this.specialty,
    required this.location,
    required this.language,
    this.isFavorite,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/doctor.png', width: 90, height: 90, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
                Text(specialty, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                Spacer(),
                Row(
                  children: [
                    const Icon(Icons.place, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    Expanded(child: Text(location, style: Theme.of(context).textTheme.bodySmall)),
                    const SizedBox(width: 8),
                    Image.asset("assets/icons/profile_language.png",height: 18,color: Colors.purple,),
                    const SizedBox(width: 4),
                    Text(language, style: Theme.of(context).textTheme.bodySmall),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
