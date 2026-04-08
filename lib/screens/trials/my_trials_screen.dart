import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/trial_controller.dart';
import '../../controllers/user_controller.dart';
import '../../data/repo/chat_repo.dart';
import '../../models/message_model.dart';
import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/snackbars.dart';

class MyTrialsScreen extends StatefulWidget {
  const MyTrialsScreen({super.key});

  @override
  State<MyTrialsScreen> createState() => _MyTrialsScreenState();
}

class _MyTrialsScreenState extends State<MyTrialsScreen> {
  final TrialController trialController = Get.find<TrialController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      trialController.getMyTrials();
    });
  }

  String _fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${AppConstants.BASE_URL}$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppbar(title: 'My Trials', leadingIcon: const BackButton()),
      body: Obx(() {
        if (trialController.myTrials.isEmpty) {
          return const Center(child: Text('No trials found'));
        }

        return ListView.separated(
          padding: EdgeInsets.all(Dimensions.width20),
          itemCount: trialController.myTrials.length,
          separatorBuilder: (_, __) => SizedBox(height: Dimensions.height15),
          itemBuilder: (context, index) {
            final trial = trialController.myTrials[index];

            return InkWell(
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              onTap: () {
                Get.to(() => TrialDetailsScreen(trialId: trial.id));
              },
              child: Container(
                padding: EdgeInsets.all(Dimensions.width15),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                      child: Image.network(
                        _fullImageUrl(trial.banner),
                        height: 80,
                        width: 90,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              height: 80,
                              width: 90,
                              color: AppColors.grey2,
                              child: const Icon(Icons.image_outlined),
                            ),
                      ),
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trial.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: Dimensions.height5),
                          Text(
                            trial.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Dimensions.font13,
                              color: AppColors.grey5,
                            ),
                          ),
                          SizedBox(height: Dimensions.height5),
                          Text(
                            trial.ageGroup,
                            style: TextStyle(
                              fontSize: Dimensions.font12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: Dimensions.height5),
                          Text(
                            '₦${trial.registrationFee.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: Dimensions.font13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class TrialDetailsScreen extends StatefulWidget {
  final String trialId;

  const TrialDetailsScreen({super.key, required this.trialId});

  @override
  State<TrialDetailsScreen> createState() => _TrialDetailsScreenState();
}

class _TrialDetailsScreenState extends State<TrialDetailsScreen> {
  final TrialController trialController = Get.find<TrialController>();
  UserController userController = Get.find<UserController>();
  late final user = userController.othersProfile.value;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      trialController.fetchTrialDetails(widget.trialId);
    });
  }

  String _fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${AppConstants.SOCKET_BASE_URL}$path';
  }

  Widget _infoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: AppColors.grey5)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppbar(
        title: 'Trial Details',
        leadingIcon: const BackButton(),
      ),
      body: Obx(() {
        if (trialController.isProcessing.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final trial = trialController.currentTrialDetails.value;
        if (trial == null) {
          return const Center(child: Text('Unable to load trial details'));
        }

        final players = trial.registeredPlayers ?? [];

        return SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.width20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _fullImageUrl(trial.banner),
                  height: 220,
                  width: Dimensions.screenWidth,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 220,
                        width: Dimensions.screenWidth,
                        color: AppColors.grey2,
                        child: const Icon(Icons.image_outlined, size: 40),
                      ),
                ),
              ),
              SizedBox(height: Dimensions.height20),

              Text(
                trial.name,
                style: TextStyle(
                  fontSize: Dimensions.font20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Dimensions.height10),

              Text(
                trial.creator?.clubName ??
                    trial.creator?.name ??
                    'Unknown Organizer',
                style: TextStyle(
                  fontSize: Dimensions.font14,
                  color: AppColors.grey5,
                ),
              ),

              SizedBox(height: Dimensions.height15),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.4,
                children: [
                  _infoTile('Location', trial.location),
                  _infoTile(
                    'Date',
                    trial.date.toLocal().toString().split(' ').first,
                  ),
                  _infoTile('Age Group', trial.ageGroup),
                  _infoTile('Type', trial.type),
                  _infoTile(
                    'Registration Fee',
                    '₦${trial.registrationFee.toStringAsFixed(0)}',
                  ),
                  _infoTile('Registered', '${trial.registeredCount}'),
                ],
              ),

              SizedBox(height: Dimensions.height20),

              Text(
                'Description',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Text(trial.description ?? 'No description'),
              ),

              SizedBox(height: Dimensions.height20),

              Text(
                'Organizer',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.grey2,
                      backgroundImage:
                          (trial.creator?.profilePicture != null &&
                                  trial.creator!.profilePicture!.isNotEmpty)
                              ? NetworkImage(trial.creator!.profilePicture!)
                              : null,
                      child:
                          (trial.creator?.profilePicture == null ||
                                  trial.creator!.profilePicture!.isEmpty)
                              ? const Icon(Icons.person)
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trial.creator?.clubName ??
                                trial.creator?.name ??
                                '-',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text('@${trial.creator?.username ?? '-'}'),
                          if (trial.creator?.state != null)
                            Text(
                              '${trial.creator?.state}, ${trial.creator?.country ?? ''}',
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Dimensions.height20),

              Text(
                'Registered Players',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: Dimensions.height10),

              if (players.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.grey2),
                  ),
                  child: const Text('No registered players yet'),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: players.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.grey2),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.grey2,
                            backgroundImage:
                                (player.profilePicture != null &&
                                        player.profilePicture!.isNotEmpty)
                                    ? NetworkImage(player.profilePicture!)
                                    : null,
                            child:
                                (player.profilePicture == null ||
                                        player.profilePicture!.isEmpty)
                                    ? const Icon(Icons.person)
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text('@${player.username}'),
                              ],
                            ),
                          ),

                          SizedBox(width: Dimensions.width5),
                          CustomButton(
                            text: 'Send a dm',
                            textStyle: TextStyle(
                              color: AppColors.white,
                              fontSize: Dimensions.font10,
                              fontWeight: FontWeight.w500,
                            ),
                            onPressed: () async {
                              try {
                                final chatRepo = Get.find<ChatRepo>();

                                final response = await chatRepo.getOrCreateChat(
                                  user!.id,
                                );

                                if (response.statusCode == 200 &&
                                    response.body['code'] == '00') {
                                  print(
                                    'CHAT RAW DATA: ${response.body['data']}',
                                  );

                                  final chat = Chat.fromJson(
                                    Map<String, dynamic>.from(
                                      response.body['data'],
                                    ),
                                  );

                                  Get.toNamed(
                                    AppRoutes.messagingScreen,
                                    arguments: {
                                      'chat': chat,
                                      'peerName': player.name,
                                      'peerUsername': player.username,
                                      'peerProfilePicture':
                                          player.profilePicture,
                                    },
                                  );
                                } else {
                                  CustomSnackBar.failure(
                                    message:
                                        response.body?['message'] ??
                                        'Unable to open chat',
                                  );
                                }
                              } catch (e, s) {
                                print('OPEN CHAT ERROR: $e');
                                print(s);
                                CustomSnackBar.failure(
                                  message: 'Unable to open chat: $e',
                                );
                              }
                            },
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width5,
                              vertical: Dimensions.height5,
                            ),
                            backgroundColor: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
