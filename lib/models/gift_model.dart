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
  // --- TIER 1: The Basics (Entry Level) ---
  GiftModel(name: "Whistle", coins: 100, icon: AppConstants.getPngAsset('whistle')),
  GiftModel(name: "Cones", coins: 250, icon: AppConstants.getPngAsset('cones')),
  GiftModel(name: "Socks", coins: 500, icon: AppConstants.getPngAsset('socks')),
  GiftModel(name: "Muscle Spray", coins: 1000, icon: AppConstants.getPngAsset('muscle-spray')),

  // --- TIER 2: Training Gear (Amateur) ---
  GiftModel(name: "Training Bib", coins: 2500, icon: AppConstants.getPngAsset('training-bib')),
  GiftModel(name: "First Aid", coins: 5000, icon: AppConstants.getPngAsset('first-aid')),
  GiftModel(name: "Captain Armband", coins: 7500, icon: AppConstants.getPngAsset('captain-armband')),
  GiftModel(name: "Corner Flag", coins: 10000, icon: AppConstants.getPngAsset('corner-flags')),

  // --- TIER 3: Match Day Kit (Professional) ---
  GiftModel(name: "Football Shorts", coins: 15000, icon: AppConstants.getPngAsset('football-shorts')),
  GiftModel(name: "Football", coins: 25000, icon: AppConstants.getPngAsset('football')),
  GiftModel(name: "Gloves", coins: 40000, icon: AppConstants.getPngAsset('gloves')),
  GiftModel(name: "Boots", coins: 60000, icon: AppConstants.getPngAsset('boots')),

  // --- TIER 4: Infrastructure (World Class) ---
  GiftModel(name: "Football Jersey", coins: 100000, icon: AppConstants.getPngAsset('football-jersey')),
  GiftModel(name: "Kit Bag", coins: 150000, icon: AppConstants.getPngAsset('kit-bag')),
  GiftModel(name: "Goal Post", coins: 250000, icon: AppConstants.getPngAsset('goal-post')),

  // --- TIER 5: Legend Status (The "Flex" Items) ---
  GiftModel(name: "Contract", coins: 500000, icon: AppConstants.getPngAsset('contract')),
  GiftModel(name: "Endorsement", coins: 1000000, icon: AppConstants.getPngAsset('endorsement')),
];

