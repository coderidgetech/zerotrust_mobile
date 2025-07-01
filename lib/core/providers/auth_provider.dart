import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService.instance;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    
    try {
      final token = await _storageService.getToken();
      if (token != null) {
        final userData = await _apiService.getCurrentUser();
        if (userData != null) {
          _user = userData;
          _isAuthenticated = true;
        } else {
          await _storageService.clearToken();
        }
      }
    } catch (e) {
      _setError('Failed to check authentication status');
      await _storageService.clearToken();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.login(username, password);
      
      if (response['success'] == true) {
        final token = response['token'];
        final userData = User.fromJson(response['user']);
        
        await _storageService.saveToken(token);
        _user = userData;
        _isAuthenticated = true;
        
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Network error. Please check your connection.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }
    
    await _storageService.clearToken();
    _user = null;
    _isAuthenticated = false;
    _setLoading(false);
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _apiService.changePassword(currentPassword, newPassword);
      if (!success) {
        _setError('Failed to change password');
      }
      return success;
    } catch (e) {
      _setError('Failed to change password');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedUser = await _apiService.updateProfile(profileData);
      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('Failed to update profile');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}