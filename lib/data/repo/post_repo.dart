import 'dart:io';

import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class PostRepo {
  final ApiClient apiClient;

  PostRepo({required this.apiClient});


  Future<Response> postNewComment({
    required String postId,
    required String content,
    String type = 'comment',
  }) async {
    final body = {
      'content': content,
      'type': type,
    };

    return await apiClient.postData(
      AppConstants.POST_NEW_COMMENTS(postId),
      body,
    );
  }


  http.MultipartRequest _buildBaseRequest({
    required String uri,
    required XFile file,
    required String fileFieldName, // 'image' or 'video'
    required String text,
    required String title,
    required String description,
    required bool isPublic,
  }) {
    final request = http.MultipartRequest('POST', Uri.parse(apiClient.baseUrl! + uri));

    // Add all field data
    request.fields.addAll({
      'text': text,
      'title': title, // Used for video
      'description': description, // Used for video
      // Use the field name expected by the server for image metadata
      'imageTitle': title,
      'imageDescription': description,
      'isPublic': isPublic.toString(),
    });

    // Add the file
    request.files.add(
      http.MultipartFile.fromBytes(
        fileFieldName,
        File(file.path).readAsBytesSync(),
        filename: file.name,
      ),
    );


    return request;
  }

// 4. UPLOAD IMAGE POST
  Future<Response> uploadImagePost({
    required XFile imageFile,
    required String text,
    required String title,
    required String description,
    required bool isPublic,
  }) async {
    final request = _buildBaseRequest(
      uri: AppConstants.UPLOAD_IMAGE_POST,
      file: imageFile,
      fileFieldName: 'image',
      text: text,
      title: title,
      description: description,
      isPublic: isPublic,
    );

    return await apiClient.postMultipartData(
      AppConstants.UPLOAD_IMAGE_POST,
      request,
    );
  }


  Future<Response> uploadVideoPost({
    required XFile videoFile,
    required String text,
    required String title,
    required String description,
    required bool isPublic,
  }) async {
    final request = _buildBaseRequest(
      uri: AppConstants.UPLOAD_VIDEO_POST,
      file: videoFile,
      fileFieldName: 'video',
      text: text,
      title: title,
      description: description,
      isPublic: isPublic,
    );

    return await apiClient.postMultipartData(
      AppConstants.UPLOAD_VIDEO_POST,
      request,
    );}

  Future<Response> getPostComments(String postId) async {
    return await apiClient.getData(
      AppConstants.GET_POST_COMMENTS(postId),
    );
  }

  Future<Response> likePost(String postId) async {
    return await apiClient.putData(
      AppConstants.LIKE_POST(postId),
      {},
    );
  }

  Future<Response> unlikePost(String postId) async {
    return await apiClient.putData(
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