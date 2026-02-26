import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuildingService {
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api/v1/buildings';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/v1/buildings';
    return 'http://127.0.0.1:8000/api/v1/buildings';
  }

  final Dio _dio = Dio();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> createBuilding(
    String name,
    String? address,
    String? city,
  ) async {
    final token = await _getToken();
    final response = await _dio.post(
      '$_baseUrl/',
      data: {'name': name, 'address': address, 'city': city},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> joinBuilding(String inviteCode) async {
    final token = await _getToken();
    final response = await _dio.post(
      '$_baseUrl/join',
      data: {'invite_code': inviteCode},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> getMyBuilding() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/my',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data == null || response.data == '') return null;
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getMembers() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '$_baseUrl/my/members',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      return [];
    }
  }
}
