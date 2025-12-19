import 'package:flutter/material.dart';
import 'package:hilite/utils/app_constants.dart';

class GiftModel {
  final String name;
  final int coins;
  final String icon;
  final Color? color; // Nullable

  GiftModel({
    required this.name,
    required this.coins,
    required this.icon,
    this.color, // Optional
  });
}

final List<GiftModel> giftList = [
  // Low Tier (Quick Support: ₦500 - ₦3,000)
  GiftModel(name: "Energy Drink", coins: 50, icon: AppConstants.getPngAsset('energy-drink')), // ₦500
  GiftModel(name: "Ice Pack", coins: 150, icon: AppConstants.getPngAsset('ice')), // ₦1,500
  GiftModel(name: "Socks Pack", coins: 250, icon: AppConstants.getPngAsset('socks')), // ₦2,500
  GiftModel(name: "Muscle Rub", coins: 300, icon: AppConstants.getPngAsset('balm')), // ₦3,000

  // Mid Tier (Solid Gifts: ₦5,000 - ₦20,000)
  GiftModel(name: "Training Vest", coins: 500, icon: AppConstants.getPngAsset('vest')), // ₦5,000
  GiftModel(name: "Club Cap", coins: 800, icon: AppConstants.getPngAsset('hat')), // ₦8,000
  GiftModel(name: "Football", coins: 1500, icon: AppConstants.getPngAsset('football-award')), // ₦15,000
  GiftModel(name: "Gloves", coins: 2000, icon: AppConstants.getPngAsset('gloves')), // ₦20,000

  // High Tier (Major Support: ₦30,000 - ₦80,000)
  GiftModel(name: "Jersey", coins: 3500, icon: AppConstants.getPngAsset('football-shirt')), // ₦35,000
  GiftModel(name: "Boots", coins: 5000, icon: AppConstants.getPngAsset('football-boots')), // ₦50,000
  GiftModel(name: "Gear Bag", coins: 6500, icon: AppConstants.getPngAsset('sport-bag')), // ₦65,000
  GiftModel(name: "Training Kit", coins: 8000, icon: AppConstants.getPngAsset('kit')), // ₦80,000

  // Premium (Whale Status: ₦100,000 - ₦1M)
  GiftModel(name: "Goal Net", coins: 10000, icon: AppConstants.getPngAsset('goal')), // ₦100,000
  GiftModel(name: "Recovery Pack", coins: 20000, icon: AppConstants.getPngAsset('recovery')), // ₦200,000
  GiftModel(name: "Endorsement", coins: 50000, icon: AppConstants.getPngAsset('endorsement')), // ₦500,000
  GiftModel(name: "Trophy", coins: 100000, icon: AppConstants.getPngAsset('winner')), // ₦1,000,000
];