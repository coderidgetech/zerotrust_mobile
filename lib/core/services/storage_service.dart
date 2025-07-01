import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Secure storage methods
  Future<void> setSecureValue(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureValue(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecureValue(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  // Regular preferences methods
  Future<void> setValue(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  Future<T?> getValue<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }

  Future<void> deleteValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await clearSecureStorage();
  }

  // Token management
  Future<void> setAuthToken(String token) async {
    await setSecureValue('auth_token', token);
  }

  Future<String?> getAuthToken() async {
    return await getSecureValue('auth_token');
  }

  Future<void> deleteAuthToken() async {
    await deleteSecureValue('auth_token');
  }

  // User credentials
  Future<void> setUserCredentials(String username, String token) async {
    await setSecureValue('username', username);
    await setSecureValue('auth_token', token);
  }

  Future<void> clearUserCredentials() async {
    await deleteSecureValue('username');
    await deleteSecureValue('auth_token');
  }

  // Legacy methods for backward compatibility
  Future<String?> getToken() async {
    return await getAuthToken();
  }

  Future<void> saveToken(String token) async {
    await setAuthToken(token);
  }

  Future<void> clearToken() async {
    await deleteAuthToken();
  }
} 