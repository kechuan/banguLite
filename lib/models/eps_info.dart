import 'package:dio/dio.dart';

class EpsInfo {
  String? airDate;
  String? name;
  String? nameCN;

  String? description;

  int? epIndex;
  int? epID;
  int? commentLength;

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
      ..commentLength = currentEpInfoMap["comment"]
      ..description = currentEpInfoMap["desc"];

      currentBangumiEpsInfo.add(currentEpInfo);
      
  }

  return currentBangumiEpsInfo;
        
}