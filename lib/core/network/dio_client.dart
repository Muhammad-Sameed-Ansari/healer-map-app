import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:healer_map_flutter/app/router.dart';
import 'package:healer_map_flutter/core/constants/api_constants.dart';
import 'package:healer_map_flutter/core/utils/shared_pref_instance.dart';

class DioClient {
  DioClient._privateConstructor();
  static final DioClient instance = DioClient._privateConstructor();
  final Dio _dio = Dio()
    ..options.baseUrl = APIConstants.apiBaseUrl
    ..options.connectTimeout = Duration(milliseconds: 30000)
    ..options.receiveTimeout = Duration(milliseconds: 30000)
    ..options.headers = {
    'Accept': 'application/json',
    'X-API-Key': 'bB7^7yn(}X&i!9jJ]DEhn4atqiqo_ac@i=hIerEL',
  };

  String? token;

  Dio get dio => _dio;

  void setToken(String token) {
    this.token = token;
    debugPrint('Token has been set to Bearer $token');
    _dio.options.headers['Authorization'] = "Bearer $token";
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      Fluttertoast.showToast(
        msg: "No internet. Please connect to the internet",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }
    return true;
  }

  Future<Response?> request(
    String method,
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    if (!await _checkInternetConnection()) return null;

    try {
      log("Calling $method API: ${APIConstants.apiBaseUrl}$uri");
      if (data != null) {
        log("Body: $data");
      }

      var response = await _dio.request(
        uri,
        data: data, // Send raw data instead of FormData
        queryParameters: queryParameters,
        options: options?.copyWith(method: method) ?? Options(method: method),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      log("Response: $response");

      // Check if the response has 401 status code
      if (response.statusCode == 401) {
        _handleUnauthorized();
      }

      return response;
    } on DioException catch (e) {
      log("Response: ${e.response}");
      if (e.response?.statusCode == 401) {
        _handleUnauthorized();
      }
      return e.response;
    } catch (e) {
      log("Error: $e");
      rethrow;
    }
  }

  bool _isLoggingOut = false;

  void _handleUnauthorized() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    log('Unauthorized - Logging out');

    await SharedPreference.instance.clear();
    setToken("");

    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      context.go(AppRoutes.login);
    }
  }

  Future<Response?> get(String uri, {Map<String, dynamic>? queryParameters}) => request("GET", uri, queryParameters: queryParameters);

  Future<Response?> post(String uri, {dynamic data}) => request("POST", uri, data: data);

  Future<Response?> put(String uri, {dynamic data}) => request("PUT", uri, data: data);

  Future<Response?> delete(String uri, {dynamic data}) => request("DELETE", uri, data: data);
}