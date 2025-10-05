import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/common/widgets/custom_dropdown_form_field.dart';
import 'package:healer_map_flutter/common/widgets/healer_card_skeleton.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:healer_map_flutter/features/home/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/features/site_info/presentation/providers/site_info_provider.dart';
import 'package:healer_map_flutter/features/favourite/presentation/controllers/favorites_controller.dart';

import '../models/search_filters.dart';
import '../providers/search_providers.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isFilterApplied = false;

  @override
  void dispose() {
    // Clear search text and filters when leaving Search page
    ref.read(searchTextProvider.notifier).state = '';
    ref.read(searchFiltersProvider.notifier).state = const SearchFilters();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const FilterBottomSheet();
      },
    ).then((value) {
      if (value != null && value) {
        setState(() {
          _isFilterApplied = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AppScaffold(
      title: localizations.healers,
      body: Column(
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      // Update global search text for provider-driven results
                      ref.read(searchTextProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      prefixIcon: Image.asset(
                        "assets/icons/search.png",
                        scale: 1.5,
                      ),
                      hintText: localizations.findHealers,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: ColorConstants.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _showFilterBottomSheet,
                  icon: Image.asset(
                    "assets/icons/filter.png",
                    width: 20,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),

          // Applied Filters Chips
          Consumer(
            builder: (context, ref, _) {
              final filters = ref.watch(searchFiltersProvider);
              final siteInfoAsync = ref.watch(siteInfoProvider);

              // Resolve category display name from id, if available
              String? categoryName;
              siteInfoAsync.when(
                data: (site) {
                  if (filters.categoryId != null) {
                    for (final g in site.categories) {
                      for (final c in g.children) {
                        if (c.id.toString() == filters.categoryId) {
                          categoryName = c.name.replaceAll('&amp;', '&');
                          break;
                        }
                      }
                      if (categoryName != null) break;
                    }
                  }
                },
                loading: () {},
                error: (e, st) {},
              );

              final hasAny = (filters.categoryId?.isNotEmpty ?? false) ||
                  (filters.language?.isNotEmpty ?? false) ||
                  (filters.distanceKm?.isNotEmpty ?? false) ||
                  filters.nearToMe ||
                  filters.barterAgreement;

              // Sync local flag for empty-state messaging below
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_isFilterApplied != hasAny) {
                  setState(() {
                    _isFilterApplied = hasAny;
                  });
                }
              });

              if (!hasAny) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (filters.language != null && filters.language!.isNotEmpty)
                      _FilterChipLabel(
                        label: filters.language!,
                        onDeleted: () {
                          ref.read(searchFiltersProvider.notifier).state = SearchFilters(
                            categoryId: filters.categoryId,
                            language: null,
                            distanceKm: filters.distanceKm,
                            barterAgreement: filters.barterAgreement,
                            nearToMe: filters.nearToMe,
                            limit: filters.limit,
                            page: filters.page,
                          );
                        },
                      ),
                    if ((filters.categoryId?.isNotEmpty ?? false))
                      _FilterChipLabel(
                        label: categoryName ?? 'Category',
                        onDeleted: () {
                          ref.read(searchFiltersProvider.notifier).state = SearchFilters(
                            categoryId: null,
                            language: filters.language,
                            distanceKm: filters.distanceKm,
                            barterAgreement: filters.barterAgreement,
                            nearToMe: filters.nearToMe,
                            limit: filters.limit,
                            page: filters.page,
                          );
                        },
                      ),
                    if ((filters.distanceKm?.isNotEmpty ?? false))
                      _FilterChipLabel(
                        label: '≤ ${filters.distanceKm} km',
                        onDeleted: () {
                          ref.read(searchFiltersProvider.notifier).state = SearchFilters(
                            categoryId: filters.categoryId,
                            language: filters.language,
                            distanceKm: null,
                            barterAgreement: filters.barterAgreement,
                            nearToMe: filters.nearToMe,
                            limit: filters.limit,
                            page: filters.page,
                          );
                        },
                      ),
                    if (filters.nearToMe)
                      _FilterChipLabel(
                        label: 'Near to me',
                        onDeleted: () {
                          ref.read(searchFiltersProvider.notifier).state = SearchFilters(
                            categoryId: filters.categoryId,
                            language: filters.language,
                            distanceKm: filters.distanceKm,
                            barterAgreement: filters.barterAgreement,
                            nearToMe: false,
                            limit: filters.limit,
                            page: filters.page,
                          );
                        },
                      ),
                    if (filters.barterAgreement)
                      _FilterChipLabel(
                        label: 'Barter',
                        onDeleted: () {
                          ref.read(searchFiltersProvider.notifier).state = SearchFilters(
                            categoryId: filters.categoryId,
                            language: filters.language,
                            distanceKm: filters.distanceKm,
                            barterAgreement: false,
                            nearToMe: filters.nearToMe,
                            limit: filters.limit,
                            page: filters.page,
                          );
                        },
                      ),
                    // Clear all
                    InputChip(
                      label: const Text('Clear all'),
                      onPressed: () {
                        ref.read(searchFiltersProvider.notifier).state = const SearchFilters();
                      },
                      onDeleted: null,
                    ),
                  ],
                ),
              );
            },
          ),

          // Search Results
          Expanded(
            child: SearchResultsList(
              searchQuery: _searchQuery,
              hasActiveFilters: _isFilterApplied,
            ),
          ),
        ],
      ),
    );
  }
}

