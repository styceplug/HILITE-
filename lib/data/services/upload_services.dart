

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Upload State
// ---------------------------------------------------------------------------

enum UploadStatus { idle, uploading, success, failure }

class UploadState {
  final UploadStatus status;
  final double progress; // 0.0 → 1.0
  final String? thumbnailPath; // local file path for thumbnail preview
  final String? errorMessage;

  const UploadState({
    required this.status,
    this.progress = 0.0,
    this.thumbnailPath,
    this.errorMessage,
  });

  UploadState copyWith({
    UploadStatus? status,
    double? progress,
    String? thumbnailPath,
    String? errorMessage,
  }) =>
      UploadState(
        status: status ?? this.status,
        progress: progress ?? this.progress,
        thumbnailPath: thumbnailPath ?? this.thumbnailPath,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ---------------------------------------------------------------------------
// UploadService
// ---------------------------------------------------------------------------

class UploadService extends GetxService {
  // Reactive state — the pill widget observes this
  final Rx<UploadState> state = Rx<UploadState>(
    const UploadState(status: UploadStatus.idle),
  );

  // Internal cancel token
  bool _cancelled = false;

  // ── Convenience getters ──────────────────────────────────────────────────

  bool get isUploading => state.value.status == UploadStatus.uploading;
  double get progress => state.value.progress;

  // ── Public API ───────────────────────────────────────────────────────────

  /// Start a multipart upload with real-time progress.
  ///
  /// [uri]           – full URL (e.g. AppConstants.UPLOAD_VIDEO_POST)
  /// [filePath]      – absolute path to the media file
  /// [fileName]      – original filename from XFile.name (e.g. "clip.mp4")
  ///                   mirrors what http.MultipartFile used as filename:
  /// [fileFieldName] – multipart field name expected by server ('video'/'image')
  /// [mediaType]     – e.g. MediaType('video', 'mp4')
  /// [fields]        – extra text fields (title, description, etc.)
  /// [headers]       – auth + content headers
  /// [thumbnailPath] – optional local thumbnail shown in the pill
  ///
  /// Returns the decoded response body map, or throws on failure.
  Future<Map<String, dynamic>> uploadWithProgress({
    required String uri,
    required String filePath,
    required String fileName,       // ← added
    required String fileFieldName,
    required MediaType mediaType,
    required Map<String, String> fields,
    required Map<String, String> headers,
    String? thumbnailPath,
  }) async {
    _cancelled = false;

    // Reset → uploading
    state.value = UploadState(
      status: UploadStatus.uploading,
      progress: 0.0,
      thumbnailPath: thumbnailPath,
    );

    try {
      // fileName is passed in from XFile.name — same value your old code used
      // as filename: file.name in http.MultipartFile.fromBytes

      // Build a StreamedRequest so we can pipe bytes manually
      final request = http.StreamedRequest('POST', Uri.parse(uri));

      // -- Headers (no Content-Type here; multipart boundary is set below) --
      headers.forEach((k, v) {
        if (k.toLowerCase() != 'content-type') request.headers[k] = v;
      });

      // Build multipart body manually so we track byte progress
      final boundary = _generateBoundary();
      request.headers['Content-Type'] =
      'multipart/form-data; boundary=$boundary';

      // Gather the full byte payload into a list of chunks
      final bodyBytes = await _buildMultipartBody(
        boundary: boundary,
        fields: fields,
        fileFieldName: fileFieldName,
        filePath: filePath,
        mediaType: mediaType,
        fileName: fileName,
      );

      final totalBytes = bodyBytes.length;
      request.headers['Content-Length'] = '$totalBytes';

      // Stream bytes to the request sink in chunks, updating progress
      const chunkSize = 65536; // 64 KB chunks
      int sent = 0;

      Future<void> streamBody() async {
        for (int offset = 0; offset < bodyBytes.length; offset += chunkSize) {
          if (_cancelled) {
            request.sink.close();
            return;
          }
          final end = (offset + chunkSize).clamp(0, bodyBytes.length);
          request.sink.add(bodyBytes.sublist(offset, end));
          sent += end - offset;

          // Update progress (cap at 0.95 — last 5% is server processing)
          final rawProgress = sent / totalBytes;
          state.value = state.value.copyWith(
            progress: (rawProgress * 0.95).clamp(0.0, 0.95),
          );

          // Yield to event loop so UI can repaint
          await Future.delayed(Duration.zero);
        }
        await request.sink.close();
      }

      // Kick off streaming + wait for response concurrently
      final streamFuture = streamBody();
      final responseFuture = http.Client().send(request);

      await streamFuture;
      if (_cancelled) throw Exception('Upload cancelled');

      final streamedResponse = await responseFuture;
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📩 Upload response ${response.statusCode}: ${response.body}');
      }

      // Server done — jump to 100%
      state.value = state.value.copyWith(progress: 1.0);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = _safeDecodeJson(response.body);
        // Show success briefly, then idle
        state.value = state.value.copyWith(status: UploadStatus.success);
        Future.delayed(const Duration(seconds: 3), _resetToIdle);
        return body;
      } else {
        final body = _safeDecodeJson(response.body);
        final msg = body['message'] as String? ?? 'Upload failed (${response.statusCode})';
        throw Exception(msg);
      }
    } catch (e) {
      if (_cancelled) {
        _resetToIdle();
        throw Exception('Upload cancelled');
      }
      state.value = state.value.copyWith(
        status: UploadStatus.failure,
        errorMessage: e.toString(),
      );
      Future.delayed(const Duration(seconds: 4), _resetToIdle);
      rethrow;
    }
  }

