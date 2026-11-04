import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

bool judgeInSeasonBangumi(String? bangumiAirDate) {

  if (bangumiAirDate == null) return false;
  final convertedTime = DateTime.parse(bangumiAirDate);

  return DateTime.now().difference(convertedTime) < const Duration(days: 90);

}

bool judgeTransitionalSeason() {

  final currentTime = DateTime.now();

  return SeasonType.values.any((currentSeason) {
    final DateTime convertedTime = DateTime.parse("${currentTime.year}-${convertDigitNumString(currentSeason.month)}-01");

    if (
    currentTime.month == currentSeason.month &&
      currentTime.difference(convertedTime) < const Duration(days: 5)
    ) {
      return true;
    }

    return false;
  });

}

bool judgeIsFollowThemeColor(BuildContext context) {
  final IndexModel indexModel = context.read<IndexModel>();

  return indexModel.userConfig.isFollowThemeColor == true;
}




bool judgeDarknessMode(BuildContext context) => Theme.brightnessOf(context) == Brightness.dark ? true : false;
bool judgeLandscapeMode(BuildContext context) => MediaQuery.orientationOf(context) == Orientation.landscape ? true : false;

/// 外链图片代理在 AppConfig 中默认为 true
bool judgeIsProxyMode(BuildContext context, {bool? isOuterImageProxy}) {

  final userConfig = context.read<IndexModel>().userConfig;

  //null/true 放行
  if (userConfig.isProxyMode != false) {
    if (userConfig.currentProxyAddress != null && userConfig.currentProxyAddress!.isNotEmpty) { 
      if (isOuterImageProxy == false) return false;
      return true;
    }
  }

  return false;
}
