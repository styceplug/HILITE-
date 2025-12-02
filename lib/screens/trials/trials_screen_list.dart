// --- New file: lib/screens/trials/trial_list_screen.dart ---

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/trial_controller.dart';
import '../../routes/routes.dart';


class TrialListScreen extends StatelessWidget {
  final TrialController controller = Get.find<TrialController>();

  TrialListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Football Trials'),
        actions: [
          // 💡 Only visible to Club users (assuming a Club role check)
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Get.toNamed(AppRoutes.createTrialScreen),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchTrials,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingTrials.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.trialList.isEmpty) {
          return const Center(child: Text('No trials available.'));
        }
        return ListView.builder(
          itemCount: controller.trialList.length,
          itemBuilder: (context, index) {
            final trial = controller.trialList[index];
            return ListTile(
              leading: trial.banner != null ? Image.network(trial.banner!, width: 50, height: 50, fit: BoxFit.cover) : const Icon(Icons.sports_soccer),
              title: Text(trial.name),
              subtitle: Text('${trial.location} - ${trial.ageGroup}'),
              trailing: Text('Fee: \$${trial.registrationFee.toStringAsFixed(0)}'),
              onTap: () => Get.toNamed(AppRoutes.trialDetailScreen, arguments: trial.id),
            );
          },
        );
      }),
    );
  }
}