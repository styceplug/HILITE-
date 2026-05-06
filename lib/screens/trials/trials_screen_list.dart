import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/trial_controller.dart';
import '../../controllers/user_controller.dart';
import '../../routes/routes.dart';
import '../../widgets/snackbars.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../widgets/trial_card.dart';

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
              return TrialCard(
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



