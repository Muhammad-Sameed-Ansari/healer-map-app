import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healer_map_flutter/core/constants/api_constants.dart';
import 'package:healer_map_flutter/core/network/dio_client.dart';
import 'package:healer_map_flutter/core/utils/shared_pref_instance.dart';
import 'package:healer_map_flutter/features/auth/domain/entities/auth_user.dart';
import 'package:healer_map_flutter/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient = DioClient.instance;
  AuthUser? _cachedUser;

  @override
  Future<AuthUser?> getCurrentUser() async {
    // Check if we have a cached user and token is still valid
    if (_cachedUser != null && _cachedUser!.isTokenValid) {
      return _cachedUser;
    }

    // Try to load user data from shared preferences
    try {
      final isLoggedIn = await SharedPreference.instance.getString('is_logged_in');
      if (isLoggedIn != 'true') {
        _cachedUser = null;
        return null;
      }

      final userId = await SharedPreference.instance.getString('user_id');
      final username = await SharedPreference.instance.getString('username');
      final email = await SharedPreference.instance.getString('email');
      final firstName = await SharedPreference.instance.getString('first_name');
      final lastName = await SharedPreference.instance.getString('last_name');
      final displayName = await SharedPreference.instance.getString('display_name');
      final token = await SharedPreference.instance.getString('auth_token');
      final tokenExpiresStr = await SharedPreference.instance.getString('token_expires');
      final avatarUrl = await SharedPreference.instance.getString('avatar_url');

      if (userId == null || username == null || email == null || firstName == null || lastName == null) {
        _cachedUser = null;
        return null;
      }

      final tokenExpires = tokenExpiresStr != null ? int.tryParse(tokenExpiresStr) : null;

      _cachedUser = AuthUser(
        id: userId,
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        displayName: displayName ?? '$firstName $lastName',
        token: token,
        tokenExpires: tokenExpires,
        avatarUrl: avatarUrl,
      );

      // Check if token is still valid
      if (!_cachedUser!.isTokenValid) {
        _cachedUser = null;
        return null;
      }

      return _cachedUser;
    } catch (e) {
      _cachedUser = null;
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> login({required String password, required String username}) async {
    try {
      final response = await _dioClient.post(
        APIEndpoints.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response == null || response.data == null) {
        return {'status': false, 'message': 'Login failed: No response data'};
      }

      // Return the response data for the UI to handle
      return response.data;
    } on DioException catch (e) {
      // Return the error response data instead of throwing
      final errorData = e.response?.data;
      if (errorData != null) {
        return errorData;
      }
      return {'status': false, 'message': e.message ?? 'Login failed'};
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Call logout API first - include token if available
      final token = await SharedPreference.instance.getString('auth_token');
      final options = token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null;

      await _dioClient.request(
        'POST',
        APIEndpoints.logout,
        options: options,
      );
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API call failed: $e');
    } finally {
      // Clear cached user and shared preferences
      _cachedUser = null;
      await SharedPreference.instance.remove('is_logged_in');
      await SharedPreference.instance.remove('user_id');
      await SharedPreference.instance.remove('username');
      await SharedPreference.instance.remove('email');
      await SharedPreference.instance.remove('first_name');
      await SharedPreference.instance.remove('last_name');
      await SharedPreference.instance.remove('display_name');
      await SharedPreference.instance.remove('auth_token');
      await SharedPreference.instance.remove('token_expires');
      await SharedPreference.instance.remove('avatar_url');
    }
  }

  @override
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    String? name
  }) async {
    try {
      final response = await _dioClient.post(
        APIEndpoints.signup,
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'username': username,
          if (name != null) 'name': name,
        },
      );

      if (response == null || response.data == null) {
        return {'status': false, 'message': 'Signup failed: No response data'};
      }

      // Return the response data for the UI to handle
      return response.data;
    } on DioException catch (e) {
      // Return the error response data instead of throwing
      final errorData = e.response?.data;
      if (errorData != null) {
        return errorData;
      }
      return {'status': false, 'message': e.message ?? 'Signup failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final token = await SharedPreference.instance.getString('auth_token');
      final options = token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null;

      final response = await _dioClient.request(
        'DELETE',
        APIEndpoints.deleteAccount,
        options: options,
        data: {},
      );

      // Return the response data for the UI to handle
      return response?.data ?? {'status': true, 'message': 'Account deleted successfully'};
    } on DioException catch (e) {
      // Return the error response data instead of throwing
      final errorData = e.response?.data;
      if (errorData != null) {
        return errorData;
      }
      return {'status': false, 'message': e.message ?? 'Delete account failed'};
    }
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String displayName,
    File? image,
  }) async {
    try {
      final token = await SharedPreference.instance.getString('auth_token');
      final options = token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null;

      final Map<String, dynamic> body = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'display_name': displayName,
      };

      // Only include image if it's provided and exists (send as base64 string)
      if (image != null && image.existsSync()) {
        final bytes = await image.readAsBytes();
        final b64 = base64Encode(bytes);
        body['image'] = b64;
      }

      final response = await _dioClient.post(
        APIEndpoints.profile,
        data: body,
      );

      // Persist avatar URL if provided in the response
      final resData = response?.data;
      if (resData is Map<String, dynamic>) {
        final data = resData['data'] ?? resData;
        // Some APIs nest under data.user
        final userMap = (data is Map<String, dynamic>)
            ? (data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data)
            : null;

        if (userMap is Map<String, dynamic>) {
          // Extract fields with fallbacks
          final id = (userMap['id'] ?? '').toString();
          final username = (userMap['username'] ?? '').toString();
          final email = (userMap['email'] ?? '').toString();
          final firstName = (userMap['first_name'] ?? '').toString();
          final lastName = (userMap['last_name'] ?? '').toString();
          final displayName = (userMap['display_name'] ?? '').toString();
          final rawAvatar = (userMap['image']);

          // Persist to SharedPreferences (like login)
          if (id.isNotEmpty) SharedPreference.instance.setString('user_id', id);
          if (username.isNotEmpty) SharedPreference.instance.setString('username', username);
          if (email.isNotEmpty) SharedPreference.instance.setString('email', email);
          if (firstName.isNotEmpty) SharedPreference.instance.setString('first_name', firstName);
          print("${firstName} after ${SharedPreference.instance.getString('first_name')}");
          if (lastName.isNotEmpty) SharedPreference.instance.setString('last_name', lastName);
          if (displayName.isNotEmpty) SharedPreference.instance.setString('display_name', displayName);
          if (rawAvatar != null && rawAvatar.toString().isNotEmpty) {
            SharedPreference.instance.setString('avatar_url', rawAvatar.toString());
            print("${SharedPreference.instance.getString('avatar_url')}");
          }

          // Refresh cached user if token remains same
          final existingToken = await SharedPreference.instance.getString('auth_token');
          final tokenExpiresStr = await SharedPreference.instance.getString('token_expires');
          final tokenExpires = tokenExpiresStr != null ? int.tryParse(tokenExpiresStr) : null;
          _cachedUser = AuthUser(
            id: id.isNotEmpty ? id : (_cachedUser?.id ?? ''),
            username: username.isNotEmpty ? username : (_cachedUser?.username ?? ''),
            email: email.isNotEmpty ? email : (_cachedUser?.email ?? ''),
            firstName: firstName.isNotEmpty ? firstName : (_cachedUser?.firstName ?? ''),
            lastName: lastName.isNotEmpty ? lastName : (_cachedUser?.lastName ?? ''),
            displayName: displayName.isNotEmpty ? displayName : (_cachedUser?.displayName ?? ''),
            token: existingToken,
            tokenExpires: tokenExpires,
            avatarUrl: (rawAvatar != null && rawAvatar.toString().isNotEmpty)
                ? rawAvatar.toString()
                : _cachedUser?.avatarUrl,
          );
        } else {
          // Fallback: just persist avatar if provided at top-level data
          final dynamic rawAvatar = (data['avatar_url'] ?? data['avatar'] ?? data['image_url'] ?? data['profile_image'] ?? data['image']);
          if (rawAvatar != null && rawAvatar.toString().isNotEmpty) {
            SharedPreference.instance.setString('avatar_url', rawAvatar.toString());
          }
        }
      }

      // Return the response data for the UI to handle
      return resData ?? {'status': true, 'message': 'Profile updated successfully'};
    } on DioException catch (e) {
      // Handle DioException with response data (API error responses)
      if (e.response != null && e.response?.data != null) {
        final responseData = e.response?.data;
        // Ensure we return a map with status and message
        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else if (responseData is String) {
          return {'status': false, 'message': responseData};
        }
      }

      // Handle DioException without response data (network errors)
      return {'status': false, 'message': e.message ?? 'Profile update failed'};
    } catch (e) {
      // Handle any other exceptions
      return {'status': false, 'message': 'Profile update failed: ${e.toString()}'};
    }
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dioClient.post(
        APIEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      // Return the response data for the UI to handle
      return response?.data ?? {'status': true, 'message': 'Password changed successfully'};
    } on DioException catch (e) {
      // Handle DioException with response data (API error responses)
      if (e.response != null && e.response?.data != null) {
        final responseData = e.response?.data;
        // Ensure we return a map with status and message
        if (responseData is Map<String, dynamic>) {
          return responseData;
        } else if (responseData is String) {
          return {'status': false, 'message': responseData};
        }
      }

      // Handle DioException without response data (network errors)
      return {'status': false, 'message': e.message ?? 'Password change failed'};
    } catch (e) {
      // Handle any other exceptions
      return {'status': false, 'message': 'Password change failed: ${e.toString()}'};
    }
  }

  @override
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _dioClient.post(
        APIEndpoints.forgotPassword,
        data: {
          'email': email,
        },
      );

      // Return the response data for the UI to handle
      return response?.data ?? {'status': true, 'message': 'Reset link sent successfully'};
    } on DioException catch (e) {
      // Return the error response data instead of throwing
      final errorData = e.response?.data;
      if (errorData != null) {
        return errorData;
      }
      return {'status': false, 'message': e.message ?? 'Request failed'};
    }
  }
}
