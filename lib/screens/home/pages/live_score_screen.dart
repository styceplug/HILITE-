import 'package:flutter/material.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';

class LiveScoreScreen extends StatefulWidget {
  const LiveScoreScreen({super.key});

  @override
  State<LiveScoreScreen> createState() => _LiveScoreScreenState();
}

class _LiveScoreScreenState extends State<LiveScoreScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int selectedLeagueIndex = -1;

  final leagues = [
    {"image": "epl", "name": "Premier \nLeague"},
    {"image": "la-liga", "name": "La Liga\nLeague"},
    {"image": "serie-a", "name": "Serie A\nLeague"},
    {"image": "bundesliga", "name": "Bundesliga\nLeague"},
    {"image": "ligue1", "name": "Ligue 1\nLeague"},
    {"image": "cbf", "name": "CBF\nLeague"},
    {"image": "korean-league", "name": "Korean\nLeague"},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenHeight,
      width: Dimensions.screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20 * 4,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Matches',
                style: TextStyle(
                  fontSize: Dimensions.font18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Image.asset(
                AppConstants.getPngAsset('nav1'),
                height: Dimensions.height30,
                width: Dimensions.width30,
                color: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: Dimensions.height20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(leagues.length, (index) {
                final league = leagues[index];
                return leagueCard(
                  image: league["image"]!,
                  name: league["name"]!,
                  isSelected: selectedLeagueIndex == index,
                  onTap: () {
                    setState(() {
                      selectedLeagueIndex = index;
                    });
                  },
                );
              }),
            ),
          ),
          SizedBox(height: Dimensions.height20),
          Row(
            children: [
              Text(
                'Upcoming',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: Dimensions.width20),
              Text(
                'Past Matches',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Friday - November 7',
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: Dimensions.height20),
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  height: Dimensions.height100 * 2,
                  width: Dimensions.screenWidth,

                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(
                        AppConstants.getLeagueAsset('background'),
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: Dimensions.height10),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              AppConstants.getLeagueAsset('epl'),
                              height: Dimensions.height30,
                              width: Dimensions.width30,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.width5,
                                vertical: Dimensions.height5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grey3,
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radius5,
                                ),
                              ),
                              child: Text(
                                '7:00 PM',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'CHELSEA',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                SizedBox(width: Dimensions.width20),
                                Image.asset(
                                  AppConstants.getLeagueAsset('chelsea'),
                                  fit: BoxFit.cover,
                                  height: Dimensions.height40,
                                  width: Dimensions.width40,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  AppConstants.getLeagueAsset('united'),
                                  fit: BoxFit.cover,
                                  height: Dimensions.height40,
                                  width: Dimensions.width40,
                                ),
                                SizedBox(width: Dimensions.width20),
                                Text(
                                  'MAN UTD',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Container(
                        width: Dimensions.screenWidth,
                        color: AppColors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                          vertical: Dimensions.height10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PLAYOFFS-ROUND 1',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Best of 3',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: Dimensions.font12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget leagueCard({
    required String image,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: Dimensions.width10),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: Dimensions.height70,
              width: Dimensions.width70,
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width10,
                vertical: Dimensions.height10,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.grey2,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(Dimensions.radius10),
              ),
              child: Image.asset(AppConstants.getLeagueAsset(image)),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimensions.font12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
