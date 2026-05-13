import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/user_controller.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/snackbars.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.fetchOrGenerateReferralCode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A1B), // Premium Dark Background
      appBar: CustomAppbar(
        backgroundColor: const Color(0xFF030A1B),
        centerTitle: false,
        customTitle: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Referral Program',
            style: TextStyle(
              fontSize: Dimensions.font20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingIcon: const BackButton(color: Colors.white),
      ),
      body: GetBuilder<UserController>(
          builder: (controller) {
            bool isLoading = controller.isLoadingReferrals;
            String displayCode = controller.referralCode ?? "GENERATING...";

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Top Illustration Box ---
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: AppColors.buttonColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.gift,
                          size: 70,
                          color: AppColors.buttonColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.height30),

                  // --- Your Referral Code ---
                  Text(
                    "Your Referral Code",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),

                  SizedBox(height: Dimensions.height10),

                  Skeletonizer(
                    enabled: isLoading,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: AppColors.buttonColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            displayCode,
                            style: const TextStyle(
                              fontSize: 24,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: isLoading || displayCode.contains("ERROR") ? null : () {
                              Clipboard.setData(ClipboardData(text: displayCode));
                              CustomSnackBar.showToast(message: 'Referral code copied!');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.buttonColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Iconsax.copy, size: 22, color: AppColors.buttonColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.height20),

                  // --- Copy & Share Buttons ---
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoading || displayCode.contains("ERROR") ? null : () {
                            Clipboard.setData(ClipboardData(text: displayCode));
                            CustomSnackBar.showToast(message: 'Referral code copied!');
                          },
                          icon: const Icon(Iconsax.copy, size: 18),
                          label: const Text("Copy Code", style: TextStyle(fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isLoading || displayCode.contains("ERROR") ? null : () {
                            // implement share logic
                          },
                          icon: const Icon(Iconsax.share, color: Colors.white, size: 18),
                          label: const Text(
                            "Share",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Dimensions.height40),

                  // --- How It Works ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "How It Works",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.height15),

                  _buildStep(
                    "Invite your friends",
                    "Share your referral code or link with your friends.",
                  ),
                  _buildStep(
                    "They sign up",
                    "They create an account using your referral code.",
                  ),
                  _buildStep(
                    "Earn rewards",
                    "You and your friend both receive bonuses.",
                  ),

                  SizedBox(height: Dimensions.height30),

                  // --- Reward Breakdown ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Reward Breakdown",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: Dimensions.height15),
                        Divider(color: Colors.white.withOpacity(0.1), height: 1),
                        SizedBox(height: Dimensions.height10),
                        _rewardRow("You earn", "₦500 credit"),
                        _rewardRow("Friend earns", "₦500 credit"),
                      ],
                    ),
                  ),

                  SizedBox(height: Dimensions.height40),

                  // --- Your Referrals Section ---
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Your Referrals",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.height15),

                  Skeletonizer(
                    enabled: isLoading,
                    child: isLoading
                        ? _buildDummyReferrals()
                        : controller.referredUsers.isEmpty
                        ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "You haven't referred anyone yet.",
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.referredUsers.length,
                      itemBuilder: (context, index) {
                        var user = controller.referredUsers[index];
                        return _buildReferredUserTile(user);
                      },
                    ),
                  ),

                  SizedBox(height: Dimensions.height40),
                ],
              ),
            );
          }
      ),
    );
  }

  Widget _buildStep(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.tick_circle, size: 18, color: AppColors.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _rewardRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              title,
              style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8))
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.success,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReferredUserTile(dynamic user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.user, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'] ?? 'Unknown User',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user['role']?.toString().capitalizeFirst ?? 'Fan',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Skeletonizer Mock Data
  Widget _buildDummyReferrals() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return _buildReferredUserTile({'username': 'Loading User', 'role': 'player'});
      },
    );
  }
}