import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/judge.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Color getCurrentThemeColor(BuildContext context) {
  final IndexModel indexModel = context.read<IndexModel>();

  if (indexModel.userConfig.isSelectedCustomColor == true && indexModel.userConfig.customColor != null) {
    return indexModel.userConfig.customColor!;
  }

  return (indexModel.userConfig.currentThemeColor ?? AppThemeColor.ruby).color;

}

Color? getDarkSurfaceColorByMode(bool? isPureDarkMode) {
  if (isPureDarkMode == false) {
    return const Color(0xFF2C2C2C);
  }

  return null;
}

Color? getDarkContentSurfaceColor(
  BuildContext context, {
  bool listen = true,
}) {
  final bool? isPureDarkMode = listen
    ? context.select<IndexModel, bool?>((model) => model.userConfig.isPureDarkMode)
    : context.read<IndexModel>().userConfig.isPureDarkMode;

  return getDarkSurfaceColorByMode(isPureDarkMode);
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

  for (final currentSeason in SeasonType.values) {
    if (currentTime == true) {
      if (currentMonth >= currentSeason.month) {
        currentSeasonType = currentSeason;
      } else {
        break;
      }
    } else {
      if (currentMonth <= currentSeason.month) {
        currentSeasonType = currentSeason;
        break;
      }
    }
  }

  return currentSeasonType;
}
