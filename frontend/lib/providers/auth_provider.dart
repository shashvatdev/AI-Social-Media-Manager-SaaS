import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  Future<bool> checkAuth() async {
    final token = await SecureStorageService.getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final response = await ApiClient.dio.get(ApiEndpoints.me);
      if (response.statusCode == 200) {
        _currentUser = UserModel.fromJson(response.data);
        notifyListeners();
        return true;
      }
    } catch (e) {
      await SecureStorageService.deleteToken();
    }
    return false;
  }

  Future<bool> signup({
    required String email,
    required String fullName,
    required String password,
    String? companyName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.signup,
        data: {
          'email': email,
          'full_name': fullName,
          'password': password,
          'company_name': companyName,
        },
      );

      if (response.statusCode == 201) {
        final token = response.data['access_token'];
        await SecureStorageService.saveToken(token);
        _currentUser = UserModel.fromJson(response.data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['detail'] ?? 'Signup failed. Please try again.';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await SecureStorageService.saveToken(token);
        _currentUser = UserModel.fromJson(response.data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['detail'] ?? 'Invalid credentials.';
    } catch (e) {
      _errorMessage = 'Login failed. Please check your network.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await SecureStorageService.deleteToken();
    _currentUser = null;
    notifyListeners();
  }
}
