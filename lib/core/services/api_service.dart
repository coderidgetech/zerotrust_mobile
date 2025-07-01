import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/vpn_models.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://your-zerovault-api.com'; // Replace with your API URL
  final StorageService _storageService = StorageService.instance;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // Authentication APIs
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: await _getHeaders(),
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    return await _handleResponse(response);
  }

  Future<void> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/logout'),
      headers: await _getHeaders(),
    );

    await _handleResponse(response);
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: await _getHeaders(),
      );

      final data = await _handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/auth/change-password'),
        headers: await _getHeaders(),
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      await _handleResponse(response);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<User?> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/auth/profile'),
        headers: await _getHeaders(),
        body: json.encode(profileData),
      );

      final data = await _handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // VPN APIs
  Future<List<VPNGateway>> getVPNGateways() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/vpn/gateways'),
      headers: await _getHeaders(),
    );

    final data = await _handleResponse(response);
    return (data as List).map((gateway) => VPNGateway.fromJson(gateway)).toList();
  }

  Future<VPNConfiguration?> getVPNConfiguration(int gatewayId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/vpn/config/wireguard?gatewayId=$gatewayId'),
        headers: await _getHeaders(),
      );

      final data = await _handleResponse(response);
      return VPNConfiguration.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> notifyVPNConnection(int gatewayId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/vpn/connect'),
      headers: await _getHeaders(),
      body: json.encode({'gatewayId': gatewayId}),
    );

    await _handleResponse(response);
  }

  Future<void> notifyVPNDisconnection(int gatewayId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/vpn/disconnect'),
      headers: await _getHeaders(),
      body: json.encode({'gatewayId': gatewayId}),
    );

    await _handleResponse(response);
  }

  Future<String?> generateVPNQRCode(String platform) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/vpn/qr/$platform'),
        headers: await _getHeaders(),
      );

      final data = await _handleResponse(response);
      return data['qrCode'];
    } catch (e) {
      return null;
    }
  }

  // Dashboard APIs
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard/metrics'),
      headers: await _getHeaders(),
    );

    return await _handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard/recent-activity'),
      headers: await _getHeaders(),
    );

    final data = await _handleResponse(response);
    if (data is List) {
      return (data as List).cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> getSecurityPosture() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/dashboard/security-posture'),
      headers: await _getHeaders(),
    );

    return await _handleResponse(response);
  }

  // Device APIs
  Future<List<Map<String, dynamic>>> getDevices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/devices'),
      headers: await _getHeaders(),
    );

    final data = await _handleResponse(response);
    if (data is List) {
      return (data as List).cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> addDevice(Map<String, dynamic> deviceData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/devices'),
      headers: await _getHeaders(),
      body: json.encode(deviceData),
    );

    return await _handleResponse(response);
  }

  Future<void> removeDevice(int deviceId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/devices/$deviceId'),
      headers: await _getHeaders(),
    );

    await _handleResponse(response);
  }

  // AI Security Insights APIs
  Future<List<Map<String, dynamic>>> getSecurityInsights() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ai-insights/my'),
      headers: await _getHeaders(),
    );

    final data = await _handleResponse(response);
    if (data is List) {
      return (data as List).cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  Future<void> generateSecurityInsights() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ai-insights/generate'),
      headers: await _getHeaders(),
    );

    await _handleResponse(response);
  }

  Future<void> markInsightAsRead(int insightId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/ai-insights/$insightId/read'),
      headers: await _getHeaders(),
    );

    await _handleResponse(response);
  }

  Future<void> dismissInsight(int insightId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/ai-insights/$insightId/dismiss'),
      headers: await _getHeaders(),
    );

    await _handleResponse(response);
  }
}