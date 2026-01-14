import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
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

Color judgeCurrentThemeColor(BuildContext context){
  final IndexModel indexModel = context.read<IndexModel>();

  if(indexModel.userConfig.isSelectedCustomColor == true){
    return indexModel.userConfig.customColor!;
  }


  return indexModel.userConfig.currentThemeColor!.color;

}

Color? judgeDarkContentSurfaceColor(
  BuildContext context,
){
  final indexModel = context.watch<IndexModel>();

  if(indexModel.userConfig.isPureDarkMode == false){

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

Color judgeDetailRenderColor(BuildContext context,Color? imageColor){

  final IndexModel indexModel = context.read<IndexModel>();

  Color renderColor;

  if(indexModel.userConfig.isFollowThemeColor == true){
    renderColor = judgeCurrentThemeColor(context);
    
  }

  else{
    renderColor = imageColor ?? judgeCurrentThemeColor(context);
  }

  return renderColor;

}


SeasonType judgeSeasonRange(int currentMonth,{bool? currentTime}){

  SeasonType currentSeasonType = SeasonType.winter;

  // 5
  // 1 4 7 10

  SeasonType.values.any((currentSeason){

    if(currentTime == true){
      if(currentMonth >= currentSeason.month){
        currentSeasonType = currentSeason;
        return false;
      }

      return true;
    }
    
    else{
      if(currentMonth > currentSeason.month){
        return false;
      }

      currentSeasonType = currentSeason;
      return true;

    }

    

  });



  return currentSeasonType;
}

bool judgeDarknessMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? true : false;
bool judgeLandscapeMode(BuildContext context) => MediaQuery.orientationOf(context) == Orientation.landscape ? true : false;
