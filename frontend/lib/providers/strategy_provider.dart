import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/strategy_model.dart';

class StrategyProvider extends ChangeNotifier {
  StrategyModel? _strategy;
  bool _isLoading = false;
  String? _errorMessage;

  StrategyModel? get strategy => _strategy;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStrategy(String brandId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(ApiEndpoints.getStrategy(brandId));
      if (response.statusCode == 200) {
        _strategy = StrategyModel.fromJson(response.data);
      }
    } catch (e) {
      _strategy = null; // No strategy yet
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> generateStrategy(String brandId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(ApiEndpoints.generateStrategy(brandId));
      if (response.statusCode == 200) {
        _strategy = StrategyModel.fromJson(response.data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Strategy blueprint generation failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> approveStrategy(String brandId) async {
    try {
      final response = await ApiClient.dio.put(
        ApiEndpoints.updateStrategy(brandId),
        data: {'is_approved': true},
      );
      if (response.statusCode == 200) {
        _strategy = StrategyModel.fromJson(response.data);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[Approve Strategy Error] $e');
    }
    return false;
  }
}
