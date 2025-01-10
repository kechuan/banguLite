import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

bool judgeInSeasonBangumi(String? bangumiAirDate){

  if(bangumiAirDate == null) return false;
  final convertedTime = DateTime.parse(bangumiAirDate);

  return DateTime.now().difference(convertedTime) < const Duration(days: 90);

}

bool judgeTransitionalSeason(){

  final currentTime = DateTime.now();

  return SeasonType.values.any((currentSeason){
    final DateTime convertedTime = DateTime.parse("${currentTime.year}-${convertDigitNumString(currentSeason.month)}-01");

    if(
      currentTime.month == currentSeason.month &&
      currentTime.difference(convertedTime) < const Duration(days: 5)
    ){
      return true;
    }

    return false;
  });

}

bool judgeDarknessMode(BuildContext context){
  return Theme.of(context).brightness == Brightness.dark ? true : false;
}

Color judgeCurrentThemeColor(BuildContext context){
  final IndexModel indexModel = context.read<IndexModel>();

  if(indexModel.userConfig.isSelectedCustomColor == true){
    return indexModel.userConfig.customColor!;
  }

  return indexModel.userConfig.currentThemeColor!.color;

}

Color judgeDetailRenderColor(BuildContext context,Color? imageColor){

  final IndexModel indexModel = context.read<IndexModel>();

  Color renderColor;

  if(indexModel.userConfig.isfollowThemeColor == true){
    renderColor = judgeCurrentThemeColor(context);
  }

  else{
    renderColor = imageColor ?? indexModel.userConfig.currentThemeColor!.color;
  }

  return renderColor;

}

SeasonType judgeSeasonRange(int currentMonth){

  SeasonType currentSeasonType = SeasonType.spring;

  SeasonType.values.any((currentSeason){
    if(currentMonth >= currentSeason.month){
      currentSeasonType = currentSeason;
      return true;
    }

    return false;

  });

  return currentSeasonType;
}
