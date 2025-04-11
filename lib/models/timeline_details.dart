
import 'dart:math';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/bangumi_define/timeline_const.dart';
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

Map<String, dynamic> extractBaseFields(Map<String, dynamic> data) {
  final resultFields = <String, dynamic>{};

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
    ;

    timelineDetailsList.add(timelineDetails);
  }

  return timelineDetailsList;
}

String convertTimelineDescription(TimelineDetails currentTimeline, {bool? authorDeclared}){

  String leadingText = "";
  String undoActionText = "";
  String actionText = "";
  String contentText = "";

  //待用字段
  String suffixText = "";
	
  /// 那么首先 划定 action 字段 行为
  switch(currentTimeline.catType){
   
    //人物/日志/目录
    case 6:
    case 7: { actionText+="添加了 "; break;}

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

    default :{
      contentText += convertDefaultTimeline(
        currentTimeline.objectIDSet,
        currentTimeline.objectNameSet,
        cat: currentTimeline.catType,
        action: currentTimeline.catAction
      );
    }


  }

  if(contentText.isEmpty) undoActionText += "撤销了一项 ";

  leadingText += undoActionText + actionText + contentText + suffixText;

  return leadingText;
}

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

    final List<String> timelineTextList = [];

    for(int index=0;index<min(5,objectNameSet.length);index++){
      int jumpID = objectIDSet.elementAt(index);
      String jumpName = objectNameSet.elementAt(index);

      timelineTextList.add('[url=${BangumiWebUrls.subject(jumpID)}]$jumpName[/url]');

    }

    subjectTimelineText += timelineTextList.join("、");

    if(objectNameSet.length>5) subjectTimelineText += '...等 ${objectNameSet.length} 部作品';
  }

   

  return subjectTimelineText;
}

//xxx 对谁 做了 什么事
String convertDefaultTimeline(
  Set<int>? objectIDSet,
  Set<String>? objectNameSet,
  {
    int? cat,
    int? action
  }
){
  String defaultTimelineText = "";

  if(objectIDSet == null || objectNameSet == null) return defaultTimelineText;
  if(objectNameSet.isEmpty || objectIDSet.isEmpty) return defaultTimelineText;

  String jumpLink = "";

  //大部分实则指向的都是 subject 少部分会指向 wiki/user/doujin 这种东西

  switch(cat){
    case 1: {

      if(action == TimelineCatDaily.AddFriend.value){
        jumpLink = BangumiWebUrls.user(objectIDSet.first.toString());
      }

      else if(action == TimelineCatDaily.JoinGroup.value || action == TimelineCatDaily.CreateGroup.value){
        jumpLink = "这里是群组ID:${objectIDSet.first}";
      }

      else if (action == TimelineCatDaily.JoinParadise.value){
        jumpLink = "这里是乐园ID:${objectIDSet.first}";
      }

    }

    case 5:{
      if(action == TimelineCatStatus.Comment.value){
        jumpLink = "这里是被吐槽的ID:${objectIDSet.first}";
      }
    }

    case 8:{

      jumpLink = BangumiWebUrls.character(objectIDSet.first);

      //if(action == TimelineCatMono.Created.value){
      //  jumpLink = BangumiWebUrls.character(objectIDSet.first);
      //}

      //if(action == TimelineCatMono.Collected.value){
      //  jumpLink = BangumiWebUrls.person(objectIDSet.first);
      //}
      
    }

    case 9:{
      if(
        action == TimelineCatDoujin.AddWork.value || 
        action == TimelineCatDoujin.CollectWork.value
      ){
        jumpLink = "这里是作品ID:${objectIDSet.first}";
      }

      else if(
        action == TimelineCatDoujin.CreateClub.value ||
         action == TimelineCatDoujin.FollowClub.value
      ){
        jumpLink = "这里是社团ID:${objectIDSet.first}";
      }

      else if(
        action == TimelineCatDoujin.FollowEvent.value ||
        action == TimelineCatDoujin.JoinEvent.value
      ) {
        jumpLink = "这里是活动ID:${objectIDSet.first}";
      }


    }

    default:{
      jumpLink = BangumiWebUrls.subject(objectIDSet.first);
    }
    
  }

  if(objectNameSet.isNotEmpty){

    final List<String> timelineTextList = [];
  
    for(int index=0;index<min(5,objectNameSet.length);index++){
      String jumpName = objectNameSet.elementAt(index);

      timelineTextList.add('[url=$jumpLink]$jumpName[/url]');

      
    }

    defaultTimelineText += timelineTextList.join("、");

    if(objectNameSet.length>5) defaultTimelineText += '...等 ${objectNameSet.length} 个条目';

  }


  return defaultTimelineText;
}