class SearchResultsList extends ConsumerStatefulWidget {
  final String searchQuery;
  final bool hasActiveFilters;

  const SearchResultsList({
    super.key,
    required this.searchQuery,
    required this.hasActiveFilters,
  });

  @override
  ConsumerState<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends ConsumerState<SearchResultsList> {
  // Optimistic favorite overrides: placeId -> isFavorite
  final Map<int, bool> _favOverrides = {};

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: const [
              ShimmerHealerCardSkeleton(),
              ShimmerHealerCardSkeleton(),
              ShimmerHealerCardSkeleton(),
            ],
          ),
        ),
      ),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('Failed to load results', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red)),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
      data: (places) {
        if (places.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No healers found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.hasActiveFilters ? 'Try adjusting your filters or search terms' : 'Try searching for a healer name or specialty',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: places.length,
          itemBuilder: (context, index) {
            final p = places[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.healerDetail, extra: p),
                child: HealerCard(
                  name: p.title,
                  specialty: p.excerpt,
                  location: p.location,
                  language: p.language,
                  imageUrl: p.featuredImage,
                  isFavorite: _favOverrides[p.id] ?? p.isFavorite,
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
                      if (next) {
                        await favCtrl.addFavorite(id);
                      } else {
                        await favCtrl.removeFavorite(id);
                      }
                    } catch (e) {
                      // Revert on error
                      setState(() {
                        _favOverrides[p.id] = previous;
                      });
                    } finally {
                      // Refresh to sync with latest server state
                      ref.invalidate(searchResultsProvider);
                      await ref.read(favoritesControllerProvider.notifier).refresh();
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  // First category: Animal or Human
  String? selectedPatientType;

  // Second category
  String? selectedMajorCategory2;

  // Language and Distance
  String? selectedLanguage;
  String? selectedDistance;

  // Checkboxes
  bool nearToMe = false;
  bool barterAgreement = false;

  @override
  void initState() {
    super.initState();
    // Seed from current provider state so filters persist while on the Search page
    final current = ref.read(searchFiltersProvider);
    selectedMajorCategory2 = current.categoryId;
    selectedLanguage = current.language;
    selectedDistance = current.distanceKm;
    nearToMe = current.nearToMe;
    barterAgreement = current.barterAgreement;
    // selectedPatientType cannot be derived reliably from current data, keep as-is
  }

  @override
  Widget build(BuildContext context) {
    final siteInfoAsync = ref.watch(siteInfoProvider);

    // Build dynamic lists from API when available
    List<DropdownMenuItem<String>> languageItems = const [];
    List<DropdownMenuItem<String>> serviceCategoryItems = const [];

    siteInfoAsync.when(
      data: (site) {
        // Use language display name as value, as API expects 'German', etc.
        languageItems = site.languages
            .map((l) =>
            DropdownMenuItem<String>(value: l.name, child: Text(l.name)))
            .toList();

        // Filter categories based on patient type if selected
        final groups = site.categories;
        final filteredGroups = selectedPatientType == null
            ? groups
            : groups.where((g) =>
        (selectedPatientType == 'human' &&
            g.slug.toLowerCase().contains('human')) ||
            (selectedPatientType == 'animal' &&
                g.slug.toLowerCase().contains('animal')),
        ).toList();

        final children = filteredGroups.expand((g) => g.children).toList();
        serviceCategoryItems = children
            .map((c) =>
            DropdownMenuItem<String>(
              value: c.id.toString(),
              child: Text(c.name.replaceAll('&amp;', '&')),
            ))
            .toList();
      },
      loading: () {},
      error: (e, st) {},
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Filters',
            style: Theme
                .of(
              context,
            )
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),

          // Filter Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Category: Animal or Human - Visual Selection
                Row(
                  children: [
                    Expanded(
                      child: _PatientTypeCard(
                        title: 'Human',
                        icon: Icons.person,
                        isSelected: selectedPatientType == 'human',
                        onTap: () {
                          setState(() {
                            selectedPatientType = 'human';
                            // Clear selected category when switching patient type
                            selectedMajorCategory2 = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PatientTypeCard(
                        title: 'Animal',
                        icon: Icons.pets,
                        isSelected: selectedPatientType == 'animal',
                        onTap: () {
                          setState(() {
                            selectedPatientType = 'animal';
                            // Clear selected category when switching patient type
                            selectedMajorCategory2 = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                // Service Category (from site-info API)
                CustomDropdownFormField<String>(
                  isForm: true,
                  title: 'Category',
                  value: selectedMajorCategory2,
                  hintText: 'Select Category',
                  items: serviceCategoryItems,
                  onChanged: (value) {
                    setState(() {
                      selectedMajorCategory2 = value;
                    });
                  },
                ),

                // Language (from site-info API)
                CustomDropdownFormField<String>(
                  isForm: true,
                  title: 'Language',
                  value: selectedLanguage,
                  hintText: 'Select Language',
                  items: languageItems,
                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value;
                    });
                  },
                ),

                CustomDropdownFormField<String>(
                  isForm: true,
                  title: 'Distance',
                  value: selectedDistance,
                  hintText: 'Select Distance',
                  items: [
                    const DropdownMenuItem(
                      value: '5',
                      child: Text('Within 5 km'),
                    ),
                    const DropdownMenuItem(
                      value: '10',
                      child: Text('Within 10 km'),
                    ),
                    const DropdownMenuItem(
                      value: '25',
                      child: Text('Within 25 km'),
                    ),
                    const DropdownMenuItem(
                      value: '50',
                      child: Text('Within 50 km'),
                    ),
                    const DropdownMenuItem(
                      value: '100',
                      child: Text('Within 100 km'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedDistance = value;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Checkboxes
                Text(
                  'Preferences',
                  style: Theme
                      .of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CustomCheckbox(
                        title: 'Near to me',
                        value: nearToMe,
                        onChanged: (value) {
                          setState(() {
                            nearToMe = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _CustomCheckbox(
                        title: 'Barter Agreement',
                        value: barterAgreement,
                        onChanged: (value) {
                          setState(() {
                            barterAgreement = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedPatientType = null;
                      selectedMajorCategory2 = null;
                      selectedLanguage = null;
                      selectedDistance = null;
                      nearToMe = false;
                      barterAgreement = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply filters to provider and close
                    ref
                        .read(searchFiltersProvider.notifier)
                        .state = SearchFilters(
                      categoryId: selectedMajorCategory2,
                      language: selectedLanguage,
                      distanceKm: selectedDistance,
                      barterAgreement: barterAgreement,
                      nearToMe: nearToMe,
                    );
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// Simple chip widget used above
class _FilterChipLabel extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;
  const _FilterChipLabel({required this.label, required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
    );
  }
}

class _PatientTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PatientTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? ColorConstants.primary.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ColorConstants.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? ColorConstants.primary : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? ColorConstants.primary : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomCheckbox extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CustomCheckbox({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: value ? ColorConstants.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? ColorConstants.primary : Colors.grey[300]!,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: ColorConstants.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: value ? ColorConstants.primary : Colors.black87,
                  fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}