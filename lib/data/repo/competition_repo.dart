import 'package:get/get_connect/http/src/response/response.dart';
import 'package:hilite/data/api/api_client.dart';

import '../../utils/app_constants.dart';

class CompetitionRepo {
  final ApiClient apiClient;

  CompetitionRepo({required this.apiClient});

  Future<Response> getCompetition() async {
    return await apiClient.getData(AppConstants.GET_COMPETITION);
  }

  Future<Response> getCompetitionDetails(String competitionId) async {
    return await apiClient.getData(
      AppConstants.GET_COMPETITION_DETAILS(competitionId),
    );
  }
}
