import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:hilite/data/api/api_client.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/app_constants.dart';

class CompetitionRepo {
  final ApiClient apiClient;

  CompetitionRepo({required this.apiClient});


  Future<Response> createCompetition({
    required String name,
    required String location,
    required String date,
    required String clubsNeeded,
    required String registrationFee,
    required String prize,
    required String description,
    XFile? bannerImage,
  }) async {


    FormData body = FormData({
      'name': name,
      'location': location,
      'date': date,
      'clubsNeeded': clubsNeeded,
      'registrationFee': registrationFee,
      'prize': prize,
      'description': description,

      // Handle the file conditionally
      if (bannerImage != null)
        'banner': MultipartFile(bannerImage.path, filename: 'banner.jpg'),
    });

    return await apiClient.postData(
      AppConstants.CREATE_COMPETITION,
      body,
    );
  }

  Future<Response> getCompetition() async {
    return await apiClient.getData(AppConstants.GET_COMPETITION);
  }

  Future<Response> getCompetitionDetails(String competitionId) async {
    return await apiClient.getData(
      AppConstants.GET_COMPETITION_DETAILS(competitionId),
    );
  }

  Future<Response> registerForCompetition(String competitionId) async {
    return await apiClient.postData(
      '/v1/competition/$competitionId/register',
      {},
    );
  }
}
