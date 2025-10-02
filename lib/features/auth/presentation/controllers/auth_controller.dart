import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:healer_map_flutter/features/auth/domain/entities/auth_user.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthUser?>(AuthController.new);
class AuthController extends AsyncNotifier<AuthUser?> {
  AuthUser? _cachedUser;

  @override
  Future<AuthUser?> build() async {
    final repo = ref.read(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    return user;
  }

  Future<void> login(String password, String username) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.login(password: password, username: username);

      // Check if login was successful based on response status
      final isSuccess = response['status'] == true;
      if (!isSuccess) {
        throw response['message'] ?? 'Login failed';
      }

      // Parse user data from response
      final data = response['data'] ?? response;
      final user = AuthUser(
        id: (data['id'] ?? data['data']?['id'] ?? '0').toString(),
        username: (data['username'] ?? data['data']?['username'] ?? '').toString(),
        email: (data['email'] ?? data['data']?['email'] ?? '').toString(),
        firstName: (data['first_name'] ?? data['data']?['first_name'] ?? '').toString(),
        lastName: (data['last_name'] ?? data['data']?['last_name'] ?? '').toString(),
        displayName: (data['display_name'] ?? data['data']?['display_name'] ?? '').toString(),
        token: (data['token'] ?? data['data']?['token']).toString(),
        tokenExpires: data['token_expires'] ?? data['data']?['token_expires'],
      );

      _cachedUser = user;
      return user;
    });
  }

  Future<void> signup(
    String email,
    String password, {
    required String firstName,
    required String lastName,
    required String username,
    String? name,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final response = await repo.signup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        username: username,
        name: name,
      );

      // Check if signup was successful based on response status
      final isSuccess = response['status'] == true;
      if (!isSuccess) {
        throw response['message'] ?? 'Signup failed';
      }

      // Parse user data from response
      final data = response['data'] ?? response;
      final user = AuthUser(
        id: (data['id'] ?? data['data']?['id'] ?? '0').toString(),
        username: (data['username'] ?? data['data']?['username'] ?? username).toString(),
        email: (data['email'] ?? data['data']?['email'] ?? email).toString(),
        firstName: (data['first_name'] ?? data['data']?['first_name'] ?? firstName).toString(),
        lastName: (data['last_name'] ?? data['data']?['last_name'] ?? lastName).toString(),
        displayName: (data['display_name'] ?? data['data']?['display_name'] ?? '$firstName $lastName').toString(),
      );

      _cachedUser = user;
      return user;
    });
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.deleteAccount();
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String displayName,
    File? image,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      displayName: displayName,
      image: image,
    );
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final repo = ref.read(authRepositoryProvider);
    return await repo.forgotPassword(email: email);
  }
}
