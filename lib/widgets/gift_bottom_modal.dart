import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                  Get.to(() => const WalletScreen()); // Navigate to wallet
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
    required this.gift,
    required this.recipientId,
    required this.walletController,
    required this.userController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 1. Check Affordability Reactively
      String balanceStr = userController.user.value?.tokenBalance ?? "0";
      double currentBalance = double.tryParse(balanceStr) ?? 0;
      bool canAfford = currentBalance >= gift.coins;

      return GestureDetector(
        onTap: () {
          if (canAfford) {
            Get.back(); // Close the modal immediately

            // 2. Call the API
            walletController.giftTokens(recipientId, gift.coins.toDouble());
          } else {
            // Optional: Shake animation or toast
            Get.snackbar(
                "Low Balance",
                "You need ${gift.coins - currentBalance} more tokens.",
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: EdgeInsets.all(20)
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: canAfford
                ? const Color(0xFF2C2C2C) // Active color
                : Colors.white.withOpacity(0.02), // Disabled color
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: canAfford
                  ? gift.color.withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: canAfford ? [
              BoxShadow(
                  color: gift.color.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4)
              )
            ] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                gift.icon,
                color: canAfford ? gift.color : Colors.grey[700],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                gift.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: canAfford ? Colors.white : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.token, color: canAfford ? Colors.amber : Colors.grey[700], size: 12),
                  const SizedBox(width: 4),
                  Text(
                    gift.coins.toString(),
                    style: TextStyle(
                        color: canAfford ? Colors.amber : Colors.grey[700],
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