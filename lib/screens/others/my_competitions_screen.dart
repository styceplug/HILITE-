import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/competition_controller.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';

class MyCompetitionsScreen extends StatefulWidget {
  const MyCompetitionsScreen({super.key});

  @override
  State<MyCompetitionsScreen> createState() => _MyCompetitionsScreenState();
}

class _MyCompetitionsScreenState extends State<MyCompetitionsScreen> {
  final CompetitionController competitionController =
  Get.find<CompetitionController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      competitionController.getMyCompetitions();
    });
  }

  String _fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${AppConstants.BASE_URL}$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppbar(
        title: 'My Competitions',
        leadingIcon: const BackButton(),
      ),
      body: Obx(() {


        if (competitionController.myCompetitions.isEmpty) {
          return const Center(child: Text('No competitions found'));
        }

        return ListView.separated(
          padding: EdgeInsets.all(Dimensions.width20),
          itemCount: competitionController.myCompetitions.length,
          separatorBuilder: (_, __) => SizedBox(height: Dimensions.height15),
          itemBuilder: (context, index) {
            final competition = competitionController.myCompetitions[index];

            return InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              onTap: () {
                Get.to(
                      () => CompetitionDetailsScreen(
                    competitionId: competition.sId ?? '',
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(Dimensions.width15),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radius15),
                      child: Image.network(
                        _fullImageUrl(competition.banner),
                        height: 80,
                        width: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 80,
                          width: 90,
                          color: AppColors.grey2,
                          child: const Icon(Icons.image_outlined),
                        ),
                      ),
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            competition.name ?? 'Untitled Competition',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: Dimensions.height5),
                          Text(
                            competition.location ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Dimensions.font13,
                              color: AppColors.grey5,
                            ),
                          ),
                          SizedBox(height: Dimensions.height5),
                          Text(
                            '${competition.clubsNeeded ?? '0'} Clubs Needed',
                            style: TextStyle(
                              fontSize: Dimensions.font12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: Dimensions.height5),
                          Text(
                            '₦${competition.registrationFee ?? 0}',
                            style: TextStyle(
                              fontSize: Dimensions.font13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class CompetitionDetailsScreen extends StatefulWidget {
  final String competitionId;

  const CompetitionDetailsScreen({
    super.key,
    required this.competitionId,
  });

  @override
  State<CompetitionDetailsScreen> createState() =>
      _CompetitionDetailsScreenState();
}

class _CompetitionDetailsScreenState extends State<CompetitionDetailsScreen> {
  final CompetitionController competitionController =
  Get.find<CompetitionController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      competitionController.getCompetitionDetails(widget.competitionId);
    });
  }

  String _fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${AppConstants.SOCKET_BASE_URL}$path';
  }

  Widget _infoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: AppColors.grey5)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppbar(
        title: 'Competition Details',
        leadingIcon: const BackButton(),
      ),
      body: GetBuilder<CompetitionController>(
        builder: (controller) {


          final competition = controller.competitionDetail;
          if (competition == null) {
            return const Center(child: Text('Unable to load competition details'));
          }

          final clubs = competition.registeredClubs;

          return SingleChildScrollView(
            padding: EdgeInsets.all(Dimensions.width20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    _fullImageUrl(competition.banner),
                    height: 220,
                    width: Dimensions.screenWidth,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      width: Dimensions.screenWidth,
                      color: AppColors.grey2,
                      child: const Icon(Icons.image_outlined, size: 40),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                Text(
                  competition.name ?? 'Untitled Competition',
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Dimensions.height10
),

                Text(
                  competition.creator?.clubName ??
                      competition.creator?.name ??
                      'Unknown Organizer',
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    color: AppColors.grey5,
                  ),
                ),

                SizedBox(height: Dimensions.height15),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.4,
                  children: [
                    _infoTile('Location', competition.location ?? '-'),
                    _infoTile(
                      'Date',
                      competition.date?.toLocal().toString().split(' ').first ??
                          '-',
                    ),
                    _infoTile('Clubs Needed', competition.clubsNeeded ?? '0'),
                    _infoTile(
                      'Registration Fee',
                      '₦${competition.registrationFee ?? 0}',
                    ),
                    _infoTile('Prize', '₦${competition.prize ?? 0}'),
                    _infoTile('Registered', '${competition.registeredCount}'),
                  ],
                ),

                SizedBox(height: Dimensions.height20),

                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Dimensions.height10
),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.grey2),
                  ),
                  child: Text(competition.description ?? 'No description'),
                ),

                SizedBox(height: Dimensions.height20),

                Text(
                  'Organizer',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Dimensions.height10
),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.grey2),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.grey2,
                        backgroundImage:
                        (competition.creator?.profilePicture != null &&
                            competition.creator!.profilePicture!.isNotEmpty)
                            ? NetworkImage(competition.creator!.profilePicture!)
                            : null,
                        child: (competition.creator?.profilePicture == null ||
                            competition.creator!.profilePicture!.isEmpty)
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              competition.creator?.clubName ??
                                  competition.creator?.name ??
                                  '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('@${competition.creator?.username ?? '-'}'),
                            if (competition.creator?.state != null)
                              Text(
                                '${competition.creator?.state}, ${competition.creator?.country ?? ''}',
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Dimensions.height20),

                Text(
                  'Registered Clubs',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: Dimensions.height10
),

                if (clubs.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.grey2),
                    ),
                    child: const Text('No registered clubs yet'),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: clubs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final club = clubs[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.grey2),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.grey2,
                              backgroundImage: (club.profilePicture != null &&
                                  club.profilePicture!.isNotEmpty)
                                  ? NetworkImage(club.profilePicture!)
                                  : null,
                              child: (club.profilePicture == null ||
                                  club.profilePicture!.isEmpty)
                                  ? const Icon(Icons.shield_outlined)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    club.clubName ?? club.name ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text('@${club.username ?? '-'}'),
                                ],
                              ),
                            ),
                            Text(club.role ?? 'club'),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}