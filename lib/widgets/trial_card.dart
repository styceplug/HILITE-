import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/models/trial_model.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class TrialCard extends StatelessWidget {
  final TrialModel trial;
  final VoidCallback onTap;

  const TrialCard({required this.trial, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d, yyyy');
    final int registeredCount = trial.registeredCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        decoration: BoxDecoration(
          color: Color(0XFF09142E),
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: Dimensions.height70,
              width: Dimensions.width70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(trial.creator?.profilePicture ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: Dimensions.width15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trial.name,
                    style: TextStyle(
                      fontSize: Dimensions.font18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        color: Colors.white,
                        size: Dimensions.iconSize20 * 0.7,
                      ),
                      SizedBox(width: Dimensions.width5),
                      Text(
                        trial.location,
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.calendar,
                                color: Colors.white,
                                size: Dimensions.iconSize20 * 0.7,
                              ),
                              SizedBox(width: Dimensions.width5),
                              Text(
                                dateFormatter.format(trial.date),
                                style: TextStyle(
                                  fontSize: Dimensions.font14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.width10,
                                ),
                                child: Icon(
                                  Icons.circle,
                                  size: Dimensions.iconSize16 * 0.5,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Icon(
                                Icons.person,
                                color: Colors.white,
                                size: Dimensions.iconSize20 * 0.7,
                              ),
                              SizedBox(width: Dimensions.width5),
                              Text(
                                trial.ageGroup.capitalizeFirst ?? '',
                                style: TextStyle(
                                  fontSize: Dimensions.font14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Iconsax.bubble,
                                color: Colors.white,
                                size: Dimensions.iconSize20 * 0.7,
                              ),
                              SizedBox(width: Dimensions.width5),
                              Text(
                                trial.type.capitalizeFirst ?? '',
                                style: TextStyle(
                                  fontSize: Dimensions.font14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.width10,
                                ),
                                child: Icon(
                                  Icons.circle,
                                  size: Dimensions.iconSize16 * 0.5,
                                  color: AppColors.textColor,
                                ),
                              ),
                              Text(
                                '$registeredCount Going',
                                style: TextStyle(
                                  fontSize: Dimensions.font14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      CustomButton(
                        onPressed: () {},
                        text: 'JOIN',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: Dimensions.font13,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10*1.2,
                          vertical: Dimensions.height10,
                        ),
                        backgroundColor: AppColors.buttonColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
