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
    renderColor = imageColor ?? judgeCurrentThemeColor(context);
  }

  return renderColor;

}

//SeasonType judgeCurrentSeasonRange(int currentMonth,{bool? currentTime}){

//  SeasonType currentSeasonType = SeasonType.winter;

//  for(int currentSeasonIndex = 0; currentSeasonIndex<SeasonType.values.length; currentSeasonIndex++){
//    if(currentMonth > SeasonType.values[currentSeasonIndex].month){
//      continue;
//    }

//    else{
//      if(currentSeasonIndex == 0) return currentSeasonType;
//      currentSeasonType = SeasonType.values[currentSeasonIndex-1];
//      break;
//    }
//  }

  

//  return currentSeasonType;
//}

SeasonType judgeSeasonRange(int currentMonth,{bool? currentTime}){

  SeasonType currentSeasonType = SeasonType.winter;

  SeasonType.values.any((currentSeason){
    if(currentMonth > currentSeason.month){
      return false;
    }

    currentSeasonType = currentSeason;
    return true;

  });

  if(currentTime == true){
    if(currentSeasonType == SeasonType.winter) return currentSeasonType;
    currentSeasonType = SeasonType.values.elementAt(currentSeasonType.index - 1);
  }

  return currentSeasonType;
}
