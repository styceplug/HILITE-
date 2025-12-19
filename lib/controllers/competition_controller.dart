import 'package:flutter/material.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/data/repo/competition_repo.dart';
import 'package:get/get.dart';
import 'package:hilite/helpers/global_loader_controller.dart';

import '../models/competition_model.dart';
import '../widgets/snackbars.dart';


class CompetitionController extends GetxController {
  final CompetitionRepo competitionRepo;
  CompetitionController({required this.competitionRepo});

  // Data Lists
  List<CompetitionModel> _competitionList = [];
  List<CompetitionModel> get competitionList => _competitionList;

  CompetitionModel? _competitionDetail;
  CompetitionModel? get competitionDetail => _competitionDetail;

  // Loaders
  GlobalLoaderController loader = Get.find<GlobalLoaderController>();

  // ✅ FIX: Add this boolean so the UI button can spin
  bool _isRegistering = false;
  bool get isRegistering => _isRegistering;

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
    } else {
      Get.snackbar("Error", response.statusText ?? "Failed to load competitions");
    }
    loader.hideLoader();
    update();
  }

  Future<void> getCompetitionDetails(String competitionId) async {
    // loader.showLoader(); // Optional: Don't block screen if you want smooth UI
    _competitionDetail = null;
    update();

    Response response = await competitionRepo.getCompetitionDetails(competitionId);

    if (response.statusCode == 200) {
      _competitionDetail = CompetitionModel.fromJson(response.body['data']);
    } else {
      Get.snackbar("Error", response.statusText ?? "Failed to load details");
    }
    // loader.hideLoader();
    update();
  }

  Future<void> registerForCompetition(String competitionId) async {
    // ✅ FIX: Move user check inside the method
    String role = Get.find<UserController>().user.value?.role ?? "";

    if (role != 'club') {
      CustomSnackBar.failure(message: "Only Clubs can register for competitions");
      return;
    }

    // ✅ FIX: Use local loading state for the button
    _isRegistering = true;
    update();

    try {
      Response response = await competitionRepo.registerForCompetition(competitionId);

      if (response.statusCode == 200 && response.body['code'] == '00') {
        CustomSnackBar.success(message: "Club registered successfully!");

        // Refresh details
        getCompetitionDetails(competitionId);
      } else {
        CustomSnackBar.failure(message: response.body['message'] ?? "Registration failed");
      }
    } catch (e) {
      print("Error registering: $e");
      CustomSnackBar.failure(message: "An error occurred");
    } finally {
      // ✅ FIX: Reset local loading state
      _isRegistering = false;
      update();
    }
  }
}
