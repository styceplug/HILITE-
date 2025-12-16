import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/empty_state_widget.dart';

import '../../controllers/competition_controller.dart';
import '../../data/repo/competition_repo.dart';
import '../../utils/dimensions.dart';
import '../../widgets/competition_card.dart';
import 'competition_details_screen.dart';

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Competitions', leadingIcon: BackButton()),
      body: GetBuilder<CompetitionController>(
        init: CompetitionController(
          competitionRepo: Get.put(CompetitionRepo(apiClient: Get.find())),
        ),
        builder: (controller) {
          return ListView.builder(
            padding: EdgeInsets.all(Dimensions.width20),
            itemCount: controller.competitionList.length,
            itemBuilder: (context, index) {
              if (controller.competitionList.isEmpty) {
                return EmptyState(message: 'No Competitions yet');
              }
              return CompetitionCard(
                competition: controller.competitionList[index],
                onTap: () {
                  String compId = controller.competitionList[index].sId ?? "";

                  if (compId.isNotEmpty) {
                    Get.to(() => CompetitionDetailsScreen(competitionId: compId));
                  } else {
                    Get.snackbar("Error", "Competition ID not found");
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
