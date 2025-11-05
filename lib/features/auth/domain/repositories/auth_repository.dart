import 'dart:io';

import 'package:healer_map_flutter/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login({required String password, required String username});
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    String? name
  });
  Future<void> logout();
  Future<AuthUser?> getCurrentUser();
  Future<Map<String, dynamic>> forgotPassword({required String email});
  Future<Map<String, dynamic>> deleteAccount();
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String displayName,
    File? image,
  });
}
