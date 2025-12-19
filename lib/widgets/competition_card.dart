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
    // Format Date safely
    String formattedDate = "Date TBA";
    if (competition.date != null) {
      try {
        DateTime dt = DateTime.parse(competition.date!);
        formattedDate = DateFormat('MMM d, yyyy').format(dt);
      } catch (e) {
        // Fallback if parsing fails
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Dimensions.height20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. IMAGE & BADGES SECTION
            Stack(
              children: [
                // Banner Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: competition.banner != null && competition.banner!.isNotEmpty
                        ? Image.network(
                      competition.banner!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey[100],
                        child: Icon(Icons.emoji_events_outlined, color: Colors.grey[300], size: 50),
                      ),
                    )
                        : Container(
                      color: Colors.grey[100],
                      child: Icon(Icons.emoji_events_outlined, color: Colors.grey[300], size: 50),
                    ),
                  ),
                ),

                // Badge: Prize Pool (Gold/Premium Look)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.amber, // Gold for prizes
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                        ]
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Prize: \$${NumberFormat.compact().format(competition.prize ?? 0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Badge: Entry Fee (Blue/Info Look)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      competition.registrationFee == 0
                          ? "FREE ENTRY"
                          : "Fee: \$${competition.registrationFee}",
                      style: const TextStyle(
                        color: Colors.blue, // Or your AppColors.primary
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. DETAILS SECTION
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    competition.name ?? "Untitled Competition",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Metadata Rows (Location & Date)
                  Row(
                    children: [
                      _buildMetaInfo(Icons.location_on_outlined, competition.location ?? "TBA"),
                      const SizedBox(width: 15),
                      _buildMetaInfo(Icons.calendar_today_outlined, formattedDate),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Footer: Teams Status
                  Row(
                    children: [
                      Icon(Icons.groups_outlined, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        // Simple logic to show "X spots left" or just total needed
                        "${competition.clubsNeeded ?? '0'} Teams Required",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),

                      // Small "View" Arrow
                      const Text(
                        "View Details",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 14, color: Colors.blue),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaInfo(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[400]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}