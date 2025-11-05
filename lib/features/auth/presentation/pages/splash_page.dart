import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/core/network/dio_client.dart';
import 'package:healer_map_flutter/core/utils/shared_pref_instance.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Check authentication status and navigate accordingly after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Keep splash visible for 3 seconds
      await Future.delayed(const Duration(seconds: 3));

      // Check if user has valid token
      final isLoggedIn = await SharedPreference.instance.getString('is_logged_in');
      final token = await SharedPreference.instance.getString('auth_token');
      final tokenExpiresStr = await SharedPreference.instance.getString('token_expires');

      bool hasValidToken = false;
      if (isLoggedIn == 'true' && token != null && token.isNotEmpty && tokenExpiresStr != null) {
        final tokenExpires = int.tryParse(tokenExpiresStr);
        if (tokenExpires != null) {
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          hasValidToken = tokenExpires > now;
        }
      }

      if (!mounted) return;

      if (hasValidToken) {
        DioClient.instance.setToken("$token");
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/Welcome.png"),fit: BoxFit.cover)),
            ),
          ),
        ],
      ),
    );
  }
}
