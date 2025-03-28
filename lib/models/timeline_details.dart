
import 'dart:math';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/timeline_const.dart';
import 'package:bangu_lite/models/base_details.dart';


// 广场timeline 与 用户timeline需求数据

class TimelineDetails extends BaseDetails {
  TimelineDetails({
    super.detailID
  });

  int? get timelineID => detailID;
  
  //这里的 UID 是指代的最初始的ID 不是 userName
  int? actionUserUID;

  // int => String
  int? catType;
  int? catAction;
  int? timelineCreatedAt;

  Set<int>? objectIDSet;
  Set<String>? objectNameSet;
  
  //parent Object?
  int? subObjectID;
  //对番剧进行评价 而非 progress更新时 独有的字段
  String? comment;

  //暂且作废 因为字段藏在 [subject][subject]内部
  //Map<int,Set<String>>? commentReactions;


  // progress 更新 4/0
  int? epsUpdate;

  String getActionDescription() {
    String actionText = "把 番剧 ";
    String contentText = "";

    // 根据 catType 和 catAction 获取 actionText
    switch (catType) {
      case 3: // 收藏条目
        contentText = objectNameSet?.first ?? "";
        actionText += "$contentText标记为 ${TimelineCatSubjectSingle.values.firstWhere((element) => element.value == catAction).actionName}";
        break;
      case 4: // 收视进度
      {
        if(catAction == 0){
          contentText += "([url=${BangumiWebUrls.subject(objectIDSet!.first)}]${objectNameSet!.first}[/url]  Ep.$epsUpdate )";
        }

        else if(catAction == 2){
          contentText += '[url=${BangumiWebUrls.ep(objectIDSet!.last)}]${objectNameSet!.last}[/url] ';
          contentText += "([url=${BangumiWebUrls.subject(objectIDSet!.first)}]Ep.$epsUpdate ${objectNameSet!.first}[/url] )";
        }

        else{
          contentText = objectNameSet?.first ?? "";
          
          
        }

        //actionText += "$contentText更新为 Ep. $epsUpdate";
        actionText += contentText;

        break;

      }
       
      // 其他 catType 的处理逻辑可以继续添加
      default:
        actionText = "未知行为";
    }

    return actionText;
  }
}


List<TimelineDetails> loadTimelineDetails(List bangumiTimelineListData){

  List<TimelineDetails> timelineDetailsList = [];

  for(var bangumiTimelineData in bangumiTimelineListData){
    final resultFields = extractBaseFields(bangumiTimelineData['memo']);

    TimelineDetails timelineDetails = TimelineDetails(
      detailID: bangumiTimelineData['id'],
    );

    timelineDetails
      ..actionUserUID = bangumiTimelineData['uid']
      ..catType = bangumiTimelineData['cat']
      ..catAction = bangumiTimelineData['type']
      ..timelineCreatedAt = bangumiTimelineData['createdAt']
      ..objectIDSet = resultFields['objectIDSet']
      ..objectNameSet = resultFields['objectNameSet']
      ..epsUpdate = resultFields['epsUpdate'] ?? resultFields['sort']
      //..subObjectID = resultFields['subContentID']
      //..commentReactions = loadReactionDetails(reactionListData)
    ;

    timelineDetailsList.add(timelineDetails);
  }

  return timelineDetailsList;
}

