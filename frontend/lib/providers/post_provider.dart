import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/post_model.dart';

class PostProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _errorMessage;
  String _currentFilter = 'PENDING_APPROVAL';

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;

  void setFilter(String filter, String brandId) {
    _currentFilter = filter;
    fetchPosts(brandId, status: filter);
  }

  Future<void> fetchPosts(String brandId, {String? status, String? platform}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{'brand_id': brandId};
      if (status != null && status != 'ALL') {
        queryParams['status'] = status;
      }
      if (platform != null) {
        queryParams['platform'] = platform;
      }

      final response = await ApiClient.dio.get(
        ApiEndpoints.posts,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        _posts = (response.data as List<dynamic>)
            .map((p) => PostModel.fromJson(p))
            .toList();
      }
    } catch (e) {
      _errorMessage = 'Failed to load posts.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> generatePosts({
    required String brandId,
    required String platform,
    String? topic,
    int count = 1,
  }) async {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.generatePosts,
        data: {
          'brand_id': brandId,
          'platform': platform,
          'topic': topic,
          'count': count,
          'generate_creatives': true,
        },
      );

      if (response.statusCode == 201) {
        final newPosts = (response.data as List<dynamic>)
            .map((p) => PostModel.fromJson(p))
            .toList();
        _posts.insertAll(0, newPosts);
        _isGenerating = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Post generation failed. Please try again.';
    }

    _isGenerating = false;
    notifyListeners();
    return false;
  }

  Future<bool> approvePost(String postId, {DateTime? scheduledFor}) async {
    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.approvePost(postId),
        data: scheduledFor != null ? {'scheduled_for': scheduledFor.toIso8601String()} : null,
      );
      if (response.statusCode == 200) {
        final updated = PostModel.fromJson(response.data);
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = updated;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('[Approve Error] $e');
    }
    return false;
  }

  Future<bool> rejectPost(String postId, {String? reason}) async {
    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.rejectPost(postId),
        data: reason != null ? {'reason': reason} : null,
      );
      if (response.statusCode == 200) {
        final updated = PostModel.fromJson(response.data);
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = updated;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('[Reject Error] $e');
    }
    return false;
  }

  Future<bool> requestChanges(String postId, String feedback) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.requestChanges(postId),
        data: {'feedback': feedback},
      );

      if (response.statusCode == 200) {
        final updated = PostModel.fromJson(response.data);
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = updated;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'AI rewrite request failed.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> editPost(String postId, {required String content, List<String>? hashtags}) async {
    try {
      final response = await ApiClient.dio.put(
        ApiEndpoints.editPost(postId),
        data: {
          'content': content,
          if (hashtags != null) 'hashtags': hashtags,
        },
      );
      if (response.statusCode == 200) {
        final updated = PostModel.fromJson(response.data);
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = updated;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('[Edit Post Error] $e');
    }
    return false;
  }

  Future<bool> publishNow(String postId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.dio.post(ApiEndpoints.publishNow(postId));
      if (response.statusCode == 200) {
        final updated = PostModel.fromJson(response.data);
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = updated;
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Publish failed. Ensure social handle is connected.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}
