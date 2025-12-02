// --- New file: lib/widgets/gift_selection_bottom_sheet.dart ---

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/post_controller.dart';
import '../controllers/wallet_controller.dart';
import '../models/gift_model.dart';


class GiftSelectionBottomSheet extends StatelessWidget {
  final String postId;

  final WalletController walletController = Get.find<WalletController>();
  final PostController postController = Get.find<PostController>();

  GiftSelectionBottomSheet({required this.postId, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // 75% screen height
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [

          _buildHeader(),

          const Divider(color: Colors.white10, height: 1),

          // 2. Gift Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 items per row
                childAspectRatio: 0.8, // Taller items for icon and text
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: giftList.length,
              itemBuilder: (context, index) {
                final gift = giftList[index];
                return _GiftGridItem(
                  gift: gift,
                  postId: postId,
                  walletController: walletController,
                  postController: postController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          const Text(
            'Send a Gift',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),

          // Balance Card & Deposit Button
          Row(
            children: [
              // Balance Card (Reactive)
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.toll, color: Colors.amber, size: 18), // Coin Icon
                    const SizedBox(width: 5),
                    Text(
                      walletController.userCoins.toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),

              const SizedBox(width: 10),

              // Deposit Button
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to deposit screen
                  print('Navigate to Deposit Screen');
                },
                child: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 30),
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
  final String postId;
  final WalletController walletController;
  final PostController postController;

  const _GiftGridItem({
    required this.gift,
    required this.postId,
    required this.walletController,
    required this.postController,
  });

  @override
  Widget build(BuildContext context) {
    // Check if user can afford the gift
    final bool canAfford = walletController.canAfford(gift.coins);

    return GestureDetector(
      onTap: () {
        if (canAfford) {
          // TODO: Implement gift submission logic in PostController
          postController.sendGift(postId, gift);
          Get.back(); // Close modal after selection
        } else {
          // Show error or redirect to deposit
          // CustomSnackBar.failure(message: "Not enough coins for ${gift.name}!");
          print("Cannot afford ${gift.name}");
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(canAfford ? 0.05 : 0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: canAfford ? gift.color.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gift Icon
            Icon(
              gift.icon,
              color: canAfford ? gift.color : Colors.grey,
              size: 40,
            ),
            const SizedBox(height: 5),
            // Gift Name
            Text(
              gift.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: canAfford ? Colors.white : Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 5),
            // Coin Cost
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.toll, color: Colors.amber, size: 14),
                const SizedBox(width: 3),
                Text(
                  gift.coins.toString(),
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}