import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wallet_controller.dart';
// Import your WalletController and AppColors/Dimensions

class TopUpBottomSheet extends StatefulWidget {
  const TopUpBottomSheet({super.key});

  @override
  State<TopUpBottomSheet> createState() => _TopUpBottomSheetState();
}

class _TopUpBottomSheetState extends State<TopUpBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final WalletController walletController = Get.find<WalletController>();

  final List<int> _quickAmounts = [1000, 2000, 5000, 10000];
  int? _selectedAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Top Up Wallet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            "10 NGN = 1 Token",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 20),

          // Quick Select Grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _quickAmounts.map((amount) {
              bool isSelected = _selectedAmount == amount;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAmount = amount;
                    _amountController.text = amount.toString();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    "₦$amount",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Custom Input
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              setState(() {
                _selectedAmount = null; // Deselect chips if typing manually
              });
            },
            decoration: InputDecoration(
              labelText: "Enter Amount (NGN)",
              prefixText: "₦ ",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),

          const SizedBox(height: 30),

          // Pay Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_amountController.text.isNotEmpty) {
                  double? amount = double.tryParse(_amountController.text);
                  if (amount != null && amount > 0) {
                    Get.back(); // Close sheet
                    walletController.initiatePurchase(amount);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Proceed to Payment",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }
}