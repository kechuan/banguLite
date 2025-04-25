import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/group_details.dart';
import 'package:bangu_lite/models/group_topic_details.dart';
import 'package:bangu_lite/models/group_topic_info.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:dio/dio.dart';

//全局Model 
//但适用规则 GroupDetails 基本等于 info 
// 而对于 Detail 来说 其子信息应当是 


class GroupsModel extends BaseModel<GroupTopicInfo,GroupTopicDetails>{

  //仅占位
  GroupsModel({required super.subjectID}){
    loadGroups();
  }

  GroupInfo? selectedGroupInfo;
  
  final Map<BangumiSurfGroupType,List<GroupInfo>> groupsData = {
    BangumiSurfGroupType.all: [],
    BangumiSurfGroupType.joined: [],
    BangumiSurfGroupType.created: [],
  };
  
  Future<bool> loadGroups({ 
    BangumiSurfGroupType mode = BangumiSurfGroupType.all,
    int? limit,
    int? offset,
    Function({String? message})? fallbackAction
  }) async {

    Completer<bool> requestGroupsCompleter = Completer();

    await HttpApiClient.client.get(
      BangumiAPIUrls.groups(),
      queryParameters: BangumiQuerys.groupsQuery(
        mode: mode,
        limit: limit,
        offset: offset,
      )
    ).then((response){
      if(response.statusCode == 200){
        groupsData[mode] = loadGroupsInfo(response.data["data"]);
        requestGroupsCompleter.complete(true);
        notifyListeners();
      }

      else{
        requestGroupsCompleter.complete(false);
        fallbackAction?.call(message:'${response.statusCode} ${response.data["message"]}');
      }
    });

    return requestGroupsCompleter.future;
    
  }


  Future<bool> loadGroupTopics({
    int? offset = 0
  }) async {

    Completer<bool> groupTopicCompleter = Completer();

    if(selectedGroupInfo == null) return false;

    contentListData.clear();

    await loadSubjectSubContentList(
      queryParameters: BangumiQuerys.topicsQuery
        ..["offset"] = offset ?? 0
    ).then((result){
      if(result){
        groupTopicCompleter.complete(true);
      }

      else{
        groupTopicCompleter.complete(false);
      }

      
    });

    return groupTopicCompleter.future;
  }

  @override
  List<GroupTopicInfo> createEmptyInfoList() => [GroupTopicInfo.empty()];
  @override
  GroupTopicDetails createEmptyDetails() => GroupTopicDetails.empty();

  @override
  String getContentListUrl(dynamic subjectID) => BangumiAPIUrls.groupTopics(selectedGroupInfo?.groupName ?? '');
  
  @override
  String getContentDetailUrl(int contentID) => BangumiAPIUrls.groupTopic(contentID);

  @override
  List<GroupTopicInfo> convertResponseToList(Response subContentListResponseData) => loadGroupTopicInfo(
    subContentListResponseData.data["data"],
    groupInfo: selectedGroupInfo

  );
  @override
  GroupTopicDetails convertResponseToDetail(Map<String,dynamic> contentResponseData) => loadGroupTopicDetails(contentResponseData);

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

}