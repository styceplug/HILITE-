import 'package:flutter/material.dart';

class GiftModel {
  final String name;
  final int coins;
  final IconData icon;
  final Color color;

  GiftModel({
    required this.name,
    required this.coins,
    required this.icon,
    this.color = Colors.white,
  });
}

final List<GiftModel> giftList = [

  GiftModel(name: "Energy Drink", coins: 10, icon: Icons.local_drink, color: Colors.green),
  GiftModel(name: "Ice Pack", coins: 50, icon: Icons.ac_unit, color: Colors.lightBlue),
  GiftModel(name: "Socks Pack", coins: 80, icon: Icons.checkroom, color: Colors.pink),
  GiftModel(name: "Football", coins: 100, icon: Icons.sports_soccer, color: Colors.orange),


  GiftModel(name: "Muscle Rub", coins: 150, icon: Icons.fitness_center, color: Colors.redAccent),
  GiftModel(name: "Gloves", coins: 200, icon: Icons.sports_handball, color: Colors.purple),
  GiftModel(name: "Jersey", coins: 300, icon: Icons.theater_comedy, color: Colors.lightGreen),
  GiftModel(name: "Training Vest", coins: 400, icon: Icons.directions_run, color: Colors.yellow),


  GiftModel(name: "Boots", coins: 500, icon: Icons.hiking, color: Colors.brown),
  GiftModel(name: "Gear Bag", coins: 600, icon: Icons.backpack, color: Colors.indigo),
  GiftModel(name: "Training Kit", coins: 700, icon: Icons.sports_gymnastics, color: Colors.teal),
  GiftModel(name: "Club Cap", coins: 800, icon: Icons.auto_delete, color: Colors.deepPurple),


  GiftModel(name: "Goal Net", coins: 1000, icon: Icons.golf_course, color: Colors.red),
  GiftModel(name: "Recovery Pack", coins: 1200, icon: Icons.medication, color: Colors.blue),
  GiftModel(name: "Endorsement Push", coins: 1500, icon: Icons.thumb_up, color: Colors.amber),
  GiftModel(name: "Trophy", coins: 2000, icon: Icons.emoji_events, color: Colors.yellowAccent),
];