String convertTimelineDescription(TimelineDetails currentTimeline, {bool? authorDeclared}){
  String resultText = "TA ";

  String actionText = "";
  String contentText = "";
  String suffixText = "";
	
  /// 那么首先 划定 action 字段 行为
  switch(currentTimeline.catType){
   
    //人物/日志/目录
    case 6:case 7: { actionText+="添加了 "; break;}

    default: { 

        List currentType = timelineEnums.elementAt(currentTimeline.catType!-1);

        for(var currentSegment in currentType){
          if(currentSegment.value == currentTimeline.catAction){
            actionText += '${currentSegment.actionName} ';
            break;
          }
        }

    }

  }


  //然后是内容字段
  switch(currentTimeline.catType){
    case 3: {
      contentText += convertSubjectTimeline(currentTimeline.objectIDSet,currentTimeline.objectNameSet);
      break;
    }

    case 4:{
      //牵扯到 epsUpdate
      contentText += convertSubjectTimeline(
        currentTimeline.objectIDSet,
        currentTimeline.objectNameSet,
        ep: currentTimeline.epsUpdate,
        cat: currentTimeline.catType,
        action: currentTimeline.catAction
      ) ;
    }
  }

  resultText += actionText;
  resultText += contentText;

  if(suffixText.isNotEmpty) resultText+=suffixText;


  return resultText;
}

Map<String, dynamic> extractBaseFields(Map<String, dynamic> data) {
  final resultFields = <String, dynamic>{};

  const detectIDList = [
    'id',
    'subjectID',
  ];

  const detectNameList = [
    'name',
    'nameCN',
    'title',
  ];

  const detectPropList = [
    'epsUpdate',
    'sort',
    'reactions'
  ];

  Set<int> objectIDSet = {};
  Set<String> objectNameSet = {};

  void recursiveExtract(Map<String, dynamic> map) {
    for (final entry in map.entries) {
      final key = entry.key;
      final value = entry.value;

      if (detectNameList.contains(key)) {
        
          if(key == 'name' || key == 'nameCN'){

            String resultText = 
              map["name"].isEmpty ? 'ep.${map["sort"]}' : 
                map["nameCN"].isEmpty ? map["name"] : map["nameCN"];

            objectNameSet.addAll({resultText});
          }

          else{
            objectNameSet.addAll({value});
          }
      }

      else if(detectIDList.contains(key)){
        int resultID = map[key];
        objectIDSet.addAll({resultID});

      }
      
      else if(detectPropList.contains(key)){
        resultFields[key] = value;
      }

      else if (value is Map<String, dynamic>) {
        recursiveExtract(value);
      } 

      else if (value is List) {
        for (final item in value) {
          if (item is Map<String, dynamic>) {
            recursiveExtract(item);
          }
        }
      }
    }

    resultFields['objectIDSet'] = objectIDSet;
    resultFields['objectNameSet'] = objectNameSet;


  }

  recursiveExtract(data);
  return resultFields;
}


//TODO Mono尚未完成 / 完成动作尚未完成
String convertSubjectTimeline(

  Set<int>? objectIDSet,
  Set<String>? objectNameSet,
  {
    int? ep,
    int? cat,
    int? action
  }
){
  String subjectTimelineText = "";

  if(objectIDSet == null || objectNameSet == null) return subjectTimelineText;

  //注意 如果ep值被提供 则说明 可能存在 ID对多的name 这取决于当时为 single 亦或者是 batch
  // single 时 则为 子夫 4/2
  // batch 则仅有 父 4/0

  if(cat == 4 && action == 2){
     subjectTimelineText += '[url=${BangumiWebUrls.subject(objectIDSet.last)}]${objectNameSet.last}[/url] ';
     subjectTimelineText += "( [url=${BangumiWebUrls.ep(objectIDSet.first)}]Ep.$ep ${objectNameSet.first}[/url] )";
  } 

  else if(cat == 4 && action == 0){
    subjectTimelineText += "( [url=${BangumiWebUrls.subject(objectIDSet.first)}]${objectNameSet.first}[/url]  Ep.$ep )";
  }

  else{

    for(int index=0;index<min(5,objectNameSet.length);index++){
      int jumpID = objectIDSet.elementAt(index);
      String jumpName = objectNameSet.elementAt(index);

      subjectTimelineText += '[url=${BangumiWebUrls.subject(jumpID)}]$jumpName[/url] ';
    }

    if(objectNameSet.length>5) subjectTimelineText += '等 ${objectNameSet.length} 部番剧...';
  }

   

  return subjectTimelineText;
}

