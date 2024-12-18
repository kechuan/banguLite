
import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:flutter/material.dart';

String? convertAmpsSymbol(String? originalString){
  if(originalString?.contains("&amp;") ?? false){
   return originalString?.replaceAll("&amp;", "&");
  }

  return originalString;
}

String convertDigitNumString(int originalNumber, {int numberBits = 2}){

  String fillingContent = '';

  if(originalNumber >= 10*(numberBits-1)){
    return '$originalNumber';
  }

  else{
    for(numberBits; numberBits>1; numberBits--){
      fillingContent+='0';
    }

    return '$fillingContent$originalNumber';
  }

}

String convertBangumiCommentSticker(String originalComment){
  RegExp stickerMatch = RegExp(r'(\()+bgm+(\d{2,3})(\))');
  
  String mappedComment = originalComment.replaceAllMapped(
    stickerMatch, 
    (match){

      String resultText = "";
      String replaceTag = "sticker";

      List<String?> resultList = [];
      

      for(String? currentPattern in match.groups([1,2,3])){
        switch(currentPattern){
          case '(': resultList.add("[$replaceTag]"); break;
          case ')': resultList.add("[/$replaceTag]"); break;
          default: resultList.add("assets/bangumiSticker/bgm${match.group(2)}.gif");
        }
      }


      resultText = resultList.join();

      

      return resultText;

      
    }
  );

  //debugPrint("convert :$mappedComment");

  return mappedComment;

									
}

int convertSegement(int totalEps, int segementRange) => convertTotalCommentPage(totalEps,segementRange);
int convertTotalCommentPage(int totalComments, int pageRange){
return  totalComments % pageRange == 0 ?
        totalComments~/pageRange :
        totalComments~/pageRange + 1;
}

bool judgeInSeasonBangumi(String? bangumiAirDate){

  if(bangumiAirDate == null) return false;

  List<String> dateSegments = bangumiAirDate.split("-");

  int bangumiYear = int.parse(dateSegments[0]);
  int bangumiMonth = int.parse(dateSegments[1]);

  if((bangumiYear - DateTime.now().year).abs() <= 1){
    if(
        (DateTime.now().month - bangumiMonth).abs() <= 2 || 
        (DateTime.now().month - bangumiMonth).abs() >= 10
    ) {
      return true;
    }
  }

  return false;

}

int convertAirDateTime(String? bangumiAirDate){
	if(bangumiAirDate == null) return 0;

	List<String> dateSegments = bangumiAirDate.split("-");

	int bangumiYear = int.parse(dateSegments[0]);
	int bangumiMonth = int.parse(dateSegments[1]);
	int bangumiDay = int.parse(dateSegments[2]);

  return DateTime(bangumiYear,bangumiMonth,bangumiDay).millisecondsSinceEpoch;

}

int convertAiredEps(String? bangumiAirDate){
	if(bangumiAirDate == null) return 0;

	int residualDateTime = (DateTime.now().millisecondsSinceEpoch - convertAirDateTime(bangumiAirDate));

	//放送开始附带一集 因此+1
	int airedEps =  (residualDateTime ~/ const Duration(days: 7).inMilliseconds) + 1;

	return airedEps;
}

String convertTypeSize(int totalLength,{StorageSize type = StorageSize.megabytes}){
  
  const int binary = 1024;
  num result = totalLength/pow(binary,type.index);
  String suffix;

  switch(type){
    case StorageSize.bytes: {suffix = StorageSize.bytes.suffix; break;}
    case StorageSize.kilobytes: {suffix = StorageSize.kilobytes.suffix; break;}
    case StorageSize.megabytes: {suffix = StorageSize.megabytes.suffix; break;}
    case StorageSize.gigabytes: {suffix = StorageSize.gigabytes.suffix; break;}
  }

  return "${result.toStringAsFixed(2)}$suffix";
}

String convertScoreRank(double? score){

  if(score==null) return ScoreRank.none.rankText;

  String resultRankText = "";

  //The property 'score' can't be accessed on the type 'ScoreRank' in a constant expression.

  //不确定到底是写一堆if-else结构还是直接这样顺序处理哪个更好
  //但这个至少简单 那就这个了

  if(score == ScoreRank.none.score) resultRankText = ScoreRank.none.rankText;
  if(score >= ScoreRank.worst.score) resultRankText = ScoreRank.worst.rankText;
  if(score >= ScoreRank.worse.score) resultRankText = ScoreRank.worse.rankText;
  if(score >= ScoreRank.poor.score) resultRankText = ScoreRank.poor.rankText;
  if(score >= ScoreRank.bad.score) resultRankText = ScoreRank.bad.rankText;
  if(score >= ScoreRank.medium.score) resultRankText = ScoreRank.medium.rankText;
  if(score >= ScoreRank.pass.score) resultRankText = ScoreRank.pass.rankText;
  if(score >= ScoreRank.great.score) resultRankText = ScoreRank.great.rankText;
  if(score >= ScoreRank.excellent.score) resultRankText = ScoreRank.excellent.rankText;
  if(score >= ScoreRank.perfect.score) resultRankText = ScoreRank.perfect.rankText;
  

  return resultRankText;


}

bool judgeDarknessMode(BuildContext context){
  return Theme.of(context).brightness == Brightness.dark ? true : false;
}