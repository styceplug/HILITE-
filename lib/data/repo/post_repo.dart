import 'package:get/get_connect/http/src/response/response.dart';

import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class PostRepo {
  final ApiClient apiClient;

  PostRepo({required this.apiClient});


  Future<Response> likePost(String postId) async {
    return await apiClient.put(
      AppConstants.LIKE_POST(postId),
      {},
    );
  }


  Future<Response> unlikePost(String postId) async {
    return await apiClient.put(
      AppConstants.UNLIKE_POST(postId),
      {},
    );
  }

  Future<Response> getRecommendedPosts({
    required String contentType,
    int limit = 20,
    int skip = 0,
  }) async {
    String url = '${AppConstants.GET_RECOMMENDED_POSTS}?contentType=$contentType&limit=$limit';

    if (skip > 0) {
      url += '&skip=$skip';
    }

    return await apiClient.getData(url);
  }
}