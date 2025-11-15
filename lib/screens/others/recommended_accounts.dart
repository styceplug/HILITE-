import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/snackbars.dart';

import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class RecommendedAccountsScreen extends StatefulWidget {
  const RecommendedAccountsScreen({super.key});

  @override
  State<RecommendedAccountsScreen> createState() =>
      _RecommendedAccountsScreenState();
}

class _RecommendedAccountsScreenState extends State<RecommendedAccountsScreen> {
  UserController userController = Get.find<UserController>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.getRecommendedUsers();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Recommended Accounts to follow',
        leadingIcon: BackButton(),
        actionIcon: InkWell(
          onTap: () {
            CustomSnackBar.showToast(
              message:
                  'Accounts are suggested based on your interests and connections. Your account may also be suggested to people you may know.',
            );
          },
          child: Icon(Icons.info, size: Dimensions.iconSize20),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Obx(() {
          if (userController.recommendedUsers.isEmpty) {
            return const Center(child: Text('No recommendations yet'));
          }

          return ListView.builder(
            itemCount: userController.recommendedUsers.length,
            itemBuilder: (context, index) {
              final user = userController.recommendedUsers[index];
              return AccountCard(
                name: user.name.capitalizeFirst ?? '',
                bio: user.bio?.capitalizeFirst ?? '',
                role: user.role.capitalizeFirst ?? '',
                id: user.id,
                image: user.profilePicture ?? 'https://via.placeholder.com/150',
                isFollowed: user.isFollowed,
                isBlocked: user.isBlocked,
                onFollow: () => userController.followUser(user.id),
                onBlock: () => userController.blockUser(user.id),
              );
            },
          );
        }),
      ),
    );
  }

  Widget AccountCard({
    required String name,
    required String bio,
    required String id,
    required String role,
    required String image,
    required bool isFollowed,
    required bool isBlocked,
    required VoidCallback onFollow,
    required VoidCallback onBlock,
  }) {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.othersProfileScreen,arguments: {'targetId':id});
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.height10,
          horizontal: Dimensions.width10,
        ),
        margin: EdgeInsets.only(bottom: Dimensions.height15),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey1),
          borderRadius: BorderRadius.circular(Dimensions.radius10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.network(
                    image,
                    height: Dimensions.height10 * 6,
                    width: Dimensions.width10 * 6,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: Dimensions.height10 * 6,
                        width: Dimensions.width10 * 6,
                        decoration: BoxDecoration(color: AppColors.error),
                        child: Icon(Icons.person, color: AppColors.white),
                      );
                    },
                  ),
                ),
                SizedBox(width: Dimensions.width10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: Dimensions.font17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width10,
                              vertical: Dimensions.height5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.radius15),
                              color: AppColors.primary,
                            ),
                            child: InkWell(
                              onTap: () {
                                CustomSnackBar.showToast(
                                  message:
                                  'This is a verified $role profile — representing their actual role in the sports world.',
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info,
                                    size: Dimensions.iconSize16,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(width: Dimensions.width5),
                                  Text(
                                    '$role'.toString().capitalizeFirst ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: Dimensions.font12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        bio,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    text: isBlocked ? 'Blocked' : 'Remove',
                    onPressed: () {
                      if (!isBlocked) {
                        print("🧱 Block button pressed for $name");
                        onBlock();
                      }
                    },
                    backgroundColor:
                    isBlocked ? AppColors.error : AppColors.grey4,
                    textStyle: TextStyle(
                      color: isBlocked ? AppColors.white : AppColors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: Dimensions.font15,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height10,
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: CustomButton(
                    text: isFollowed ? 'Followed' : 'Follow',
                    onPressed: () {
                      if (!isFollowed) {
                        print("👥 Follow button pressed for $name");
                        onFollow();
                      }
                    },
                    backgroundColor:
                    isFollowed ? AppColors.grey4 : AppColors.primary,
                    textStyle: TextStyle(
                      color: isFollowed ? AppColors.black : AppColors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: Dimensions.font15,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height10,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
