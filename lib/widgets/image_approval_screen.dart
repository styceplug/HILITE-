import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageApprovalScreen extends StatelessWidget {
  final File imageFile;

  const ImageApprovalScreen({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          onPressed: () => Get.back(result: false),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
            ),
          ),

          // 2. Premium Gradient at bottom for visibility
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Send Button
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: () => Get.back(result: true),
              backgroundColor: const Color(0xFF2563EB),
              elevation: 4,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text(
                "Send Image",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}