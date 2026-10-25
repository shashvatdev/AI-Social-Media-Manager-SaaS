import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/secure_storage.dart';
import '../models/brand_model.dart';
import '../models/knowledge_model.dart';

class BrandProvider extends ChangeNotifier {
  List<BrandModel> _brands = [];
  BrandModel? _activeBrand;
  List<KnowledgeItemModel> _knowledgeItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BrandModel> get brands => _brands;
  BrandModel? get activeBrand => _activeBrand;
  List<KnowledgeItemModel> get knowledgeItems => _knowledgeItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBrands() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.dio.get(ApiEndpoints.brands);
      if (response.statusCode == 200) {
        _brands = (response.data as List<dynamic>)
            .map((b) => BrandModel.fromJson(b))
            .toList();

        // Restore or pick active brand
        final savedBrandId = await SecureStorageService.getActiveBrandId();
        if (savedBrandId != null && _brands.any((b) => b.id == savedBrandId)) {
          _activeBrand = _brands.firstWhere((b) => b.id == savedBrandId);
        } else if (_brands.isNotEmpty) {
          _activeBrand = _brands.first;
          await SecureStorageService.saveActiveBrandId(_activeBrand!.id);
        }

        if (_activeBrand != null) {
          await fetchKnowledge(_activeBrand!.id);
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load brands.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void setActiveBrand(BrandModel brand) async {
    _activeBrand = brand;
    await SecureStorageService.saveActiveBrandId(brand.id);
    await fetchKnowledge(brand.id);
    notifyListeners();
  }

  Future<BrandModel?> createBrand({
    required String name,
    String? websiteUrl,
    String? industry,
    String? toneOfVoice,
    String? targetAudience,
    List<String>? contentPillars,
    List<String>? bannedWords,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.brands,
        data: {
          'name': name,
          'website_url': websiteUrl,
          'industry': industry,
          'tone_of_voice': toneOfVoice,
          'target_audience': targetAudience,
          'content_pillars': contentPillars ?? [],
          'banned_words': bannedWords ?? [],
        },
      );

      if (response.statusCode == 201) {
        final newBrand = BrandModel.fromJson(response.data);
        _brands.insert(0, newBrand);
        _activeBrand = newBrand;
        await SecureStorageService.saveActiveBrandId(newBrand.id);
        _isLoading = false;
        notifyListeners();
        return newBrand;
      }
    } catch (e) {
      _errorMessage = 'Failed to create brand profile.';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> scrapeWebsite(String brandId, {String? url}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.scrapeUrl(brandId),
        data: url != null ? {'url': url} : null,
      );

      if (response.statusCode == 200) {
        await fetchKnowledge(brandId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Website scraping failed.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> uploadDocument(String brandId, String filePath, String fileName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await ApiClient.dio.post(
        ApiEndpoints.uploadDocs(brandId),
        data: formData,
      );

      if (response.statusCode == 201) {
        await fetchKnowledge(brandId);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Document upload failed.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> fetchKnowledge(String brandId) async {
    try {
      final response = await ApiClient.dio.get(ApiEndpoints.brandKnowledge(brandId));
      if (response.statusCode == 200) {
        _knowledgeItems = (response.data as List<dynamic>)
            .map((k) => KnowledgeItemModel.fromJson(k))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Knowledge Fetch Error] $e');
    }
  }
}
