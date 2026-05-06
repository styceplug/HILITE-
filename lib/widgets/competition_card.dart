import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../models/competition_model.dart';
import '../routes/routes.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';
import 'custom_button.dart';

class CompetitionCard extends StatelessWidget {
  final CompetitionModel competition;
  final VoidCallback onTap;

  const CompetitionCard({
    Key? key,
    required this.competition,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = "Date TBA";
    if (competition.date != null) {
      try {
        DateTime dt = DateTime.parse(competition.date.toString());
        formattedDate = DateFormat('MMM d, yyyy').format(dt);
      } catch (e) {
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        margin: EdgeInsets.only(bottom: Dimensions.height20),
        decoration: BoxDecoration(
          color: Color(0XFF09142E),

          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child:
        Row(
          children: [
            Container(
              height: Dimensions.height70,
              width: Dimensions.width70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(competition.creator?.profilePicture ?? ''),
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
                    competition.name ?? '',
                    overflow: TextOverflow.ellipsis,
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
                        competition.location ?? '',
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textColor,
                        ),
                      ),
                      Spacer(),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width5,
                        ),
                        child: Icon(
                          Icons.money,
                          size: Dimensions.iconSize16,
                          color: AppColors.textColor,
                        ),
                      ),
                      Text('₦${competition.registrationFee}',style: TextStyle(fontWeight: FontWeight.w700),)
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
                                formattedDate,
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
                                Iconsax.cup,
                                color: Colors.white,
                                size: Dimensions.iconSize20 * 0.7,
                              ),
                              SizedBox(width: Dimensions.width5),
                              Text(

                                '${competition.clubsNeeded} Teams',
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
                        onPressed: onTap,
                        text: 'View details',
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: Dimensions.font13,
                        ),
                        borderRadius: BorderRadius.circular(Dimensions.radius10),
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