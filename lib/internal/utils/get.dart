import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/judge.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Color getCurrentThemeColor(BuildContext context) {
  final IndexModel indexModel = context.read<IndexModel>();

  if (indexModel.userConfig.isSelectedCustomColor == true) {
    return indexModel.userConfig.customColor!;
  }

  return indexModel.userConfig.currentThemeColor!.color;

}

Color? getDarkContentSurfaceColor(
  BuildContext context,
) {
  final indexModel = context.watch<IndexModel>();

  if (indexModel.userConfig.isPureDarkMode == false) {

    //debugPrint("lumi: ${Colors.grey.withValues(alpha: 0.1).computeLuminance()} / ${Color(0xFF2C2C2C).computeLuminance()}");

    //更浅
    //return Colors.grey.withValues(alpha: 0.15);

    //更深
    return const Color(0xFF2C2C2C);

    //[DEBUG]
    //return Colors.grey.withValues(alpha: 0.5);
  }

  return null;


}

Color getDetailRenderColor(BuildContext context, Color? imageColor) {

  Color renderColor;

  if (judgeIsFollowThemeColor(context) == true) {
    renderColor = getCurrentThemeColor(context);
  }

  else {
    renderColor = imageColor ?? getCurrentThemeColor(context);
  }

  return renderColor;  

}

SeasonType getSeasonRange(int currentMonth, {bool? currentTime}) {

  SeasonType currentSeasonType = SeasonType.winter;

  // 5
  // 1 4 7 10

  SeasonType.values.any((currentSeason) {

    if (currentTime == true) {
      if (currentMonth >= currentSeason.month) {
        currentSeasonType = currentSeason;
        return false;
      }

      return true;
    }

    else {
      if (currentMonth > currentSeason.month) {
        return false;
      }

      currentSeasonType = currentSeason;
      return true;

    }

  });

  return currentSeasonType;
}
