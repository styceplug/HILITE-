import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/competition_model.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';

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
    String formattedDate = competition.date != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.parse(competition.date!))
        : "Date TBA";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.height15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius15)),
              child: Container(
                height: Dimensions.height150,
                width: double.infinity,
                color: Colors.grey[200], // Placeholder color
                child: competition.banner != null && competition.banner!.isNotEmpty
                    ? Image.network(
                  competition.banner!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, color: Colors.grey);
                  },
                )
                    : Icon(Icons.sports_soccer, size: 50, color: Colors.grey),
              ),
            ),

            // Details Section
            Padding(
              padding: EdgeInsets.all(Dimensions.width15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          competition.name ?? "Unknown Competition",
                          style: TextStyle(
                            fontSize: Dimensions.font16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "\$${competition.prize ?? 0} Prize",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.font12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),

                  // Location Row
                  Row(
                    children: [
                      Icon(Icons.location_on, size: Dimensions.iconSize16, color: AppColors.grey2),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          competition.location ?? "No location",
                          style: TextStyle(color: AppColors.grey2, fontSize: Dimensions.font12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),

                  // Date Row
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: Dimensions.iconSize16, color: AppColors.grey2),
                      SizedBox(width: 5),
                      Text(
                        formattedDate,
                        style: TextStyle(color: AppColors.grey2, fontSize: Dimensions.font12),
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