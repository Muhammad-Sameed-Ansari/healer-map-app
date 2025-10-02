import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/features/home/presentation/pages/home_page.dart';
import 'package:healer_map_flutter/core/localization/app_localization.dart';

import '../../../blog/presentation/pages/blog_page.dart';
import '../../../favourite/presentation/pages/favourite_page.dart';
import '../../../map/presentation/pages/map_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = <Widget>[
    const HomePage(),
    const MapPage(),
    const FavouritePage(),
    const BlogPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.white,
        backgroundColor: Colors.white,
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Image.asset('assets/icons/home_inactive.png', width: 24, height: 24),
            selectedIcon: Image.asset('assets/icons/home_active.png', width: 24, height: 24),
            label: localizations.home,
          ),
          NavigationDestination(
            icon: Image.asset('assets/icons/map_inactive.png', width: 24, height: 24),
            selectedIcon: Image.asset('assets/icons/map_active.png', width: 24, height: 24),
            label: localizations.map,
          ),
          NavigationDestination(
            icon: Image.asset('assets/icons/favourite_inactive.png', width: 24, height: 24),
            selectedIcon: Image.asset('assets/icons/favourite_active.png', width: 24, height: 24),
            label: localizations.favorites,
          ),
          NavigationDestination(
            icon: Image.asset('assets/icons/blog_inactive.png', width: 24, height: 24),
            selectedIcon: Image.asset('assets/icons/blog_active.png', width: 24, height: 24),
            label: localizations.blog,
          ),
          NavigationDestination(
            icon: Image.asset('assets/icons/profile_inactive.png', width: 24, height: 24),
            selectedIcon: Image.asset('assets/icons/profile_active.png', width: 24, height: 24),
            label: localizations.profile,
          ),
        ],
      ),
    );
  }
}

class _SimplePlaceholder extends StatelessWidget {
  final String title;
  const _SimplePlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title screen coming soon'),
      ),
    );
  }
}
