import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../data/repo/trial_repo.dart';
import '../models/trial_model.dart';
import '../widgets/snackbars.dart';


class TrialController extends GetxController {
  final TrialRepo trialRepo;

  TrialController({required this.trialRepo});


  RxList<TrialModel> trialList = <TrialModel>[].obs;
  RxBool isLoadingTrials = false.obs;


  RxBool isProcessing = false.obs;
  Rx<TrialModel?> currentTrialDetails = Rx<TrialModel?>(null);


  @override
  void onInit() {
    super.onInit();
    fetchTrials();
  }



  Future<void> fetchTrials() async {
    isLoadingTrials.value = true;
    try {
      final response = await trialRepo.getAllTrials();
      if (response.statusCode == 200 && response.body['data'] is List) {
        final List<TrialModel> fetchedTrials = List<TrialModel>.from(
            response.body['data'].map((i) => TrialModel.fromJson(i))
        );
        trialList.assignAll(fetchedTrials);
      } else {
        CustomSnackBar.failure(message: 'Failed to load trials, please try again');
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
        name: name, location: location, date: date, ageGroup: ageGroup,
        registrationFee: registrationFee, type: type,
        description: description, banner: banner,
      );

      if (response.statusCode == 201) {
        CustomSnackBar.success(message: 'Trial created successfully!');
        fetchTrials(); // Refresh list
        return true;
      } else {
        CustomSnackBar.failure(message: response.body['message'] ?? 'Failed to create trial.');
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
        CustomSnackBar.failure(message: response.body['message'] ?? 'Registration failed.');
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Network error.');
      print(e);
    } finally {
      isProcessing.value = false;
    }
  }
}