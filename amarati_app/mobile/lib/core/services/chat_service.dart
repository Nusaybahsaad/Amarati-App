import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1/chat';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1/chat';
    return 'http://127.0.0.1:8000/api/v1/chat';
  }

  final Dio _dio = Dio();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> sendMessage(
    String message, {
    String messageType = 'text',
  }) async {
    final token = await _getToken();
    final response = await _dio.post(
      _baseUrl,
      data: {'message': message, 'message_type': messageType},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMessages() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        _baseUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }
}
