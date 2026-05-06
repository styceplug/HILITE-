import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/empty_state_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../controllers/chat_controller.dart';
import '../../../controllers/competition_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../controllers/trial_controller.dart';
import '../../../data/repo/competition_repo.dart';
import '../../../models/message_model.dart';
import '../../../models/notification_model.dart';
import '../../../widgets/competition_card.dart';
import '../../../widgets/trial_card.dart';
import '../../others/competition_details_screen.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with AutomaticKeepAliveClientMixin<ActivitiesScreen> {
  @override
  bool get wantKeepAlive => true;

  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Trials', 'Competitions', 'Joined'];

  late UserController userController;
  late TrialController trialController;
  late CompetitionController compController;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();

    trialController = Get.put(TrialController(trialRepo: Get.find()));
    compController = Get.put(
      CompetitionController(
        competitionRepo: Get.put(CompetitionRepo(apiClient: Get.find())),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      trialController.fetchTrials();
      compController.getCompetitions();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool isClub = userController.user.value?.role == 'club';

    return Scaffold(
      appBar: CustomAppbar(
        customTitle: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Activities',
            style: TextStyle(
              fontSize: Dimensions.font20,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actionIcon: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width10,
            vertical: Dimensions.height10,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white.withOpacity(0.1),
          ),
          child: Icon(
            CupertinoIcons.add,
            size: Dimensions.iconSize24,
            color: AppColors.white,
          ),
        ),
        centerTitle: false,
      ),

      /* // --- UNIFIED FAB FOR CLUBS ---
      floatingActionButton: isClub
          ? FloatingActionButton(
        onPressed: _showCreateBottomSheet,
        backgroundColor: AppColors.buttonColor,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      )
          : null,*/
      body: Column(
        children: [
          _buildCustomTabBar(),
          Expanded(child: _buildSelectedTabContent()),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      width: Dimensions.screenWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF030A1B),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_tabs.length, (index) {
          bool isSelected = _selectedTabIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height15,
                    ),
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        fontSize: Dimensions.font14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: isSelected ? Dimensions.width40 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedTabContent() {
    return RefreshIndicator(
      color: AppColors.buttonColor,
      backgroundColor: const Color(0xFF1F2937),
      onRefresh: () async {
        await trialController.fetchTrials();
        await compController.getCompetitions();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(Dimensions.width20),
        child: Builder(
          builder: (context) {
            if (_selectedTabIndex == 0) return _buildAllTab();
            if (_selectedTabIndex == 1) return _buildTrialsTab();
            if (_selectedTabIndex == 2) return _buildCompetitionsTab();
            if (_selectedTabIndex == 3) return _buildJoinedTab();
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: Dimensions.height20),
            child: Row(
              children: [
                Container(
                  height: Dimensions.height10 * 6,
                  width: Dimensions.width10 * 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(width: Dimensions.width15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: Dimensions.screenWidth * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: Dimensions.screenWidth * 0.7,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllTab() {
    return GetBuilder<CompetitionController>(
      builder: (compCtrl) {
        return Obx(() {
          final isLoading = trialController.isLoadingTrials.value;

          if (isLoading) {
            return Column(
              children: [
                SizedBox(height: Dimensions.height30),
                _buildSkeletonList(),
              ],
            );
          }

          final trials = trialController.trialList.take(2).toList();
          final comps = compCtrl.competitionList.take(2).toList();

          if (trials.isEmpty && comps.isEmpty) {
            return _buildEmptyState(
              icon: CupertinoIcons.doc_text_search,
              title: "No activities right now",
              subtitle: "Check back later for new trials and competitions.",
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AD PLACEMENT
              Container(
                height: Dimensions.height10*17,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  image: DecorationImage(
                    image: AssetImage(AppConstants.getPngAsset('advert')),
                    fit: BoxFit.fitWidth
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height30),

              // FEATURED TRIALS
              if (trials.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Open Trials",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Text(
                        "See All",
                        style: TextStyle(
                          color: AppColors.buttonColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height15),
                ...trials.map(
                  (trial) => Padding(
                    padding: EdgeInsets.only(bottom: Dimensions.height15),
                    child: TrialCard(
                      trial: trial,
                      onTap: () {
                        if (trial.id.isNotEmpty)
                          Get.toNamed(
                            AppRoutes.trialDetailScreen,
                            arguments: trial.id,
                          );
                      },
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height15),
              ],

              // FEATURED COMPETITIONS
              if (comps.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Latest Competitions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 2),
                      child: Text(
                        "See All",
                        style: TextStyle(
                          color: AppColors.buttonColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height15),
                ...comps.map(
                  (comp) => Padding(
                    padding: EdgeInsets.only(bottom: Dimensions.height15),
                    child: CompetitionCard(
                      competition: comp,
                      onTap: () {
                        if (comp.sId != null && comp.sId!.isNotEmpty) {
                          Get.to(
                            () => CompetitionDetailsScreen(
                              competitionId: comp.sId!,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ],
          );
        });
      },
    );
  }

  // --- 2. TRIALS TAB ---
  Widget _buildTrialsTab() {
    return Obx(() {
      if (trialController.isLoadingTrials.value) {
        return _buildSkeletonList(); // --- CALLED SKELETONIZER HERE ---
      }

      if (trialController.trialList.isEmpty) {
        return _buildEmptyState(
          icon: Icons.sports_soccer,
          title: "No trials active right now",
          subtitle: "Pull down to refresh and check for new opportunities.",
        );
      }

      return Column(
        children:
            trialController.trialList
                .map(
                  (trial) => Padding(
                    padding: EdgeInsets.only(bottom: Dimensions.height15),
                    child: TrialCard(
                      trial: trial,
                      onTap: () {
                        if (trial.id.isNotEmpty)
                          Get.toNamed(
                            AppRoutes.trialDetailScreen,
                            arguments: trial.id,
                          );
                      },
                    ),
                  ),
                )
                .toList(),
      );
    });
  }

  // --- 3. COMPETITIONS TAB ---
  Widget _buildCompetitionsTab() {
    return GetBuilder<CompetitionController>(
      builder: (compCtrl) {
        // If you add an isLoading flag to CompetitionController later, you can add the skeleton here too!
        if (compCtrl.competitionList.isEmpty) {
          return _buildEmptyState(
            icon: Icons.emoji_events_outlined,
            title: "No Competitions yet",
            subtitle: "Competitions hosted by clubs will appear here.",
          );
        }

        return Column(
          children:
              compCtrl.competitionList
                  .map(
                    (comp) => Padding(
                      padding: EdgeInsets.only(bottom: Dimensions.height15),
                      child: CompetitionCard(
                        competition: comp,
                        onTap: () {
                          if (comp.sId != null && comp.sId!.isNotEmpty) {
                            Get.to(
                              () => CompetitionDetailsScreen(
                                competitionId: comp.sId!,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }

  // --- 4. JOINED TAB ---
  Widget _buildJoinedTab() {
    bool hasJoinedActivities = false;

    if (!hasJoinedActivities) {
      return _buildEmptyState(
        icon: CupertinoIcons.checkmark_seal,
        title: "No joined activities",
        subtitle:
            "Trials or competitions you participate in will show up here.",
      );
    }

    return const Center(
      child: Text(
        "Your joined activities list...",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // --- HELPER: EMPTY STATE ---
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: Dimensions.height50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 70, color: Colors.white.withOpacity(0.1)),
            SizedBox(height: Dimensions.height20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER: FAB BOTTOM SHEET ---
  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: EdgeInsets.all(Dimensions.width20),
                  child: const Text(
                    "Create Activity",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.sports_soccer, color: AppColors.warning),
                  ),
                  title: const Text(
                    'Create a Trial',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.createTrialScreen);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.emoji_events, color: AppColors.success),
                  ),
                  title: const Text(
                    'Create a Competition',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoutes.createCompetitionScreen);
                  },
                ),
                SizedBox(height: Dimensions.height20),
              ],
            ),
          ),
    );
  }
}
