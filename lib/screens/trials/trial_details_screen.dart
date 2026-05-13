import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/trial_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/trial_model.dart';
import '../../routes/routes.dart';
import '../../utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';



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

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF030A1B), // Premium Dark Background
        body: Obx(() {
          final realTrial = controller.currentTrialDetails.value;

          // Smart Loading Logic:
          final bool isInitialLoad = realTrial == null && controller.isProcessing.value;

          if (realTrial == null && !controller.isProcessing.value) {
            return _buildErrorState();
          }

          // Feed the UI a dummy trial so Skeletonizer can draw the shapes while loading
          final trial = realTrial ?? _getMockTrial();

          // User & Role Logic
          final currentUserId = userController.user.value?.id;
          final bool isPlayer = userController.user.value?.role == 'player';
          final bool isFree = trial.registrationFee == 0;

          // --- FIX: Check if current user is already registered ---
          final bool isAlreadyRegistered = trial.registeredPlayers?.any((player) => player.id == currentUserId) ?? false;

          return Skeletonizer(
            enabled: isInitialLoad,
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 1. Collapsing Header Image
                    _buildSliverAppBar(trial),

                    // 2. Main Content Body
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(Dimensions.width20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              trial.name,
                              style: TextStyle(
                                fontSize: Dimensions.font25,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),

                            // Host Profile Row
                            InkWell(
                              onTap: isInitialLoad ? null : () {
                                if (trial.creator?.id != null) {
                                  Get.toNamed(AppRoutes.othersProfileScreen, arguments: {'targetId': trial.creator!.id});
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    backgroundImage: trial.creator?.profilePicture != null && trial.creator!.profilePicture!.isNotEmpty
                                        ? NetworkImage(trial.creator!.profilePicture!)
                                        : null,
                                    child: trial.creator?.profilePicture == null || trial.creator!.profilePicture!.isEmpty
                                        ? const Icon(Iconsax.building_3, size: 14, color: Colors.blueAccent)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Hosted by ${trial.creator?.clubName ?? trial.creator?.name  ?? 'Unknown'}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: Dimensions.font14,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: Dimensions.height20),

                            // Key Info Grid (Date, Location, etc.)
                            _buildInfoGrid(trial),

                            SizedBox(height: Dimensions.height20),
                            Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                            SizedBox(height: Dimensions.height20),

                            // Description Section
                            const Text(
                              "About this Trial",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: Dimensions.height10),
                            Text(
                              trial.description ?? 'No description provided for this event.',
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),

                            SizedBox(height: Dimensions.height30),
                          ],
                        ),
                      ),
                    ),

                    // 3. Registered Players List
                    if (trial.registeredPlayers != null && trial.registeredPlayers!.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                          child: Row(
                            children: [
                              const Text(
                                "Registered Talent",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "${trial.registeredPlayers!.length}",
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.all(Dimensions.width20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final player = trial.registeredPlayers![index];
                              return Container(
                                margin: EdgeInsets.only(bottom: Dimensions.height10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                                  leading: CircleAvatar(
                                    backgroundImage: player.profilePicture != null && player.profilePicture!.isNotEmpty
                                        ? NetworkImage(player.profilePicture!)
                                        : null,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    child: player.profilePicture == null || player.profilePicture!.isEmpty
                                        ? Text(
                                        player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                                    )
                                        : null,
                                  ),
                                  title: Text(
                                      player.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                                  ),
                                  subtitle: Text(
                                    "@${player.username}",
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                                  ),
                                  trailing: Icon(Iconsax.arrow_right_3, color: Colors.white.withOpacity(0.3), size: 18),
                                  onTap: () {
                                    if (!isInitialLoad) {
                                      Get.toNamed(AppRoutes.othersProfileScreen, arguments: {'targetId': player.id});
                                    }
                                  },
                                ),
                              );
                            },
                            childCount: trial.registeredPlayers!.length,
                          ),
                        ),
                      ),
                    ],
                    // Extra padding at the bottom so content doesn't hide behind the sticky bar
                    SliverToBoxAdapter(child: SizedBox(height: isPlayer ? 100 : 40)),
                  ],
                ),

                // 4. Sticky Bottom Action Bar (For Players)
                if (isPlayer)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                        vertical: Dimensions.height15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF030A1B),
                        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Registration Fee",
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isFree ? 'Free' : '₦${NumberFormat('#,###').format(trial.registrationFee)}',
                                  style: TextStyle(
                                    fontSize: Dimensions.font22,
                                    fontWeight: FontWeight.bold,
                                    color: isFree ? Colors.greenAccent : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),

                            // --- REGISTRATION BUTTON WITH SAFETY DISABLE ---
                            ElevatedButton(
                              onPressed: isInitialLoad || controller.isProcessing.value || isAlreadyRegistered
                                  ? null
                                  : () => controller.registerForTrial(trial.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isAlreadyRegistered ? Colors.white.withOpacity(0.1) : Colors.blueAccent,
                                disabledBackgroundColor: Colors.white.withOpacity(0.1),
                                disabledForegroundColor: Colors.white.withOpacity(0.5),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.width30,
                                  vertical: Dimensions.height15,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: controller.isProcessing.value && !isInitialLoad && !isAlreadyRegistered
                                  ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                                  : Text(
                                  isAlreadyRegistered ? "Registered" : "Register Now",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSliverAppBar(var trial) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      backgroundColor: const Color(0xFF030A1B),
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            trial.banner != null && trial.banner!.trim().isNotEmpty
                ? Image.network(
              trial.banner!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.white.withOpacity(0.05),
                child: Icon(Icons.broken_image, size: 80, color: Colors.white.withOpacity(0.1)),
              ),
            )
                : Container(
              color: Colors.white.withOpacity(0.05),
              child: Icon(Icons.sports_soccer, size: 80, color: Colors.white.withOpacity(0.1)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    const Color(0xFF030A1B),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid(var trial) {
    String formattedDate = DateFormat('EEE, d MMM').format(trial.date);
    String formattedTime = DateFormat('h:mm a').format(trial.date);

    // Safely cast and capitalize pure Dart-style to avoid dynamic extension crashes
    String typeStr = trial.type?.toString() ?? '';
    String displayType = typeStr.isNotEmpty
        ? '${typeStr[0].toUpperCase()}${typeStr.substring(1)}'
        : '';

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildDetailChip(Iconsax.calendar_1, formattedDate),
        _buildDetailChip(Iconsax.clock, formattedTime),
        _buildDetailChip(Iconsax.location, trial.location),
        _buildDetailChip(Iconsax.profile_2user, trial.ageGroup.toUpperCase()),
        _buildDetailChip(Iconsax.category, displayType), // <-- FIXED HERE
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
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
          Icon(Icons.error_outline, size: 48, color: Colors.white.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text("Failed to load trial details", style: TextStyle(color: Colors.white)),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Go Back", style: TextStyle(color: Colors.blueAccent)),
          )
        ],
      ),
    );
  }

  // --- DUMMY MODEL FOR SKELETONIZER ---
  TrialModel _getMockTrial() {
    return TrialModel(
      id: 'mock',
      name: 'Loading Placeholder Title For Trial',
      location: 'Loading Location...',
      date: DateTime.now(),
      ageGroup: 'U-20',
      type: 'Open',
      registrationFee: 0,
      description: 'This is a long description placeholder to make the skeleton look realistic. ' * 3,
      creator: TrialCreator(
        id: 'mock',
        name: 'Loading Club Name',
        username: 'mock',
        role: 'club',
      ),
      registeredPlayers: [
        RegisteredPlayer(id: '1', name: 'Player One', username: 'player1', role: 'player'),
        RegisteredPlayer(id: '2', name: 'Player Two', username: 'player2', role: 'player'),
        RegisteredPlayer(id: '3', name: 'Player Three', username: 'player3', role: 'player'),
      ],
    );
  }
}