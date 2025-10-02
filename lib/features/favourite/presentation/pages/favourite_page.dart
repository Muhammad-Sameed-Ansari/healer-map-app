import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:healer_map_flutter/features/favourite/presentation/providers/favorites_provider.dart';
import 'package:healer_map_flutter/features/home/presentation/pages/home_page.dart';

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
    final favorites = ref.watch(favoritesProvider);

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No favorite healers yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on healer cards to add them to favorites',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return HealerCard(
          name: favorite.name,
          specialty: favorite.specialty,
          location: favorite.location,
          language: favorite.language,
          isFavorite: true,
          onFavoriteToggle: () {
            ref.read(favoritesProvider.notifier).removeFromFavorites(favorite.id);
          },
        );
      },
    );
  }
}
