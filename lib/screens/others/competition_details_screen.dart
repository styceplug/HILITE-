import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../controllers/competition_controller.dart';
import '../../controllers/user_controller.dart';
import '../../models/competition_model.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class CompetitionDetailsScreen extends StatefulWidget {
  final String competitionId;

  const CompetitionDetailsScreen({Key? key, required this.competitionId})
    : super(key: key);

  @override
  State<CompetitionDetailsScreen> createState() =>
      _CompetitionDetailsScreenState();
}

class _CompetitionDetailsScreenState extends State<CompetitionDetailsScreen> {

  CompetitionController competitionController = Get.find<CompetitionController>();

  bool amIRegistered(CompetitionModel comp) {
    String myId = Get.find<UserController>().user.value?.id ?? "";
    if (comp.registered == null) return false;

    for (var item in comp.registered!) {
      // Check if item is Object (RegisteredClub)
      if (item is RegisteredClub && item.sId == myId) return true;
      // Check if item is String (ID)
      if (item is String && item == myId) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      competitionController.getCompetitionDetails(widget.competitionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false, // Let the sliver app bar hit the very top
      child: Scaffold(
        backgroundColor: const Color(0xFF030A1B), // Premium Dark Background
        body: GetBuilder<CompetitionController>(
          builder: (controller) {
            var competition = controller.competitionDetail;

            // --- SMART SKELETONIZER LOGIC ---
            final bool isInitialLoad = competition == null;

            // Format Date safely
            String formattedDate = "Loading Date...";
            if (competition != null && competition.date != null) {
              formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(DateTime.parse(competition.date.toString()));
            }

            var user = Get.find<UserController>().user.value;
            bool isClub = user?.role == 'club';
            bool isRegistered = competition != null ? amIRegistered(competition) : false;

            // Dummy fallbacks for Skeletonizer when competition is null
            final int fee = competition?.registrationFee ?? 25000;
            final bool isFree = fee == 0;
            final int prize = competition?.prize ?? 1000000;
            final Object teamsNeeded = competition?.clubsNeeded ?? 16;
            final int registeredCount = competition?.registered?.length ?? 4;

            return Skeletonizer(
              enabled: isInitialLoad,
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverAppBar(
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
                              competition?.banner != null && competition!.banner!.trim().isNotEmpty
                                  ? Image.network(
                                competition.banner!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => Container(
                                  color: Colors.white.withOpacity(0.05),
                                  child: Icon(Icons.broken_image, size: 80, color: Colors.white.withOpacity(0.1)),
                                ),
                              )
                                  : Container(
                                color: Colors.white.withOpacity(0.05),
                                child: Icon(Icons.emoji_events_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
                              ),
                              // Premium Gradient Overlay
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
                      ),

                      // 2. Content Body
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(Dimensions.width20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                competition?.name ?? "Loading Competition Title Here",
                                style: TextStyle(
                                  fontSize: Dimensions.font26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: Dimensions.height10),

                              // Host Info
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    backgroundImage: competition?.creator?.profilePicture != null
                                        ? NetworkImage(competition!.creator!.profilePicture!)
                                        : null,
                                    child: competition?.creator?.profilePicture == null
                                        ? Icon(Iconsax.building_3, size: 14, color: AppColors.buttonColor)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Hosted by ${competition?.creator?.username?.capitalizeFirst ?? 'Loading Club Name'}",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontWeight: FontWeight.w500,
                                      fontSize: Dimensions.font14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Dimensions.height20),

                              // Key Stats Row (Prize & Fee)
                              Row(
                                children: [
                                  _buildStatCard(
                                    "Prize Pool",
                                    "₦${NumberFormat('#,###').format(prize)}",
                                    Icons.emoji_events_rounded,
                                    Colors.amber,
                                  ),
                                  SizedBox(width: Dimensions.width15),
                                  _buildStatCard(
                                    "Entry Fee",
                                    isFree ? "Free" : "₦${NumberFormat('#,###').format(fee)}",
                                    Icons.payments_rounded,
                                    isFree ? AppColors.success : AppColors.buttonColor,
                                  ),
                                ],
                              ),
                              SizedBox(height: Dimensions.height20),

                              // Info Section (Location & Date)
                              _buildInfoRow(Iconsax.location, competition?.location ?? "Loading Location Area"),
                              SizedBox(height: Dimensions.height10),
                              _buildInfoRow(Iconsax.calendar_1, formattedDate),
                              SizedBox(height: Dimensions.height10),
                              _buildInfoRow(Iconsax.people, "$teamsNeeded Teams Needed"),

                              SizedBox(height: Dimensions.height20),
                              Divider(thickness: 1, color: Colors.white.withOpacity(0.1)),
                              SizedBox(height: Dimensions.height20),

                              // Description
                              Text(
                                "About Competition",
                                style: TextStyle(
                                  fontSize: Dimensions.font18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: Dimensions.height10),
                              Text(
                                competition?.description ?? "This is a placeholder description that fills up space so the skeletonizer can draw realistic looking text lines while the real data fetches from the backend.",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  height: 1.6,
                                  fontSize: Dimensions.font15,
                                ),
                              ),

                              SizedBox(height: Dimensions.height20),
                              Divider(thickness: 1, color: Colors.white.withOpacity(0.1)),
                              SizedBox(height: Dimensions.height20),

                              // Registered Clubs Section
                              Row(
                                children: [
                                  Text(
                                    "Registered Teams",
                                    style: TextStyle(
                                      fontSize: Dimensions.font18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.buttonColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "$registeredCount/$teamsNeeded",
                                      style: TextStyle(
                                        color: AppColors.buttonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: Dimensions.height15),

                              // Empty state for when it loads but is empty
                              if (!isInitialLoad && (competition!.registered == null || competition.registered!.isEmpty))
                                Text(
                                  "No teams registered yet. Be the first!",
                                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontStyle: FontStyle.italic),
                                ),

                              // Dummy lists for Skeletonizer
                              if (isInitialLoad)
                                ...List.generate(3, (index) => _buildMockTeamTile()),

                              // Actual populated lists
                              if (!isInitialLoad && competition!.registered != null)
                                ...competition.registered!.map((item) {
                                  if (item is RegisteredClub) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: Dimensions.height10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: Dimensions.width15, vertical: 4),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.white.withOpacity(0.1),
                                          child: Text(
                                            item.name?.isNotEmpty == true ? item.name![0].toUpperCase() : "T",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        title: Text(item.name ?? "Unknown Team", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        subtitle: Text("@${item.username ?? ''}", style: TextStyle(color: Colors.white.withOpacity(0.5))),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }).toList(),

                              SizedBox(height: Dimensions.height100), // Spacing for sticky bottom bar
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 3. Sticky Bottom Action Bar
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
                        child: isRegistered
                            ? Container(
                          height: 50,
                          decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.tick_circle, color: AppColors.success, size: 20),
                              const SizedBox(width: 8),
                              Text("Team Registered", style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        )
                            : !isClub
                            ? Container(
                          height: 50,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text(
                            "Registration Open to Clubs Only",
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold),
                          ),
                        )
                            : ElevatedButton(
                          onPressed: isInitialLoad ? null : () => _showRegisterDialog(controller, isFree, fee),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Center(
                            child: controller.isRegistering
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                              isFree ? "Register Team (Free)" : "Register Team (₦${NumberFormat('#,###').format(fee)})",
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withOpacity(0.5)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMockTeamTile() {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: Dimensions.width15, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.1),
          child: const Text("T"),
        ),
        title: const Text("Loading Team Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text("@loadingteam", style: TextStyle(color: Colors.white.withOpacity(0.5))),
      ),
    );
  }

  void _showRegisterDialog(CompetitionController controller, bool isFree, int fee) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1F2937), // Dark dialog background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Confirm Registration", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          isFree
              ? "Register your club for this competition for free?"
              : "Register your club for ₦${NumberFormat('#,###').format(fee)}?",
          style: TextStyle(color: Colors.white.withOpacity(0.8), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              controller.registerForCompetition(controller.competitionDetail!.sId!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isFree ? "Register" : "Pay & Register", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}