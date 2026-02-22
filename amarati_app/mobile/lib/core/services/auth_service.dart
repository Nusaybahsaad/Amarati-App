import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  // Change this to your backend IP/URL
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1/auth';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1/auth';
    return 'http://127.0.0.1:8000/api/v1/auth';
  }
  
  final Dio _dio = Dio();

  Future<UserModel> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String role = 'tenant',
  }) async {
    final response = await _dio.post(
      '$_baseUrl/register',
      data: {
        'name': name,
        'phone': phone,
        'password': password,
        'email': email,
        'role': role,
      },
    );

    final token = response.data['access_token'] as String;
    final user = UserModel.fromJson(response.data, token);
    await _saveToken(token);
    return user;
  }

  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/login',
      data: {'phone': phone, 'password': password},
    );

    final token = response.data['access_token'] as String;
    final user = UserModel.fromJson(response.data, token);
    await _saveToken(token);
    return user;
  }

  Future<UserModel> updateRole(String role, String token) async {
    final response = await _dio.put(
      '$_baseUrl/me/role',
      data: {'role': role},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return UserModel.fromJson(response.data, token);
  }

  Future<UserModel?> getMe(String token) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return UserModel.fromJson(response.data, token);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
