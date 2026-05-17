import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hilite/helpers/global_loader_controller.dart';
import 'package:image_picker/image_picker.dart';

import '../data/repo/trial_repo.dart';
import '../models/trial_model.dart';
import '../widgets/snackbars.dart';

class TrialController extends GetxController {
  final TrialRepo trialRepo;

  TrialController({required this.trialRepo});

  RxList<TrialModel> trialList = <TrialModel>[].obs;
  RxBool isLoadingTrials = false.obs;
  GlobalLoaderController loaderController = Get.find<GlobalLoaderController>();
  RxList<TrialModel> myTrials = <TrialModel>[].obs;
  var joinedTrialList = <TrialModel>[].obs;
  RxBool isProcessing = false.obs;
  Rx<TrialModel?> currentTrialDetails = Rx<TrialModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchTrials();
  }


  Future<void> fetchJoinedTrials() async {
    isLoadingTrials.value = true;
    try {
      Response response = await trialRepo.getRegisteredTrials();
      if (response.statusCode == 200 && response.body['code'] == '00') {
        List<dynamic> rawList = response.body['data'] ?? [];
        joinedTrialList.value = rawList.map((e) => TrialModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching joined trials: $e");
    } finally {
      isLoadingTrials.value = false;
    }
  }

  Future<void> getMyTrials() async {
    try {
      loader.showLoader();

      Response response = await trialRepo.getMyTrials();

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body['code'] == '00') {
        final List data = response.body['data'] ?? [];
        myTrials.assignAll(data.map((e) => TrialModel.fromJson(e)).toList());
      } else {
        CustomSnackBar.failure(
          message: response.body?['message'] ?? 'Failed to fetch trials',
        );
      }
    } catch (e, s) {
      print('getMyTrials error: $e');
      print(s);
      CustomSnackBar.failure(message: 'Something went wrong');
    } finally {
      loader.hideLoader();
      update();
    }
  }

  Future<void> fetchTrials() async {
    isLoadingTrials.value = true;
    try {
      final response = await trialRepo.getAllTrials();
      if (response.statusCode == 200 && response.body['data'] is List) {
        final List<TrialModel> fetchedTrials = List<TrialModel>.from(
          response.body['data'].map((i) => TrialModel.fromJson(i)),
        );
        trialList.assignAll(fetchedTrials);
      } else {
        CustomSnackBar.failure(
          message: 'Failed to load trials, please try again',
        );
      }
    } catch (e) {
      print('Error fetching trials: $e');
    } finally {
      isLoadingTrials.value = false;
    }
  }

  Future<void> fetchTrialDetails(String trialId) async {
    if (trialId.isEmpty) return; // Guard clause

    currentTrialDetails.value = null;
    isProcessing.value = true;

    try {
      final response = await trialRepo.getTrialDetails(trialId);

      if (response.statusCode == 200) {
        var data = response.body['data'];

        // FIX: Handle if server returns a List instead of Map (Edge case)
        if (data is Map<String, dynamic>) {
          currentTrialDetails.value = TrialModel.fromJson(data);
        } else if (data is List && data.isNotEmpty) {
          currentTrialDetails.value = TrialModel.fromJson(data[0]);
        } else {
          CustomSnackBar.failure(message: 'Invalid data format from server');
        }
      } else {
        CustomSnackBar.failure(message: 'Failed to load trial details');
      }
    } catch (e) {
      print('Error fetching trial details: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<bool> createTrial({
    required String name,
    required String location,
    required DateTime date,
    required String ageGroup,
    required double registrationFee,
    required String type,
    String? description,
    XFile? banner,
  }) async {
    isProcessing.value = true;
    try {
      final response = await trialRepo.createNewTrial(
        name: name,
        location: location,
        date: date,
        ageGroup: ageGroup,
        registrationFee: registrationFee,
        type: type,
        description: description,
        banner: banner,
      );

      if (response.statusCode == 201) {
        CustomSnackBar.success(message: 'Trial created successfully!');
        fetchTrials(); // Refresh list
        return true;
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Failed to create trial.',
        );
        return false;
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Network error.');
      print(e);
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> registerForTrial(String trialId) async {
    isProcessing.value = true;
    try {
      final response = await trialRepo.registerForTrial(trialId);
      if (response.statusCode == 200) {
        CustomSnackBar.success(message: 'Registered for trial!');
        fetchTrialDetails(trialId);
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Registration failed.',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Network error.');
      print(e);
    } finally {
      isProcessing.value = false;
    }
  }
}
