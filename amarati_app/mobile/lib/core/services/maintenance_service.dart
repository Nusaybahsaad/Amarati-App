import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaintenanceService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1/maintenance';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1/maintenance';
    return 'http://127.0.0.1:8000/api/v1/maintenance';
  }

  final Dio _dio = Dio();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Options _authHeaders(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  /// Create a new maintenance request (tenant side)
  Future<Map<String, dynamic>> createRequest({
    required String description,
    required String category,
    String unitNumber = '',
    String contactName = '',
    String contactPhone = '',
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('غير مسجل الدخول');

    final response = await _dio.post(
      '$_baseUrl/',
      data: {
        'description': description,
        'category': category,
        'unit_number': unitNumber,
        'contact_name': contactName,
        'contact_phone': contactPhone,
      },
      options: _authHeaders(token),
    );
    return response.data;
  }

  /// Get all maintenance requests (provider side), optionally filtered by status
  Future<List<Map<String, dynamic>>> getRequests({String? status}) async {
    final token = await _getToken();
    if (token == null) throw Exception('غير مسجل الدخول');

    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;

    final response = await _dio.get(
      '$_baseUrl/',
      queryParameters: queryParams,
      options: _authHeaders(token),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Get current user's requests (tenant side)
  Future<List<Map<String, dynamic>>> getMyRequests() async {
    final token = await _getToken();
    if (token == null) throw Exception('غير مسجل الدخول');

    final response = await _dio.get(
      '$_baseUrl/my',
      options: _authHeaders(token),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Update request status (provider: accept/reject/complete)
  Future<Map<String, dynamic>> updateStatus({
    required String requestId,
    required String status,
    String? notes,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('غير مسجل الدخول');

    final response = await _dio.put(
      '$_baseUrl/$requestId/status',
      data: {'status': status, 'notes': ?notes},
      options: _authHeaders(token),
    );
    return response.data;
  }
}
