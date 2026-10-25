import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/social_account_model.dart';

class SocialProvider extends ChangeNotifier {
  List<SocialAccountModel> _accounts = [];
  bool _isLoading = false;

  List<SocialAccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;

  Future<void> fetchAccounts(String brandId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(
        ApiEndpoints.socialAccounts,
        queryParameters: {'brand_id': brandId},
      );

      if (response.statusCode == 200) {
        _accounts = (response.data as List<dynamic>)
            .map((a) => SocialAccountModel.fromJson(a))
            .toList();
      }
    } catch (e) {
      debugPrint('[Fetch Social Accounts Error] $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> connectAccount({
    required String brandId,
    required String platform,
    required String accountHandle,
    String? accountName,
    required String accessToken,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.connectSocial,
        data: {
          'brand_id': brandId,
          'platform': platform,
          'account_handle': accountHandle,
          'account_name': accountName,
          'access_token': accessToken,
        },
      );

      if (response.statusCode == 201) {
        await fetchAccounts(brandId);
        return true;
      }
    } catch (e) {
      debugPrint('[Connect Social Error] $e');
    }
    return false;
  }

  Future<bool> disconnectAccount(String accountId, String brandId) async {
    try {
      final response = await ApiClient.dio.delete(ApiEndpoints.disconnectSocial(accountId));
      if (response.statusCode == 200) {
        _accounts.removeWhere((a) => a.id == accountId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[Disconnect Error] $e');
    }
    return false;
  }
}
