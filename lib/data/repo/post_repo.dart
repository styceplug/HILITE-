import 'dart:io';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart'; // REQUIRED for MediaType
import 'package:mime/mime.dart'; // Optional, but good for auto-detection
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
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
  }) async {
    final body = {'content': content, 'type': type};

    return await apiClient.postData(
      AppConstants.POST_NEW_COMMENTS(postId),
      body,
    );
  }

  /*http.MultipartRequest _buildBaseRequest({
    required String uri,
    required XFile file,
    required String fileFieldName, // 'image' or 'video'
    required String text,
    required String title,
    required String description,
    required bool isPublic,
    required MediaType mediaType, // <--- 1. ADD THIS PARAMETER
  }) {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(apiClient.baseUrl! + uri),
    );

    // Add fields
    request.fields.addAll({
      'text': text,
      'title': title,
      'description': description,
      'imageTitle': title,
      'imageDescription': description,
      'isPublic': isPublic.toString(),
    });

    // 2. Add File with EXPLICIT ContentType
    request.files.add(
      http.MultipartFile.fromBytes(
        fileFieldName,
        File(file.path).readAsBytesSync(),
        filename: file.name,
        contentType: mediaType, // <--- CRITICAL FIX
      ),
    );

    return request;
  }*/

/*  // 4. UPLOAD IMAGE POST
  Future<Response> uploadImagePost({
    required XFile imageFile,
    required String text,
    required String title,
    required String description,
    required bool isPublic,
  }) async {
    // Default to jpeg, or detect
    MediaType contentType = MediaType('image', 'jpeg');
    if (imageFile.path.endsWith('.png')) {
      contentType = MediaType('image', 'png');
    }

    final request = _buildBaseRequest(
      uri: AppConstants.UPLOAD_IMAGE_POST,
      file: imageFile,
      fileFieldName: 'image',
      text: text,
      title: title,
      description: description,
      isPublic: isPublic,
      mediaType: contentType,
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
    // Determine mime type (Basic logic)
    // You can also use lookupMimeType(videoFile.path) from package:mime
    MediaType contentType = MediaType('video', 'mp4');

    if (videoFile.path.endsWith('.mov')) {
      contentType = MediaType('video', 'quicktime');
    } else if (videoFile.path.endsWith('.avi')) {
      contentType = MediaType('video', 'x-msvideo');
    }

    final request = _buildBaseRequest(
      uri: AppConstants.UPLOAD_VIDEO_POST,
      file: videoFile,
      fileFieldName: 'video',
      text: text,
      title: title,
      description: description,
      isPublic: isPublic,
      mediaType: contentType, // Pass it here
    );

    return await apiClient.postMultipartData(
      AppConstants.UPLOAD_VIDEO_POST,
      request,
    );
  }*/

  Map<String, String> _baseFields({
    required String text,
    required String title,
    required String description,
    required bool isPublic,
  }) =>
      {
        'text': text,
        'title': title,
        'description': description,
        'imageTitle': title,         // mirrors _buildBaseRequest
        'imageDescription': description, // mirrors _buildBaseRequest
        'isPublic': isPublic.toString(),
      };



  Future<Response> uploadVideoPost({
    required XFile videoFile,
    required String text,
    required String title,
    required String description,
    required bool isPublic,
    String? thumbnailPath, // optional — pass a generated thumbnail file path
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
        fileName: videoFile.name,   // ← mirrors filename: file.name from fromBytes
        fileFieldName: 'video',
        mediaType: contentType,
        fields: _baseFields(
          text: text,
          title: title,
          description: description,
          isPublic: isPublic,
        ),
        headers: apiClient.mainHeaders,
        thumbnailPath: thumbnailPath,
      );

      // Wrap in a GetConnect Response so PostController is untouched
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
        fileName: imageFile.name,   // ← mirrors filename: file.name from fromBytes
        fileFieldName: 'image',
        mediaType: contentType,
        fields: _baseFields(
          text: text,
          title: title,
          description: description,
          isPublic: isPublic,
        ),
        headers: apiClient.mainHeaders,
        // Images don't need a thumbnail preview in the pill
      );

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
