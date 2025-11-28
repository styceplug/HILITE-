import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:iconsax/iconsax.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with AutomaticKeepAliveClientMixin<ActivitiesScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Activities'),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: Dimensions.height150,
                  decoration: BoxDecoration(
                    color: AppColors.grey3,
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: Dimensions.height10,
                      width: Dimensions.width10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey4,
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Container(
                      height: Dimensions.height10,
                      width: Dimensions.width10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey4,
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Container(
                      height: Dimensions.height10,
                      width: Dimensions.width10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                itemCard(
                  title: 'New followers',
                  subtitle: 'styce started following you.',
                  iconOrImage: Icons.people,
                  color: AppColors.primary.withOpacity(0.8),
                  count: '9+',
                ),
                itemCard(
                  title: 'Activity',
                  subtitle: 'JOSE MOURINHO liked your post',
                  iconOrImage: Icons.favorite,
                  color: Colors.red.withOpacity(0.9),
                  count: '5',
                ),
                itemCard(
                  title: 'Marcus Rashford',
                  subtitle:
                      'I have been viewing your content and must say its impressive',
                  iconOrImage: AppConstants.getPngAsset('rashford'),
                  color: AppColors.primary.withOpacity(0.8),
                  count: '1',
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: Dimensions.bottomNavIconHeight + Dimensions.height150,
              child: InkWell(
                onTap: (){
                  Get.toNamed(AppRoutes.uploadContent);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(CupertinoIcons.plus, color: AppColors.white),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget itemCard({
    required String title,
    required String subtitle,
    required dynamic iconOrImage,
    required Color color,
    required String count,
    bool isNetworkImage = false,
  }) {
    Widget iconWidget;

    if (iconOrImage is IconData) {
      iconWidget = Icon(
        iconOrImage,
        color: AppColors.white,
        size: Dimensions.iconSize30,
      );
    } else if (iconOrImage is String) {
      iconWidget = ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child:
            isNetworkImage
                ? Image.network(
                  iconOrImage,
                  height: Dimensions.iconSize30,
                  width: Dimensions.iconSize30,
                  fit: BoxFit.cover,
                )
                : Image.asset(
                  iconOrImage,
                  height: Dimensions.iconSize30,
                  width: Dimensions.iconSize30,
                  fit: BoxFit.cover,
                ),
      );
    } else {
      iconWidget = Icon(
        Icons.person,
        color: AppColors.white,
        size: Dimensions.iconSize30,
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height10),
      child: Row(
        children: [
          Container(
            height: Dimensions.height10 * 6,
            width: Dimensions.width10 * 6,
            padding:
                (iconOrImage is IconData)
                    ? EdgeInsets.all(Dimensions.height12)
                    : EdgeInsets.zero,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: iconWidget,
          ),
          SizedBox(width: Dimensions.width10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: Dimensions.font18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: Dimensions.width10),
          Container(
            height: Dimensions.height10 * 2.5,
            width: Dimensions.width10 * 2.5,
            padding: EdgeInsets.all(Dimensions.height5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error,
            ),
            alignment: Alignment.center,
            child: Text(
              count,
              maxLines: 1,
              style: TextStyle(
                fontSize: Dimensions.font10,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
