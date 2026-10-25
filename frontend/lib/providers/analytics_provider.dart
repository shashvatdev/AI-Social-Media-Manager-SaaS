import 'package:flutter/foundation.dart';
import '../models/analytics_model.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsModel? _analytics;
  bool _isLoading = false;
  String? _errorMessage;

  AnalyticsModel? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAnalytics(String brandId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(ApiEndpoints.brandAnalytics(brandId));
      if (response.statusCode == 200) {
        _analytics = AnalyticsModel.fromJson(response.data);
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[Analytics Fetch Error] $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
