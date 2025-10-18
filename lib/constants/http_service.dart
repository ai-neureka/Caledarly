import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkTimeoutException extends ApiException {
  NetworkTimeoutException() : super('Network request timeout');
}

class NoInternetException extends ApiException {
  NoInternetException() : super('No internet connection available');
}

class BaseHttpClient {
  static const String _tokenKey = 'auth_token';
  static const Duration _defaultTimeout = Duration(seconds: 30);

  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final Duration timeout;

  // Singleton pattern
  static BaseHttpClient? _instance;
  static BaseHttpClient get instance {
    _instance ??= BaseHttpClient._internal();
    return _instance!;
  }

  BaseHttpClient._internal({
    this.baseUrl = 'https://apexschedular-production.up.railway.app/api/',
    this.defaultHeaders = const {'Content-Type': 'application/json'},
    this.timeout = _defaultTimeout,
  });

  factory BaseHttpClient({
    String? baseUrl,
    Map<String, String>? defaultHeaders,
    Duration? timeout,
  }) {
    return BaseHttpClient._internal(
      baseUrl:
          baseUrl ?? 'https://apexschedular-production.up.railway.app/api/',
      defaultHeaders:
          defaultHeaders ?? const {'Content-Type': 'application/json'},
      timeout: timeout ?? _defaultTimeout,
    );
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  /// Save authentication token
  Future<void> saveAuthToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      debugPrint('Error saving auth token: $e');
    }
  }

  /// Remove authentication token
  Future<void> clearAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      debugPrint('Error clearing auth token: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Build headers with authentication
  Future<Map<String, String>> _buildHeaders({
    Map<String, String>? headers,
    bool includeAuth = true,
  }) async {
    final Map<String, String> mergedHeaders = {...defaultHeaders};
    SharedPreferences pref = await SharedPreferences.getInstance();
    // Add authentication header if available and requested
    if (includeAuth) {
      final token = pref.getString('token');
      if (token != null && token.isNotEmpty) {
        mergedHeaders['Authorization'] = 'Bearer $token';
      }
    }

    // Add custom headers
    if (headers != null) {
      mergedHeaders.addAll(headers);
    }

    return mergedHeaders;
  }

  /// Core request handler with enhanced error handling
  Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    dynamic body,
    bool includeAuth = true,
    Duration? customTimeout,
  }) async {
    try {
      // Build URI
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())),
      );

      // Build headers with authentication
      final mergedHeaders = await _buildHeaders(
        headers: headers,
        includeAuth: includeAuth,
      );

      // Log request details in debug mode
      if (kDebugMode) {
        debugPrint('🚀 ${method.toUpperCase()} $uri');
        debugPrint('📋 Headers: $mergedHeaders');
        if (body != null) debugPrint('📦 Body: ${jsonEncode(body)}');
      }

      late http.Response response;
      final requestTimeout = customTimeout ?? timeout;

      // Make HTTP request with timeout
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: mergedHeaders)
              .timeout(requestTimeout);
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: mergedHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(requestTimeout);
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: mergedHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(requestTimeout);
          break;
        case 'PATCH':
          response = await http
              .patch(
                uri,
                headers: mergedHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(requestTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: mergedHeaders)
              .timeout(requestTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      return await _handleResponse(response);
    } on SocketException {
      throw NoInternetException();
    } on HttpException catch (e) {
      throw ApiException('HTTP error occurred: ${e.message}');
    } on FormatException catch (e) {
      throw ApiException('Invalid response format: ${e.message}');
    } on TimeoutException {
      throw NetworkTimeoutException();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: ${e.toString()}');
    }
  }

  /// Enhanced response handler
  Future<dynamic> _handleResponse(http.Response response) async {
    final statusCode = response.statusCode;

    // Log response in debug mode
    if (kDebugMode) {
      debugPrint('📨 Response [$statusCode]: ${response.body}');
    }

    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (e) {
      debugPrint('Failed to parse response JSON: $e');
      body = {'raw_response': response.body};
    }

    // Handle different status codes
    switch (statusCode) {
      case >= 200 && < 300:
        return body;

      case 401:
        // Token expired or invalid - clear stored token
        await clearAuthToken();
        throw ApiException(
          'Authentication failed. Please log in again.',
          statusCode: statusCode,
          data: body,
        );

      case 403:
        throw ApiException(
          'Access forbidden. You don\'t have permission to perform this action.',
          statusCode: statusCode,
          data: body,
        );

      case 404:
        throw ApiException(
          'Resource not found.',
          statusCode: statusCode,
          data: body,
        );

      case 409:
        throw ApiException(
          body is Map && body['message'] != null
              ? body['message']
              : 'OTP required',
          statusCode: statusCode,
          data: body,
        );

      case 422:
        throw ApiException(
          'Validation error. Please check your input.',
          statusCode: statusCode,
          data: body,
        );

      case >= 500:
        throw ApiException(
          'Server error. Please try again later.',
          statusCode: statusCode,
          data: body,
        );

      default:
        final message = body is Map && body['message'] != null
            ? body['message']
            : 'Something went wrong';
        throw ApiException(message, statusCode: statusCode, data: body);
    }
  }

  /// Enhanced image fetching with better error handling
  static Future<Uint8List?> getImageUint8List(
    String imageUrl, {
    Duration? timeout,
    Map<String, String>? headers,
  }) async {
    try {
      if (imageUrl.isEmpty) {
        debugPrint('Image URL is empty');
        return null;
      }

      final response = await http
          .get(Uri.parse(imageUrl), headers: headers)
          .timeout(timeout ?? _defaultTimeout);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint(
            '✅ Image fetched successfully: ${response.bodyBytes.length} bytes',
          );
        }
        return response.bodyBytes;
      } else {
        debugPrint('❌ Failed to fetch image: ${response.statusCode}');
        return null;
      }
    } on TimeoutException {
      debugPrint('❌ Image fetch timeout');
      return null;
    } catch (e) {
      debugPrint('❌ Error while fetching image: $e');
      return null;
    }
  }

  /// Public HTTP methods with authentication
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool includeAuth = true,
    Duration? timeout,
  }) => _request(
    'GET',
    endpoint,
    queryParams: queryParams,
    headers: headers,
    includeAuth: includeAuth,
    customTimeout: timeout,
  );

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool includeAuth = true,
    Duration? timeout,
  }) => _request(
    'POST',
    endpoint,
    body: body,
    headers: headers,
    includeAuth: includeAuth,
    customTimeout: timeout,
  );

  Future<dynamic> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool includeAuth = true,
    Duration? timeout,
  }) => _request(
    'PUT',
    endpoint,
    body: body,
    headers: headers,
    includeAuth: includeAuth,
    customTimeout: timeout,
  );

  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    bool includeAuth = true,
    Duration? timeout,
  }) => _request(
    'PATCH',
    endpoint,
    body: body,
    headers: headers,
    includeAuth: includeAuth,
    customTimeout: timeout,
  );

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool includeAuth = true,
    Duration? timeout,
  }) => _request(
    'DELETE',
    endpoint,
    headers: headers,
    includeAuth: includeAuth,
    customTimeout: timeout,
  );
}