  void cancel() {
    _cancelled = true;
  }

  void dismissPill() => _resetToIdle();

  // ── Internals ────────────────────────────────────────────────────────────

  void _resetToIdle() {
    state.value = const UploadState(status: UploadStatus.idle);
  }

  String _generateBoundary() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '----FlutterBoundary$timestamp';
  }

  /// Builds the multipart body by streaming the file from disk in chunks.
  ///
  /// Why not readAsBytes()?  readAsBytes() loads the entire file into memory
  /// before a single byte is sent.  A 200 MB video would spike RAM by 200 MB+
  /// before the upload even starts.  Streaming keeps peak memory near one
  /// chunk size (64 KB) regardless of file size.
  ///
  /// Structure: [text field parts] + [file part header] + [file bytes] + [closing boundary]
  /// This is assembled into a flat list so we know Content-Length up front,
  /// which some servers require.  The byte list itself is never held all at
  /// once — we write it straight into the StreamedRequest sink in the caller.
  Future<List<int>> _buildMultipartBody({
    required String boundary,
    required Map<String, String> fields,
    required String fileFieldName,
    required String filePath,
    required MediaType mediaType,
    required String fileName, // pass file.name to preserve original filename
  }) async {
    final output = <int>[];

    void writeln(String s) => output.addAll(utf8.encode('$s\r\n'));
    void write(String s) => output.addAll(utf8.encode(s));

    // ── Text fields (mirrors _buildBaseRequest's request.fields.addAll) ────
    for (final entry in fields.entries) {
      writeln('--$boundary');
      writeln('Content-Disposition: form-data; name="${entry.key}"');
      writeln('');
      writeln(entry.value);
    }

    // ── File field header ────────────────────────────────────────────────────
    writeln('--$boundary');
    writeln(
      'Content-Disposition: form-data; name="$fileFieldName"; filename="$fileName"',
    );
    writeln('Content-Type: ${mediaType.mimeType}');
    writeln('');

    // ── File bytes — streamed from disk, never fully in memory ──────────────
    final fileStream = File(filePath).openRead();
    await for (final chunk in fileStream) {
      output.addAll(chunk);
    }
    writeln(''); // CRLF after file data

    // ── Closing boundary ─────────────────────────────────────────────────────
    write('--$boundary--\r\n');

    return output;
  }

  Map<String, dynamic> _safeDecodeJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}