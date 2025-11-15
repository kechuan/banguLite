
import 'dart:io';
import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/informations/subjects/eps_info.dart';

List<String> convertSystemFontFamily() {
    if (Platform.isAndroid) {
      return ['sans-serif'];
    } 
    
    else if (Platform.isIOS) {
      return ['System'];
    }

    else if (Platform.isWindows) {
      return ['MiSans','Microsoft YaHei'];
    }
    
    else {
      return ['Roboto'];
    }
  }

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

String convertDecimalDigitNumString(num originalNumber, {int numberBits = 2}){

  String fillingContent = '.';

  if(originalNumber.toString().length > (numberBits-1)){
    return '$originalNumber';
  }

  else{
    for(numberBits; numberBits>1; numberBits--){
      fillingContent+='0';
    }

    return '$originalNumber$fillingContent';
  }

}

int convertStickerDatalike(int dataLikeIndex){

  //我也不知道为什么别人前端的里 大部分 data-like-value 的差异都是39 就只有 0 指向的是 44
  //data-like-value = 0 => "/img/smiles/tv/44.gif"
  //至于为什么是+23 那就是因为 bgm 与 tv 包的差异了 bgm包刚好是23个表情 因此偏移23
  
  //但唯有 0 dataLikeIndex 是需求增加 
  //而其他的 dataLikeIndex 都是 减少偏移数值

  //而对于 200/500 的新版本 谢天谢地是直接数值
  if(dataLikeIndex >= 200) return dataLikeIndex;

  int stickerIndex = dataLikeIndex - 39 + 23;
      
          
  if(dataLikeIndex == 0){
    stickerIndex = dataLikeIndex + 44 + 23; 
  }

  return stickerIndex;
}

String convertBangumiStickerPath(int stickerIndex){

  String authorPath = "";

  switch(stickerIndex){
    case <= 23: {
      authorPath = "01-23 dsm";
      break;
    }
      
    case <= 125: {
      authorPath = "24-125 Cinnamor";
      break;
    }
    
    case <= 238: {
      authorPath = "200-238 神戶小鳥";
      break;
    }

    case <= 529: {
      authorPath = "500-529 五行行行行行啊";
      break;
    }
      
  }

  return "assets/bangumiSticker/$authorPath/bgm${convertDigitNumString(stickerIndex)}.gif";
}

String convertBangumiCommentSticker(String originalComment){
  RegExp stickerMatch = RegExp(r'(\()+bgm+(\d{2,3})(\))');
  
  String mappedComment = originalComment.replaceAllMapped(
    stickerMatch, 
    (match){

      String replaceTag = "sticker";

      List<String?> resultList = [];
      
      for(String? currentPattern in match.groups([1,2,3])){
        switch(currentPattern){
          case '(': resultList.add("[$replaceTag]"); break;
          case ')': resultList.add("[/$replaceTag]"); break;
          //default: resultList.add("assets/bangumiSticker/bgm${match.group(2)}.gif");
          default: resultList.add(convertBangumiStickerPath(int.parse(match.group(2)!)));
        }
      }

      return resultList.join();

      
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

  bool isAired = convertDateTime(bangumiDate).isBefore(DateTime.now());

  if(!isAired) return 0;



	int residualDateTime = (DateTime.now().millisecondsSinceEpoch - convertDateTime(bangumiDate).millisecondsSinceEpoch);

	//放送开始附带一集 因此+1
	int airedEps = (residualDateTime ~/ const Duration(days: 7).inMilliseconds) + 1;

	return airedEps;
}

int convertPassedSeason(int year,int month){
  DateTime currentTime = DateTime.now();

  if(year < currentTime.year) {return 4;} 
  
  else if(year > currentTime.year) {return 0;}

  else{
    return judgeSeasonRange(month,currentTime: true).index;
  }

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

String covertPastDifferentTime(int? timeStamp){

  
  String resultText = "";

  if(timeStamp == null) return resultText;

  final currentTime = DateTime.now();

  final int = currentTime.difference(DateTime.fromMillisecondsSinceEpoch(timeStamp*1000)).inMinutes;

  if(int < 60){
    resultText = "$int分钟前";
  }
  
  else if(int < 60 * 24){
    resultText = "${int~/60}小时前";
  }
  
  else if(int < 60 * 24 * 7){
    resultText = "${int~/(60 * 24)}天前";
  }
  
  else if(int < 60 * 24 * 30){
    resultText = "${int~/(60 * 24 * 7)}周前";
  }

  else if(int < 60 * 24 * 30 * 12){
    resultText = "${int~/(60 * 24 * 30)}月前";
  }

  else if(int < 60 * 24 * 30 * 12 * 10){
    resultText = "${int~/(60 * 24 * 30 * 12)}年前";
  }


  return resultText;
}

String convertInsertContent({String originalText = '',String insertText = '',int insertOffset = 0}){
  StringBuffer buffer = StringBuffer();
  buffer.write(originalText.substring(0, insertOffset)); // 写入前半部分
  buffer.write(insertText); // 插入内容
  buffer.write(originalText.substring(insertOffset)); // 写入后半部分

  return buffer.toString();
}

String convertProxyImageUri(String imageLink){ 
  Uri imageUri = Uri.parse(imageLink);
  return "${APPInformationRepository.banguLiteImageForwardUri}${imageUri.host}${imageUri.path}";
}


