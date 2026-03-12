import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api/api_client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';


class ChatRepo {
  final ApiClient apiClient;

  ChatRepo({required this.apiClient});

  Future<Response> getChats({
    int page = 1,
    int limit = 20,
  }) async {
    return await apiClient.getData('/v1/chat?page=$page&limit=$limit');
  }

  Future<Response> getOrCreateChat(String targetId) async {
    return await apiClient.getData('/v1/chat/with/$targetId');
  }

  Future<Response> getMessages({
    required String chatId,
    int page = 1,
    int limit = 30,
  }) async {
    return await apiClient.getData(
      '/v1/chat/$chatId/messages?page=$page&limit=$limit',
    );
  }

  Future<Response> sendTextMessage({
    required String chatId,
    required String text,
  }) async {
    return await apiClient.postData(
      '/v1/chat/$chatId/messages',
      {
        'type': 'text',
        'text': text,
      },
    );
  }

  Future<Response> sendImageMessage({
    required String chatId,
    required File imageFile,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${apiClient.appBaseUrl}/v1/chat/$chatId/messages'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer ${apiClient.token}',
    });

    request.fields['type'] = 'image';

    final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
    final mimeParts = mimeType.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      ),
    );

    return await apiClient.postMultipartData(
      '/v1/chat/$chatId/messages',
      request,
    );
  }

  Future<Response> sendAudioMessage({
    required String chatId,
    required File audioFile,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${apiClient.appBaseUrl}/v1/chat/$chatId/messages'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer ${apiClient.token}',
    });

    request.fields['type'] = 'audio';

    final mimeType = lookupMimeType(audioFile.path) ?? 'audio/mpeg';
    final mimeParts = mimeType.split('/');

    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        contentType: MediaType(mimeParts[0], mimeParts[1]),
      ),
    );

    return await apiClient.postMultipartData(
      '/v1/chat/$chatId/messages',
      request,
    );
  }

  Future<Response> markChatAsRead(String chatId) async {
    return await apiClient.putData('/v1/chat/$chatId/read', {});
  }

  Future<Response> deleteMessage(String messageId) async {
    return await apiClient.deleteData('/v1/chat/messages/$messageId');
  }
}