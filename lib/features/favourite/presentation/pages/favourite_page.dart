import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/features/favourite/presentation/controllers/favorites_controller.dart';
import 'package:healer_map_flutter/features/home/presentation/pages/home_page.dart';
import 'package:healer_map_flutter/features/home/data/models/place.dart';

class FavouritePage extends ConsumerWidget {
  const FavouritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    return AppScaffold(
      title: localizations.favorites,
      body: const FavoritesListView(),
    );
  }
}

class FavoritesListView extends ConsumerWidget {
  const FavoritesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFavorites = ref.watch(favoritesControllerProvider);

    return asyncFavorites.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(err.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.read(favoritesControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
      data: (favorites) {
        if (favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No favorite healers yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the heart icon on healer cards to add them to favorites',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(favoritesControllerProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final f = favorites[index];
              return Column(
                children: [
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.healerDetail, extra: _toPlace(f)),
                    child: HealerCard(
                      name: f.name,
                      specialty: f.specialty,
                      location: f.location,
                      language: f.language,
                      imageUrl: f.imageUrl,
                      isFavorite: true,
                      heroTag: 'healer_${f.id}',
                      onFavoriteToggle: () async {
                        // Remove from favorites
                        await ref.read(favoritesControllerProvider.notifier).removeFavorite(f.id);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// Helper to convert FavoriteHealer to Place for detail page reuse
Place _toPlace(f) {
  return Place(
    id: int.tryParse(f.id) ?? 0,
    title: f.name,
    excerpt: f.specialty,
    featuredImage: f.imageUrl,
    category: f.category,
    language: f.language,
    location: f.location,
    isFavorite: true,
  );
}
