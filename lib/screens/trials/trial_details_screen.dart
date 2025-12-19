import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/dimensions.dart';

import '../../controllers/trial_controller.dart';
import '../../controllers/user_controller.dart';
import '../../widgets/custom_button.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TrialDetailScreen extends StatelessWidget {
  TrialDetailScreen({super.key});

  final TrialController controller = Get.find<TrialController>();
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    // 1. Safety Logic
    final String trialId = Get.arguments ?? '';
    if (trialId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchTrialDetails(trialId);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        final trial = controller.currentTrialDetails.value;

        if (controller.isProcessing.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (trial == null) {
          return _buildErrorState();
        }

        // Role Logic
        bool isPlayer = userController.user.value?.role == 'player';

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                // 1. Collapsing Header Image
                _buildSliverAppBar(trial),

                // 2. Main Content Body
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Host
                        Text(
                          trial.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Host Profile Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              child: const Icon(Icons.business, size: 14, color: Colors.blue),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Hosted by ${trial.creator?.name ?? 'Unknown Club'}",
                              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Key Info Grid (Date, Location, etc.)
                        _buildInfoGrid(trial),

                        const SizedBox(height: 25),
                        const Divider(height: 1),
                        const SizedBox(height: 25),

                        // Description Section
                        const Text(
                          "About this Trial",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          trial.description ?? 'No description provided for this event.',
                          style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                        ),

                        const SizedBox(height: 30), // Spacing for bottom bar
                      ],
                    ),
                  ),
                ),

                // 3. Registered Players List (Only visible to Club)
                if (trial.registeredPlayers != null) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Text(
                            "Registered Talent",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              "${trial.registeredPlayers!.length}",
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final player = trial.registeredPlayers![index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: player.profilePicture != null
                                    ? NetworkImage(player.profilePicture!)
                                    : null,
                                backgroundColor: Colors.blue.withOpacity(0.1),
                                child: player.profilePicture == null
                                    ? Text(player.name[0].toUpperCase(), style: const TextStyle(color: Colors.blue))
                                    : null,
                              ),
                              title: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("@${player.username}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.visibility_outlined, color: Colors.grey),
                                onPressed: () {
                                  // Navigate to player profile
                                },
                              ),
                            ),
                          );
                        },
                        childCount: trial.registeredPlayers!.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ]
              ],
            ),

            // 4. Sticky Bottom Action Bar (For Players)
            if (isPlayer)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:  EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Registration Fee", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              "\$${trial.registrationFee.toStringAsFixed(0)}",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: controller.isProcessing.value
                              ? null
                              : () => controller.registerForTrial(trial.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Premium feel
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: controller.isProcessing.value
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Register Now", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSliverAppBar(var trial) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: const BackButton(color: Colors.black),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            trial.banner != null
                ? Image.network(trial.banner!, fit: BoxFit.cover)
                : Container(
              color: Colors.grey[200],
              child: const Icon(Icons.sports_soccer, size: 80, color: Colors.grey),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(var trial) {
    // Format Date
    String formattedDate = DateFormat('EEE, d MMM').format(trial.date);
    String formattedTime = DateFormat('h:mm a').format(trial.date);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildDetailChip(Icons.calendar_month, formattedDate, Colors.blue),
        _buildDetailChip(Icons.access_time, formattedTime, Colors.orange),
        _buildDetailChip(Icons.location_on, trial.location, Colors.red),
        _buildDetailChip(Icons.groups, trial.ageGroup, Colors.purple),
        _buildDetailChip(Icons.category, trial.type.toUpperCase(), Colors.teal),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Failed to load trial details"),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Go Back"),
          )
        ],
      ),
    );
  }
}