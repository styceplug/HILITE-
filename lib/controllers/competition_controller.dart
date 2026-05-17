import 'package:flutter/material.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/data/repo/competition_repo.dart';
import 'package:get/get.dart';
import 'package:hilite/helpers/global_loader_controller.dart';
import 'package:image_picker/image_picker.dart';

import '../data/api/api_checker.dart';
import '../models/competition_model.dart';
import '../widgets/snackbars.dart';

class CompetitionController extends GetxController {
  final CompetitionRepo competitionRepo;

  CompetitionController({required this.competitionRepo});

  //Text Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController clubsNeededController = TextEditingController();
  TextEditingController feeController = TextEditingController();
  TextEditingController prizeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Data Lists
  List<CompetitionModel> _competitionList = [];

  List<CompetitionModel> get competitionList => _competitionList;

  CompetitionModel? _competitionDetail;

  CompetitionModel? get competitionDetail => _competitionDetail;

  // Loaders
  GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  DateTime? selectedDate;
  XFile? bannerImage;
  bool isLoading = false;
  List<CompetitionModel> joinedCompetitionList = [];
  RxList<CompetitionModel> myCompetitions = <CompetitionModel>[].obs;
  bool _isRegistering = false;

  bool get isRegistering => _isRegistering;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCompetitions();
    });
  }




  Future<void> fetchJoinedCompetitions() async {
    isLoading = true;
    update();

    try {
      Response response = await competitionRepo.getRegisteredCompetition();
      if (response.statusCode == 200 && response.body['code'] == '00') {
        List<dynamic> rawList = response.body['data'] ?? [];
        joinedCompetitionList = rawList.map((e) => CompetitionModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching joined competitions: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getMyCompetitions() async {
    try {
      loader.showLoader();

      Response response = await competitionRepo.getMyCompetition();

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body['code'] == '00') {
        final List data = response.body['data'] ?? [];
        myCompetitions.assignAll(
          data.map((e) => CompetitionModel.fromJson(e)).toList(),
        );
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to fetch competitions',
        );
      }
    } catch (e, s) {
      print('getMyCompetitions error: $e');
      print(s);
      CustomSnackBar.failure(message: 'Something went wrong');
    } finally {
      loader.hideLoader();
      update();
    }
  }


  Future<void> createCompetition() async {

    if (nameController.text.isEmpty ||
        locationController.text.isEmpty ||
        clubsNeededController.text.isEmpty ||
        feeController.text.isEmpty ||
        prizeController.text.isEmpty ||
        selectedDate == null) {
      CustomSnackBar.failure(message: "Please fill all required fields");
      return;
    }

    loader.showLoader();
    update();

    try {
      Response response = await competitionRepo.createCompetition(
        name: nameController.text.trim(),
        location: locationController.text.trim(),
        date: selectedDate!.toIso8601String(),
        clubsNeeded: clubsNeededController.text.trim(),
        registrationFee: feeController.text.trim(), // Server expects number, sending string usually works if backend parses, else parse to int here
        prize: prizeController.text.trim(),
        description: descriptionController.text.trim(),
        bannerImage: bannerImage,
      );

      if (response.statusCode == 201) {
        CustomSnackBar.success(message: "Competition created successfully!");
        Get.back();
        _clearForm();
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      print("Create Competition Error: $e");
      CustomSnackBar.failure(message: "An error occurred");
    } finally {
      loader.hideLoader();
      update();
    }
  }

  void _clearForm() {
    nameController.clear();
    locationController.clear();
    clubsNeededController.clear();
    feeController.clear();
    prizeController.clear();
    descriptionController.clear();
    selectedDate = null;
    bannerImage = null;
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      update();
    }
  }

  Future<void> pickBannerImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      bannerImage = image;
      update();
    }
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
      Get.snackbar(
        "Error",
        response.statusText ?? "Failed to load competitions",
      );
    }
    loader.hideLoader();
    update();
  }

  Future<void> getCompetitionDetails(String competitionId) async {
    // loader.showLoader(); // Optional: Don't block screen if you want smooth UI
    _competitionDetail = null;
    update();

    Response response = await competitionRepo.getCompetitionDetails(
      competitionId,
    );

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
      CustomSnackBar.failure(
        message: "Only Clubs can register for competitions",
      );
      return;
    }

    // ✅ FIX: Use local loading state for the button
    _isRegistering = true;
    update();

    try {
      Response response = await competitionRepo.registerForCompetition(
        competitionId,
      );

      if (response.statusCode == 200 && response.body['code'] == '00') {
        CustomSnackBar.success(message: "Club registered successfully!");

        // Refresh details
        getCompetitionDetails(competitionId);
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? "Registration failed",
        );
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
