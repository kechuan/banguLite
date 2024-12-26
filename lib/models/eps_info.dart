import 'package:bangu_lite/internal/convert.dart';
import 'package:dio/dio.dart';

class EpsInfo {
  String? airDate;
  String? name;
  String? nameCN;

  String? description;

  int? epIndex;
  num? sort; //同类条目的排序和集数
  int? epID;
  int? commentLength;

  int? type;

}

List<EpsInfo> loadEpsData(Response bangumiEpsInfoResponse){
  
  List epsDataList = bangumiEpsInfoResponse.data["data"];

  List<EpsInfo> currentBangumiEpsInfo = [];

  for(Map currentEpInfoMap in epsDataList){
    EpsInfo currentEpInfo = EpsInfo();

    currentEpInfo
      ..airDate = currentEpInfoMap["airdate"]
      ..name = currentEpInfoMap["name"]
      ..nameCN = currentEpInfoMap["name_cn"]
      ..epID = currentEpInfoMap["id"]
      ..epIndex = currentEpInfoMap["ep"]
      ..sort = currentEpInfoMap["sort"]
      ..type = currentEpInfoMap["type"]
      ..commentLength = currentEpInfoMap["comment"]
      ..description = currentEpInfoMap["desc"]
    ;

      currentBangumiEpsInfo.add(currentEpInfo);
      
  }

  return currentBangumiEpsInfo;
        
}

String convertCollectionName(EpsInfo? currentInfo,int currentEpIndex){
  if(currentInfo==null) return "loading";

  String currentEpType = convertEPInfoType(currentInfo.type);
  num currentIndex = currentInfo.sort ?? currentEpIndex;
  String currentEpText = currentInfo.nameCN ?? currentInfo.name ?? ""; 

  return "$currentEpType. $currentIndex ${currentEpText.isEmpty ? currentInfo.name : currentEpText}";
}

enum EPType{
  ep(), //本篇
  sp(),
  op(),
  ed(),
  ad(),
  mad(),
  other();

  const EPType();
  
}
