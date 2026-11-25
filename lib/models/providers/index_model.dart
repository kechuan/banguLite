
import 'package:bangu_lite/hive/config_model.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/services/star_sync_service.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/models/informations/local/star_details.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IndexModel extends ChangeNotifier {
  IndexModel(){
    initModel();
  }

  int starUpdateFlag = 0;

  AppConfig userConfig = defaultAPPConfig();

  Map<int, Map<String, num>> starsUpdateRating = {};

  // 草稿箱 [标题:内容]
  // 当然标题不一定会存在 如果不存在直接置为空就好

  //理论上这样做的话 会有发布内容会被互相覆盖的问题
  //但我不应该响应这种情况 毕竟是DAU没两位数的项目
  //试试Record吧。。
  final Map<dynamic, (String,String)> draftContent = {};

  //用于在视觉上覆盖用户原本的评论
  Map<int, String> userCommentMap = {};

  void updateUserCommentMap(int postID, String comment) {
    userCommentMap = {
      ...userCommentMap
      ..[postID] = comment
    };

    notifyListeners();
  }

  int cachedImageSize = 0;

  void initModel() async {
    loadConfigData();
    await updateStarDetail();
  }

  void loadConfigData() {
    userConfig = MyHive.appConfigDataBase.get("currentTheme") ?? defaultAPPConfig();
    AppFontSize.scale = userConfig.fontScale ?? ScaleType.medium;
  }

  void updateThemeMode(ThemeMode mode, {bool? config}) {
    userConfig.themeMode = mode;
    notifyListeners();
    if (config == true) updateConfig();    
  }

  void updateThemeColor(AppThemeColor themeColor) {
    userConfig.currentThemeColor = themeColor;
    userConfig.isSelectedCustomColor = false;
    updateConfig();
  }

  void updateCustomColor(Color customColor) {
    userConfig.customColor = customColor;
    userConfig.isSelectedCustomColor = true;
    updateConfig();
  }

  void updateFontSize(ScaleType scale) {
    AppFontSize.scale = scale;
    userConfig.fontScale = scale;
    updateConfig();
  }

  void updateFollowThemeColor(bool detailfollowStatus) {
    userConfig.isFollowThemeColor = detailfollowStatus;
    updateConfig();
  }

  void updateCommentImageLoadMode(bool imageLoadMode) {
    userConfig.isManuallyImageLoad = imageLoadMode;
    updateConfig();
  }

  void updateUpdateAlertMode(bool alertMode) {
    userConfig.isUpdateAlert = alertMode;
    updateConfig();
  }

  void updatePureDarkMode(bool darkMode) {
    userConfig.isPureDarkMode = darkMode;
    updateConfig();
  }

  void updateProxyMode(bool proxyMode) {
    userConfig.isProxyMode = proxyMode;
    updateConfig();
  }

  void updateCurrentProxyAddress(String proxyAddress) {
    userConfig.currentProxyAddress = proxyAddress;
    updateConfig();
  }

  void updateImageTagProxyMode(bool isImageTagProxy) {
    userConfig.isImgTagProxy = isImageTagProxy;
    updateConfig();
  }

  //更新所有收藏的番剧未免不现实 更改一下逻辑
  //变成只更新目前还未完结的番剧吧。。
  Future<void> updateStarDetail() async {
    Set<int> starsList = {};

    if (MyHive.starBangumisDataBase.keys.isEmpty) return;

    starsList.addAll(
      MyHive.starBangumisDataBase.values.where(
        (bangumiData) {
          if (
          bangumiData.rank == 0 || 
            bangumiData.score == 0.0
          ) {
            return true;
          }

          DateTime finishedTime = convertDateTime(bangumiData.finishedDate);
          if (DateTime.now().compareTo(finishedTime) < 0) return true;
          return false;
        }
      ).map((e) => e.bangumiID!).toList()
    );

    starsUpdateRating = await StarSyncService.fetchStarsRating(starsList);

    debugPrint("timestamp: ${DateTime.now()} update Star done");

    if (starsUpdateRating.isNotEmpty) {
      for (int bangumiID in starsUpdateRating.keys) {

        final StarBangumiDetails? currentStorageInformation = MyHive.starBangumisDataBase.get(bangumiID);

        if (currentStorageInformation == null) continue;

        MyHive.starBangumisDataBase.put(
          bangumiID,
          currentStorageInformation
            ..score = starsUpdateRating[bangumiID]!["score"] as double?
            ..rank = starsUpdateRating[bangumiID]!["rank"] as int?
        );

      }
    }

  }

  void resetConfig() {
    MyHive.appConfigDataBase.clear();
    userConfig = defaultAPPConfig();
    AppFontSize.scale = ScaleType.medium;
    notifyListeners();
  }

  void updateConfig() {
    MyHive.appConfigDataBase.put("currentTheme", userConfig);
    notifyListeners();
  }

  Future<void> updateCachedSize() async {
    cachedImageSize = await compute(getTotalSizeOfFilesInDir, MyHive.cachedImageDir);
    notifyListeners();
  }

  void updateStar() {
    starUpdateFlag += 1;
    notifyListeners();
  }

}

class AppFontSize {
  static ScaleType scale = ScaleType.medium;

  static double get s18 => 18 * scale.fontScale;
  static double get s17 => 17 * scale.fontScale;
  static double get s16 => 16 * scale.fontScale;
  static double get s15 => 15 * scale.fontScale;
  static double get s14 => 14 * scale.fontScale;
  static double get s13 => 13 * scale.fontScale;
  static double get s12 => 12 * scale.fontScale;
  static double getScaledSize(double fontSize) => fontSize * scale.fontScale;

  static void init() {
    //Hive 存放
    scale = ScaleType.medium;
  }

}
