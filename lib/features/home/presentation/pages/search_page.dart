import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/common/widgets/app_scaffold.dart';
import 'package:healer_map_flutter/common/widgets/custom_dropdown_form_field.dart';
import 'package:healer_map_flutter/core/constants/app_constants.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';
import 'package:healer_map_flutter/features/home/presentation/pages/home_page.dart';

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
                    height: 20,
                    width: 20,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
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

class SearchResultsList extends ConsumerWidget {
  final String searchQuery;
  final bool hasActiveFilters;

  const SearchResultsList({
    super.key,
    required this.searchQuery,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock search results - in real app, this would come from API/state management
    final mockResults = [
      if (searchQuery.isEmpty ||
          searchQuery.toLowerCase().contains('dr') ||
          searchQuery.toLowerCase().contains('john'))
        const HealerCard(
          name: 'Dr. John',
          specialty: 'Dhaka medical (Neur specialist)',
          location: 'Magnolia, United States',
          language: 'English',
        ),
      if (searchQuery.isEmpty ||
          searchQuery.toLowerCase().contains('dr') ||
          searchQuery.toLowerCase().contains('karuk'))
        const HealerCard(
          name: 'Dr. Karuk',
          specialty: 'Dhaka medical (Neur specialist)',
          location: 'Magnolia, United States',
          language: 'English',
        ),
      if (searchQuery.isEmpty ||
          searchQuery.toLowerCase().contains('dr') ||
          searchQuery.toLowerCase().contains('erann'))
        const HealerCard(
          name: 'Dr. Erann',
          specialty: 'Dhaka medical (Neur specialist)',
          location: 'Magnolia, United States',
          language: 'English',
        ),
    ];

    if (mockResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No healers found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilters
                  ? 'Try adjusting your filters or search terms'
                  : 'Try searching for a healer name or specialty',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mockResults.length,
      itemBuilder: (context, index) {
        return mockResults[index];
      },
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
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
  Widget build(BuildContext context) {
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),

          // Filter Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Category: Animal or Human - Visual Selection
                Text(
                  'Patient Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
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
                          });
                        },
                      ),
                    ),
                  ],
                ),
                CustomDropdownFormField<String>(
                  isForm: true,
                  title: 'Service Category',
                  value: selectedMajorCategory2,
                  hintText: 'Select Service Category',
                  items: [
                    const DropdownMenuItem(
                      value: 'medical',
                      child: Text('Medical Services'),
                    ),
                    const DropdownMenuItem(
                      value: 'therapy',
                      child: Text('Therapy Services'),
                    ),
                    const DropdownMenuItem(
                      value: 'wellness',
                      child: Text('Wellness Services'),
                    ),
                    const DropdownMenuItem(
                      value: 'consultation',
                      child: Text('Consultation'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedMajorCategory2 = value;
                    });
                  },
                ),

                CustomDropdownFormField<String>(
                  isForm: true,
                  title: 'Language',
                  value: selectedLanguage,
                  hintText: 'Select Language',
                  items: [
                    const DropdownMenuItem(
                      value: 'english',
                      child: Text('English'),
                    ),
                    const DropdownMenuItem(
                      value: 'spanish',
                      child: Text('Spanish'),
                    ),
                    const DropdownMenuItem(
                      value: 'french',
                      child: Text('French'),
                    ),
                    const DropdownMenuItem(
                      value: 'german',
                      child: Text('German'),
                    ),
                    const DropdownMenuItem(
                      value: 'arabic',
                      child: Text('Arabic'),
                    ),
                    const DropdownMenuItem(
                      value: 'hindi',
                      child: Text('Hindi'),
                    ),
                  ],
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
          const SizedBox(height: 20),
        ],
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
