import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/trial_controller.dart';
import '../../controllers/user_controller.dart';
import '../../routes/routes.dart';
import '../../widgets/snackbars.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TrialListScreen extends StatelessWidget {
  final TrialController controller = Get.find<TrialController>();
  final UserController userController = Get.find<UserController>();

  TrialListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    bool isClub = userController.user.value?.role == 'club';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Football Trials',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
      ),

      floatingActionButton: isClub
          ? FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.createTrialScreen),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Trial", style: TextStyle(color: Colors.white)),
      )
          : null,

      // 2. Pull-to-Refresh Logic
      body: RefreshIndicator(
        onRefresh: () async => await controller.fetchTrials(),
        color: Colors.black,
        child: Obx(() {
          if (controller.isLoadingTrials.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.trialList.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.trialList.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final trial = controller.trialList[index];
              return _TrialCard(
                  trial: trial,
                  onTap: () {
                    if (trial.id.isNotEmpty) {
                      Get.toNamed(AppRoutes.trialDetailScreen, arguments: trial.id);
                    }
                  }
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No trials active right now",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: controller.fetchTrials,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
          )
        ],
      ),
    );
  }
}

// --- The Custom Card Widget ---

class _TrialCard extends StatelessWidget {
  final dynamic trial; // Replace 'dynamic' with TrialModel
  final VoidCallback onTap;

  const _TrialCard({required this.trial, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image & Badges Section
            Stack(
              children: [
                // Banner Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: trial.banner != null && trial.banner!.isNotEmpty
                        ? Image.network(trial.banner!, fit: BoxFit.cover)
                        : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),

                // Badge: Age Group
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trial.ageGroup.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Badge: Type (Open/Closed)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trial.type.toUpperCase(), // e.g., "OPEN"
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          trial.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "\$${trial.registrationFee.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Location Row
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          trial.location,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Date Row
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        dateFormatter.format(trial.date),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}