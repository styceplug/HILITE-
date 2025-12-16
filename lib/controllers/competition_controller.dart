import 'package:flutter/material.dart';
import 'package:hilite/data/repo/competition_repo.dart';
import 'package:get/get.dart';
import 'package:hilite/helpers/global_loader_controller.dart';

import '../models/competition_model.dart';

class CompetitionController extends GetxController {
  final CompetitionRepo competitionRepo;

  CompetitionController({required this.competitionRepo});

  List<CompetitionModel> _competitionList = [];
  List<CompetitionModel> get competitionList => _competitionList;
  CompetitionModel? _competitionDetail;
  CompetitionModel? get competitionDetail => _competitionDetail;
  GlobalLoaderController loader = Get.find<GlobalLoaderController>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCompetitions();
    });
  }

  Future<void> getCompetitions() async {
    loader.showLoader();
    update();

    Response response = await competitionRepo.getCompetition();

    if (response.statusCode == 200) {
      _competitionList = [];
      List<dynamic> data = response.body['data'];
      _competitionList.addAll(data.map((e) => CompetitionModel.fromJson(e)));
      loader.hideLoader();
      update();
    } else {
      print(response.body);
      loader.hideLoader();
      update();
      Get.snackbar(
        "Error",
        response.statusText ?? "Failed to load competitions",
      );
    }
  }

  Future<void> getCompetitionDetails(String competitionId) async {
    loader.showLoader();
    _competitionDetail = null;
    update();

    Response response = await competitionRepo.getCompetitionDetails(competitionId);

    if (response.statusCode == 200) {
      _competitionDetail = CompetitionModel.fromJson(response.body['data']);
    } else {
      Get.snackbar("Error", response.statusText ?? "Failed to load details");
    }

    loader.hideLoader();
    update();
  }
}
