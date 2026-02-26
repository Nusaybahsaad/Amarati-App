import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1/notifications';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1/notifications';
    return 'http://127.0.0.1:8000/api/v1/notifications';
  }

  final Dio _dio = Dio();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        _baseUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await _getToken();
      await _dio.put(
        '$_baseUrl/$notificationId/read',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/preferences',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return {'push': true, 'email': true, 'in_app': true};
    }
  }

  Future<Map<String, dynamic>> updatePreferences(
    Map<String, bool> prefs,
  ) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        '$_baseUrl/preferences',
        data: prefs,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to update preferences');
    }
  }
}
