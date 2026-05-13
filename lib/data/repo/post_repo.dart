import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart'; // REQUIRED for MediaType
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';
import '../services/upload_services.dart';

class PostRepo {
  final ApiClient apiClient;

  PostRepo({required this.apiClient});

  Future<Response> deletePost(String postId) async {
    return await apiClient.deleteData(AppConstants.DELETE_POST(postId));
  }

  Future<Response> getPostById(String id) async {
    return await apiClient.getData(AppConstants.GET_SINGLE_POST(id));
  }

  Future<Response> getBookmarkedPosts() async {
    return await apiClient.getData(AppConstants.GET_BOOKMARKED_POST);
  }

  Future<Response> postNewComment({
    required String postId,
    required String content,
    String type = 'comment',
    String? mentionedUser,
    String? parentComment,
  }) async {
    final body = <String, dynamic>{'content': content, 'type': type};

    if (mentionedUser != null && mentionedUser.isNotEmpty) {
      body['mentionedUser'] = mentionedUser;
    }

    if (parentComment != null && parentComment.isNotEmpty) {
      body['parentComment'] = parentComment;
    }

    return await apiClient.postData(
      AppConstants.POST_NEW_COMMENTS(postId),
      body,
    );
  }


  Map<String, String> _baseFields({
    required String text,
    required String title,
    required String description,
    required bool isPublic,
    required List<String> tags,
  }) {
    final Map<String, String> fields = {
      'text': text,
      'title': title,
      'description': description,
      'imageTitle': title,
      'imageDescription': description,
      'isPublic': isPublic.toString(),
    };

    if (tags.isNotEmpty) {
      fields['tags'] = tags.join(',');
    }

    debugPrint('🚀 [API LAYER] PREPARED FIELDS: $fields');

    return fields;
  }

  Future<Response> uploadVideoPost({
    required XFile videoFile,
    required String text,
    required String title,
    required String description,
    required bool isPublic,
    required List<String> tags, // Required parameter
    String? thumbnailPath,
  }) async {
    MediaType contentType = MediaType('video', 'mp4');
    if (videoFile.path.endsWith('.mov')) {
      contentType = MediaType('video', 'quicktime');
    } else if (videoFile.path.endsWith('.avi')) {
      contentType = MediaType('video', 'x-msvideo');
    }

    final uploadService = Get.find<UploadService>();

    try {
      final body = await uploadService.uploadWithProgress(
        uri: '${apiClient.appBaseUrl}${AppConstants.UPLOAD_VIDEO_POST}',
        filePath: videoFile.path,
        fileName: videoFile.name,
        fileFieldName: 'video',
        mediaType: contentType,
        // Pass tags INTO _baseFields
        fields: _baseFields(
          text: text,
          title: title,
          description: description,
          isPublic: isPublic,
          tags: tags,
        ),
        headers: apiClient.mainHeaders,
        thumbnailPath: thumbnailPath,
      );

      print('This is it: ${body}');

      return Response(statusCode: 201, body: body);
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> uploadImagePost({
    required XFile imageFile,
    required String text,
    required String title,
    required String description,
    required bool isPublic,
    required List<String> tags, // Added required parameter
  }) async {
    MediaType contentType = MediaType('image', 'jpeg');
    if (imageFile.path.endsWith('.png')) {
      contentType = MediaType('image', 'png');
    }

    final uploadService = Get.find<UploadService>();

    try {
      final body = await uploadService.uploadWithProgress(
        uri: '${apiClient.appBaseUrl}${AppConstants.UPLOAD_IMAGE_POST}',
        filePath: imageFile.path,
        fileName: imageFile.name,
        fileFieldName: 'image',
        mediaType: contentType,
        // Pass tags INTO _baseFields
        fields: _baseFields(
          text: text,
          title: title,
          description: description,
          isPublic: isPublic,
          tags: tags,
        ),
        headers: apiClient.mainHeaders,
      );

      print('Response Body: $body');

      return Response(statusCode: 201, body: body);
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> getPostComments(String postId) async {
    return await apiClient.getData(AppConstants.GET_POST_COMMENTS(postId));
  }

  Future<Response> likePost(String postId) async {
    return await apiClient.putData(AppConstants.LIKE_POST(postId), {});
  }

  Future<Response> unlikePost(String postId) async {
    return await apiClient.putData(AppConstants.UNLIKE_POST(postId), {});
  }

  Future<Response> bookmarkPost(String postId) async {
    return await apiClient.putData(AppConstants.BOOKMARK_POST(postId), {});
  }

  Future<Response> unBookmarkPost(String postId) async {
    return await apiClient.putData(AppConstants.UNBOOKMARK_POST(postId), {});
  }

  Future<Response> getRecommendedPosts({
    required String contentType,
    int limit = 20,
    int skip = 0,
  }) async {
    String url =
        '${AppConstants.GET_RECOMMENDED_POSTS}?contentType=$contentType&limit=$limit';

    if (skip > 0) {
      url += '&skip=$skip';
    }

    return await apiClient.getData(url);
  }
}
