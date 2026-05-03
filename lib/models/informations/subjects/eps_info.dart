import 'package:bangu_lite/internal/utils/convert.dart';

class EpsInfo {
  EpsInfo({
    this.epID
  });

  int? epID;

  String? airDate;
  String? name;
  String? nameCN;

  String? description;

  num? epIndex;
  num? sort; //同类条目的排序和集数
  
  int? commentLength;

  int? type;

  //上下ID的链表 kana?
  int? nextEpID;
  int? prevEpID;

  factory EpsInfo.empty() => EpsInfo(epID: 0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EpsInfo && other.hashCode == hashCode;
    
  }

  @override
  int get hashCode => epID.hashCode;

}

List<EpsInfo> loadEpsData(List bangumiEpsInfoResponse){
  
  List epsDataList = bangumiEpsInfoResponse;

  List<EpsInfo> currentBangumiEpsInfo = [];

  for(Map currentEpInfoMap in epsDataList){
    EpsInfo currentEpInfo = EpsInfo();

    currentEpInfo
      ..airDate = currentEpInfoMap["airdate"]
      ..name = convertAmpsSymbol(currentEpInfoMap["name"])
      ..nameCN = convertAmpsSymbol(currentEpInfoMap["name_cn"])
      ..epID = currentEpInfoMap["id"]
      ..epIndex = currentEpInfoMap["ep"] ?? currentEpInfoMap["sort"]
      ..sort = currentEpInfoMap["sort"]
      ..type = currentEpInfoMap["type"]
      ..commentLength = currentEpInfoMap["comment"]
      ..description = currentEpInfoMap["desc"]
    ;

      currentBangumiEpsInfo.add(currentEpInfo);
      
  }

  return currentBangumiEpsInfo;
        
}


String convertCollectionName(EpsInfo? currentInfo,num currentEpIndex){
  if(currentInfo==null) return "loading";

  String currentEpType =  convertEPInfoType(currentInfo.type);

  num currentIndex = 
    currentEpIndex == 0 ?
    currentInfo.epID ?? currentEpIndex :
    currentInfo.sort ?? currentEpIndex
  ;
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
