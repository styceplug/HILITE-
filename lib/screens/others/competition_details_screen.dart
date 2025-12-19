import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:intl/intl.dart';

import '../../controllers/competition_controller.dart';
import '../../models/competition_model.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class CompetitionDetailsScreen extends StatefulWidget {
  final String competitionId;

  const CompetitionDetailsScreen({Key? key, required this.competitionId})
    : super(key: key);

  @override
  State<CompetitionDetailsScreen> createState() =>
      _CompetitionDetailsScreenState();
}

class _CompetitionDetailsScreenState extends State<CompetitionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CompetitionController>().getCompetitionDetails(
        widget.competitionId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<CompetitionController>(
        builder: (controller) {
          var competition = controller.competitionDetail;

          if (competition == null) {
            return const Center(child: Text("Competition not found"));
          }

          // Format Date
          String formattedDate =
              competition.date != null
                  ? DateFormat(
                    'EEEE, MMM dd, yyyy',
                  ).format(DateTime.parse(competition.date!))
                  : "Date TBA";

          return CustomScrollView(
            slivers: [
              // 1. Sliver App Bar with Banner
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background:
                      competition.banner != null
                          ? Image.network(
                            competition.banner!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (c, o, s) => Container(color: Colors.grey),
                          )
                          : Container(
                            color: AppColors.primary,
                            child: Icon(
                              Icons.sports_soccer,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                ),
                leading: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: BackButton(color: Colors.black),
                ),
              ),

              // 2. Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.width20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        competition.name ?? "Unknown Competition",
                        style: TextStyle(
                          fontSize: Dimensions.font26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10),

                      // Host Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: 15,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Hosted by ${competition.creator?.name ?? 'Organizer'}",
                            style: TextStyle(
                              color: AppColors.grey4,
                              fontSize: Dimensions.font14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.height20),

                      // Key Stats Row (Prize & Fee)
                      Row(
                        children: [
                          _buildStatCard(
                            "Prize Pool",
                            "\$${competition.prize}",
                            Icons.emoji_events,
                            Colors.amber,
                          ),
                          SizedBox(width: Dimensions.width15),
                          _buildStatCard(
                            "Entry Fee",
                            "\$${competition.registrationFee}",
                            Icons.payments,
                            Colors.green,
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.height20),

                      // Info Section (Location & Date)
                      _buildInfoRow(
                        Icons.location_on,
                        competition.location ?? "No location",
                      ),
                      SizedBox(height: 10),
                      _buildInfoRow(Icons.calendar_month, formattedDate),
                      SizedBox(height: 10),
                      _buildInfoRow(
                        Icons.groups,
                        "${competition.clubsNeeded} Teams Needed",
                      ),

                      SizedBox(height: Dimensions.height20),
                      Divider(thickness: 1, color: Colors.grey[200]),
                      SizedBox(height: Dimensions.height20),

                      // Description
                      Text(
                        "About Competition",
                        style: TextStyle(
                          fontSize: Dimensions.font18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        competition.description ?? "No description available.",
                        style: TextStyle(color: AppColors.grey4, height: 1.5),
                      ),

                      SizedBox(height: Dimensions.height20),
                      Divider(thickness: 1, color: Colors.grey[200]),
                      SizedBox(height: Dimensions.height20),

                      // Registered Clubs Section
                      Text(
                        "Registered Teams (${competition.registered?.length ?? 0})",
                        style: TextStyle(
                          fontSize: Dimensions.font18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      if (competition.registered == null ||
                          competition.registered!.isEmpty)
                        Text(
                          "No teams registered yet. Be the first!",
                          style: TextStyle(color: AppColors.grey4),
                        ),

                      if (competition.registered != null)
                        ...competition.registered!.map((item) {
                          if (item is RegisteredClub) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                child: Text(
                                  item.name?[0] ?? "T",
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                              title: Text(item.name ?? "Unknown Team"),
                              subtitle: Text("@${item.username ?? ''}"),
                            );
                          }
                          return SizedBox.shrink();
                        }).toList(),

                      SizedBox(height: Dimensions.height40 * 3),
                      // Spacing for bottom button
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: GetBuilder<CompetitionController>(
        builder: (controller) {
          if (controller.competitionDetail == null) return SizedBox.shrink();

          return Container(
            height: Dimensions.height100*1.2,
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height30,
            ),
            child: CustomButton(
              padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
              text:
                  'Register Team (\$${controller.competitionDetail?.registrationFee})',
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.grey4),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
