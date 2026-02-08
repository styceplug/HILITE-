import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/competition_controller.dart';
import 'package:iconsax/iconsax.dart';

import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class CreateCompetitionScreen extends StatelessWidget {
  const CreateCompetitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    CompetitionController controller = Get.find<CompetitionController>();

    return Scaffold(
      appBar: CustomAppbar(
        title: "New Competition",
        leadingIcon: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.width20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 1. Banner Image Picker
            GetBuilder<CompetitionController>(
              builder: (ctrl) {
                return GestureDetector(
                  onTap: ctrl.pickBannerImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      image: ctrl.bannerImage != null
                          ? DecorationImage(
                        image: FileImage(File(ctrl.bannerImage!.path)),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: ctrl.bannerImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 40, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text("Upload Banner (Optional)",
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    )
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // 2. Basic Info
            const SectionLabel(text: "Details"),
            CustomTextField(
              controller: controller.nameController,
              hintText: "Competition Name",
              prefixIcon: Icons.emoji_events_outlined,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: controller.locationController,
              hintText: "Location (Stadium/City)",
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 15),

            // 3. Date Picker
            GetBuilder<CompetitionController>(
              builder: (ctrl) {
                return GestureDetector(
                  onTap: () => ctrl.pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text(
                          ctrl.selectedDate == null
                              ? "Select Start Date"
                              : "${ctrl.selectedDate!.day}/${ctrl.selectedDate!.month}/${ctrl.selectedDate!.year}",
                          style: TextStyle(
                            color: ctrl.selectedDate == null
                                ? Colors.grey
                                : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            // 4. Numbers (Fee, Prize, Teams)
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.clubsNeededController,
                    hintText: "Clubs Needed (e.g 16)",
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                IntrinsicWidth(
                  child: CustomTextField(
                    controller: controller.feeController,
                    hintText: "Reg. Fee",
                    keyboardType: TextInputType.number,
                    prefixIcon: Iconsax.money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: controller.prizeController,
              hintText: "Prize Money",
              keyboardType: TextInputType.number,
              prefixIcon: Icons.emoji_events,
            ),
            const SizedBox(height: 15),

            // 5. Description
            CustomTextField(
              controller: controller.descriptionController,
              hintText: "Description (Rules, details...)",
              maxLines: 4,
            ),
            const SizedBox(height: 30),

            CustomButton(
              text: "Create Competition",
              onPressed: controller.createCompetition,
            )
          ],
        ),
      ),
    );
  }
}

// Simple Helper for Labels
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}