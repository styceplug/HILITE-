import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/custom_textfield.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/post_controller.dart';
import '../../../models/post_model.dart';
import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/reel_overlay.dart';
import '../../../widgets/reels_video_item.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PostController controller = Get.find<PostController>();
  final PageController pageController = PageController();

  String currentType = "video";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.posts.isEmpty) {
        controller.loadRecommendedPosts(currentType);
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        controller.loadRecommendedPosts(currentType);
        return Future.delayed(const Duration(seconds: 1));
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (controller.posts.isEmpty) {
            controller.loadRecommendedPosts(currentType);
            ;
          }

          return Stack(
            children: [
              // 1. The Vertical Feed
              PageView.builder(
                controller: pageController,
                scrollDirection: Axis.vertical,
                itemCount: controller.posts.length,
                onPageChanged: (index) => controller.onPageChanged(index),
                itemBuilder: (_, index) {
                  final post = controller.posts[index];
                  if (post.type == 'video' || post.type == 'image') {
                    return ReelsVideoItem(
                      index: index,
                      post: post,
                      controller: controller,
                    );
                  }
                },
              ),

              // 2. Top Tabs (Trials / Images / Videos)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: Dimensions.width20,
                right: Dimensions.width20,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          Get.toNamed(AppRoutes.recommendedAccountsScreen);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width20,
                            vertical: Dimensions.height10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius15,
                            ),
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(CupertinoIcons.search, color: AppColors.black),
                              SizedBox(width: Dimensions.width15),
                              Text(
                                'Search...',
                                style: TextStyle(
                                  fontSize: Dimensions.font16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black,
                                ),
                              ),
                              Spacer(),
                              InkWell(
                                onTap:(){},
                                child: Icon(Iconsax.people, size: Dimensions.iconSize24),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
