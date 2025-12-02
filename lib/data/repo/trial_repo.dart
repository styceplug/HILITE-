import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../utils/app_constants.dart';
import '../api/api_client.dart';


class TrialRepo extends GetxService {
  final ApiClient apiClient;

  TrialRepo({required this.apiClient});


  Future<Response> getAllTrials() async {
    return await apiClient.getData(AppConstants.GET_TRIALS);
  }


  Future<Response> getTrialDetails(String trialId) async {
    return await apiClient.getData(AppConstants.GET_SINGLE_TRIALS(trialId));
  }


  Future<Response> createNewTrial({
    required String name,
    required String location,
    required DateTime date,
    required String ageGroup,
    required double registrationFee,
    required String type,
    String? description,
    XFile? banner,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('${AppConstants.BASE_URL}${AppConstants
        .POST_TRIAL}'));


    request.fields.addAll({
      'name': name,
      'location': location,
      'date': date.toIso8601String(),
      'ageGroup': ageGroup,
      'registrationFee': registrationFee.toString(),
      'type': type,
      'description': description ?? '',
    });


    if (banner != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'banner', 
          await banner.readAsBytes(),
          filename: banner.name,
        ),
      );
    }


    return await apiClient.postMultipartData(
      AppConstants.POST_TRIAL, 
      request,
    );
  }


  Future<Response> editTrial(String trialId, Map<String, dynamic> data) async {
    return await apiClient.putData(
      AppConstants.EDIT_TRIALS(trialId),
      data,
    );
  }


  Future<Response> deleteTrial(String trialId) async {
    return await apiClient.deleteData(AppConstants.DELETE_TRIALS(trialId));
  }


  Future<Response> registerForTrial(String trialId) async {
    return await apiClient.postData(
      AppConstants.REGISTER_FOR_TRIALS(trialId),
      {},
    );
  }
}