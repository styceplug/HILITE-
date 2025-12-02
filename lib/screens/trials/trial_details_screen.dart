// --- New file: lib/screens/trials/trial_detail_screen.dart ---

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/trial_controller.dart';
import '../../widgets/custom_button.dart';
// Import TrialController, TrialModel, CustomButton

class TrialDetailScreen extends StatelessWidget {
  final String trialId;
  final TrialController controller = Get.find<TrialController>();

  TrialDetailScreen({required this.trialId, super.key}) {
    controller.fetchTrialDetails(trialId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trial Details')),
      body: Obx(() {
        final trial = controller.currentTrialDetails.value;
        if (controller.isProcessing.value || trial == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Assume isPlayerRole is a boolean check from your UserController
        const bool isPlayerRole = true;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image
              if (trial.banner != null) Image.network(trial.banner!, fit: BoxFit.cover),
              const SizedBox(height: 16),

              Text(trial.name, style: Get.textTheme.headlineMedium),
              const SizedBox(height: 8),

              Text('Club: ${trial.creator?.name ?? 'Unknown'}', style: Get.textTheme.bodyLarge),
              Text('Location: ${trial.location}', style: Get.textTheme.bodyLarge),
              Text('Date: ${trial.date.toLocal().toString().split(' ')[0]}', style: Get.textTheme.bodyLarge),
              Text('Age Group: ${trial.ageGroup}', style: Get.textTheme.bodyLarge),
              Text('Fee: \$${trial.registrationFee.toStringAsFixed(0)}', style: Get.textTheme.bodyLarge),
              Text('Type: ${trial.type.capitalizeFirst}', style: Get.textTheme.bodyLarge),

              const SizedBox(height: 16),
              Text(trial.description ?? 'No description provided.', style: Get.textTheme.bodyMedium),
              const SizedBox(height: 24),

              // Player Registration Button
              if (isPlayerRole)
                CustomButton(
                  text: 'Register Now (\$${trial.registrationFee.toStringAsFixed(0)})',
                  onPressed: controller.isProcessing.value
                      ? null
                      : () => controller.registerForTrial(trial.id),
                  isLoading: controller.isProcessing.value,
                ),

              // Club View: Registered Players List (if available and club owns trial)
              if (!isPlayerRole && trial.registeredPlayers != null) ...[
                const Divider(),
                Text('Registered Players (${trial.registeredPlayers!.length})', style: Get.textTheme.titleLarge),
                ...trial.registeredPlayers!.map((player) => ListTile(
                  title: Text(player.name),
                  subtitle: Text(player.username),
                )).toList(),
              ]
            ],
          ),
        );
      }),
    );
  }
}