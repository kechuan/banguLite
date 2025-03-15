
import 'dart:io';
import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/models/eps_info.dart';
import 'package:flutter/material.dart';


String? convertAmpsSymbol(String? originalString){
  if(originalString?.contains("&amp;") ?? false){
   return originalString?.replaceAll("&amp;", "&");
  }

  if(originalString?.contains("&quot;") ?? false){
   return originalString?.replaceAll('&quot;', '"');
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

DateTime convertDateTime(String? bangumiDate){
	if(bangumiDate == null) return DateTime(0);

  DateTime? convertedDateTime;

  convertedDateTime = DateTime.tryParse(bangumiDate);
  if(convertedDateTime!=null) return convertedDateTime;

  List<String> dateSegments = bangumiDate.split("-");
  if(dateSegments.length != 3) return DateTime(0);

  int bangumiYear = int.parse(dateSegments[0]);
  int bangumiMonth = int.parse(dateSegments[1]);
  int bangumiDay = int.parse(dateSegments[2]);

  return DateTime(bangumiYear,bangumiMonth,bangumiDay);


}

String convertDateTimeToString(DateTime dateTime){
  return dateTime.toIso8601String().substring(0,10);
  //return "${dateTime.year}-${convertDigitNumString(dateTime.month)}-${convertDigitNumString(dateTime.day)} ${convertDigitNumString(dateTime.hour)}:${convertDigitNumString(dateTime.minute)}";
}


int convertAiredEps(String? bangumiDate){
	if(bangumiDate == null) return 0;

	int residualDateTime = (DateTime.now().millisecondsSinceEpoch - convertDateTime(bangumiDate).millisecondsSinceEpoch);

	//放送开始附带一集 因此+1
	int airedEps = (residualDateTime ~/ const Duration(days: 7).inMilliseconds) + 1;

	return airedEps;
}

int convertPassedSeason(int year,int month){
  int passedSeason = 1;
  DateTime currentTime = DateTime.now();

  if(year < currentTime.year) return 4;

  SeasonType.values.any((currentSeasonType){
    if(currentSeasonType.month > month){
      debugPrint("what:${currentSeasonType.month} / $month ");
      passedSeason+=1;
      return false;
    }
    return true;
  });

  return passedSeason;

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

String convertSubjectType(int? type){
  if(type == null) return "";

  String resultSubjectType = "";

  for(SubjectType currentType in SubjectType.values){
    if(currentType.subjectType == type){
      resultSubjectType = currentType.name;
      break;
    }
  }

  return resultSubjectType.replaceFirst(resultSubjectType[0], resultSubjectType[0].toUpperCase());

}

String convertScoreRank(double? score){

  if(score==null) return ScoreRank.none.rankText;

  String resultRankText = ScoreRank.none.rankText;

  //为什么不用switch? 
  //Error: The property 'score' can't be accessed on the type 'ScoreRank' in a constant expression.

  for(ScoreRank currentRank in ScoreRank.values){
    if(score >= currentRank.score){
      resultRankText = currentRank.rankText;
      
    }
  }

  return resultRankText;

}



String convertEPInfoType(int? type){
  String resultEPType = "Ep";
  if(type == null) return resultEPType;

  for(EPType currentType in EPType.values){
    if(currentType.index == type){
      resultEPType = currentType.name;
      break;
    }
  }

  return resultEPType.replaceFirst(resultEPType[0], resultEPType[0].toUpperCase());
}

Future<int> getTotalSizeOfFilesInDir(final FileSystemEntity fileSystemEntity) async {
  if (fileSystemEntity is File && fileSystemEntity.existsSync()) {
    return await fileSystemEntity.length();
  }
  
  if (fileSystemEntity is Directory && fileSystemEntity.existsSync()) {
    List children = fileSystemEntity.listSync();
    int total = 0;
    if (children.isNotEmpty){
      for (final FileSystemEntity child in children) {
        total += await getTotalSizeOfFilesInDir(child);
      }
    }
      
    return total;
  }
  
  return 0;
}

String convertRankBoxStandardDiffusion(int totalVotes, List<dynamic> scoreList,num score){
  double standardDiffusion = 0;

  for (var (index, item) in scoreList.reversed.indexed) {
    standardDiffusion += (10 - index - score) * (10 - index - (score)) * item;
  }

  return sqrt(standardDiffusion / totalVotes).toStringAsFixed(3);
}