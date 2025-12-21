import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


class UploadContent extends StatefulWidget {
  const UploadContent({super.key});

  @override
  State<UploadContent> createState() => _UploadContentState();
}

class _UploadContentState extends State<UploadContent> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isFrontCamera = false;
  bool _isFlashOn = false;
  bool _isVideoMode = false; // This only controls the CAMERA UI

  final ImagePicker _picker = ImagePicker();
  XFile? _lastGalleryItem;
  bool _lastItemIsVideo = false; // Track if the gallery item is video

  @override
  void initState() {
    super.initState();
    _checkPermissions().then((_) => _initializeCamera());
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.photos,
    ].request();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final selectedCamera = _isFrontCamera ? cameras.last : cameras.first;

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isCameraInitialized = false;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    _isFlashOn = !_isFlashOn;
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  Future<void> _captureMedia() async {
    if (!_isCameraInitialized) return;

    if (_isVideoMode) {
      if (_isRecording) {
        final file = await _cameraController!.stopVideoRecording();
        setState(() => _isRecording = false);
        // From Camera: Use _isVideoMode to determine type
        _navigateToPostDetails(file, isVideo: true);
      } else {
        await _cameraController!.startVideoRecording();
        setState(() => _isRecording = true);
        Timer(const Duration(seconds: 30), () async {
          if (_isRecording) {
            final file = await _cameraController!.stopVideoRecording();
            setState(() => _isRecording = false);
            _navigateToPostDetails(file, isVideo: true);
          }
        });
      }
    } else {
      final file = await _cameraController!.takePicture();
      // From Camera: Use _isVideoMode (false)
      _navigateToPostDetails(file, isVideo: false);
    }
  }

  // 🛠️ FIXED: Added optional isVideo parameter to override camera state
  void _navigateToPostDetails(XFile file, {required bool isVideo}) {
    Get.toNamed(AppRoutes.postDetailScreen, arguments: {
      'file': file,
      'isVideo': isVideo // Pass the explicit type
    });
  }

  // 🛠️ FIXED: Logic to detect file type from Gallery
  Future<void> _pickFromGallery() async {
    try {
      // pickMedia() allows selecting ONE image OR ONE video
      final result = await _picker.pickMedia();

      if (result != null) {
        // Simple logic to check extension
        final String extension = result.path.split('.').last.toLowerCase();
        final bool isVideo = ['mp4', 'mov', 'avi', 'mkv', 'flv'].contains(extension);

        setState(() {
          _lastGalleryItem = result;
          _lastItemIsVideo = isVideo;
        });

        _navigateToPostDetails(result, isVideo: isVideo);
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine dimensions (assuming usage of a package or MediaQuery)
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🟢 Camera Preview
            if (_isCameraInitialized)
              SizedBox(
                width: width,
                height: height,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CameraPreview(_cameraController!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // 🎛️ Top Controls
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(
                    icon: Icons.flash_on,
                    active: _isFlashOn,
                    onTap: _toggleFlash,
                  ),
                  _buildIconButton(
                    icon: _isVideoMode ? Icons.videocam : Icons.photo_camera,
                    onTap: () => setState(() => _isVideoMode = !_isVideoMode),
                  ),
                  _buildIconButton(
                    icon: Icons.cameraswitch,
                    onTap: _toggleCamera,
                  ),
                ],
              ),
            ),

            // 🔴 Capture Button + Gallery
            Positioned(
              bottom: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGalleryButton(),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: _captureMedia,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isRecording ? Colors.red : Colors.white,
                          width: 5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _isVideoMode
                              ? (_isRecording
                              ? Icons.stop
                              : Icons.videocam)
                              : Icons.camera_alt,
                          color: _isRecording ? Colors.red : Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  const SizedBox(width: 64), // spacing symmetry
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    bool active = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? Colors.white24 : Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: _pickFromGallery,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _lastGalleryItem == null
            ? const Icon(Icons.photo, color: Colors.white)
            : ClipRRect(
          borderRadius: BorderRadius.circular(12),
          // 🛠️ FIXED: If it's a video, show an Icon, otherwise show the image
          child: _lastItemIsVideo
              ? const Center(child: Icon(Icons.videocam, color: Colors.white))
              : Image.file(
            File(_lastGalleryItem!.path),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}