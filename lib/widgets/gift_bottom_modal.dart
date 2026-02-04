import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:intl/intl.dart';
import '../controllers/post_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/wallet_controller.dart';
import '../models/gift_model.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/settings/wallet_screen.dart';


class GiftSelectionBottomSheet extends StatelessWidget {
  final String recipientId;

  final UserController userController = Get.find<UserController>();
  final WalletController walletController = Get.find<WalletController>();

  GiftSelectionBottomSheet({required this.recipientId, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60, // Adjusted height
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A), // Dark theme background
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),

          const Divider(color: Colors.white10, height: 1),

          // Gift Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: giftList.length,
              itemBuilder: (context, index) {
                final gift = giftList[index];
                return _GiftGridItem(
                  gift: gift,
                  recipientId: recipientId,
                  walletController: walletController,
                  userController: userController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Send a Gift',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // Balance Card & Deposit Button
          Row(
            children: [
              // Reactive Balance Card
              Obx(() {
                // Parse balance safely from String to Double/Int
                String balanceStr = userController.user.value?.tokenBalance ?? "0";
                double balance = double.tryParse(balanceStr) ?? 0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10)
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.token, color: Colors.amber, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        NumberFormat.compact().format(balance), // e.g. 1.5K
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(width: 15),

              // Deposit Button
              GestureDetector(
                onTap: () {
                  Get.back(); // Close sheet
                  Get.to(() => const WalletScreen());
                  //pause playing video
                  Get.find<PostController>().pauseAll();
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withOpacity(0.2)
                  ),
                  child: const Icon(Icons.add, color: Colors.greenAccent, size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GiftGridItem extends StatelessWidget {
  final GiftModel gift;
  final String recipientId;
  final WalletController walletController;
  final UserController userController;

  const _GiftGridItem({
    super.key,
    required this.gift,
    required this.recipientId,
    required this.walletController,
    required this.userController,
  });

  // Helper to determine border/glow color if none is provided in the model
  Color _getTierColor(int price) {
    if (price <= 300) return Colors.green;
    if (price <= 2000) return Colors.blue;
    if (price <= 8000) return Colors.purple;
    return Colors.amber;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. Check Affordability
      String balanceStr = userController.user.value?.tokenBalance ?? "0";
      double currentBalance = double.tryParse(balanceStr) ?? 0;
      bool canAfford = currentBalance >= gift.coins;

      // 2. Determine Display Color
      Color displayColor = gift.color ?? _getTierColor(gift.coins);

      return GestureDetector(
        onTap: () {
          if (canAfford) {
            Get.back(); // Close modal
            walletController.giftTokens(recipientId, gift.coins.toDouble());
          } else {
            CustomSnackBar.failure(message: 'Insufficient Funds: Fund your wallet to gift');

          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // Always show the active background color
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(15),
            // Always show the border
            border: Border.all(
              color: displayColor.withOpacity(0.5),
              width: 1.5,
            ),
            // Always show the glow/shadow
            boxShadow: [
              BoxShadow(
                  color: displayColor.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4)
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // IMAGE HANDLING
              Image.asset(
                gift.icon,
                // Always use the gift's actual color (or null if it's a full-color image)
                color: gift.color,
                height: Dimensions.height10 * 6.1,
                width: Dimensions.width10 * 6.1,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                gift.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // Always use White text
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Always use Amber for the coin icon and text
                  const Icon(Icons.token, color: Colors.amber, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    gift.coins.toString(),
                    style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 13
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}