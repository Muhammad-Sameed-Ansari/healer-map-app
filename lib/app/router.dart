import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:healer_map_flutter/features/auth/presentation/pages/signup_page.dart';
import 'package:healer_map_flutter/features/auth/presentation/pages/splash_page.dart';
import 'package:healer_map_flutter/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:healer_map_flutter/features/favourite/presentation/pages/favourite_page.dart';
import 'package:healer_map_flutter/features/home/presentation/pages/search_page.dart';
import 'package:healer_map_flutter/features/map/presentation/pages/map_page.dart';
import 'package:healer_map_flutter/features/profile/presentation/pages/edit_profile_page.dart';

import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/profile/presentation/pages/change_language_page.dart';
import 'package:healer_map_flutter/features/blog/presentation/pages/blog_detail_page.dart';
import 'package:healer_map_flutter/features/blog/data/models/blog_post.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// Centralized route paths
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const changeLanguage = '/change-language';
  static const favorite = '/favorite';
  static const search = '/search';
  static const editProfile = '/edit-profile';
  static const blogDetail = '/blog-detail';
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    // refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.changeLanguage,
        builder: (context, state) => const ChangeLanguagePage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.favorite,
        builder: (context, state) => const FavouritePage(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: AppRoutes.blogDetail,
        builder: (context, state) {
          final post = state.extra as BlogPost;
          return BlogDetailPage(post: post);
        },
      ),
    ],
  );
});
