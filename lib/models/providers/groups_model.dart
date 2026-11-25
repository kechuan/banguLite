import 'dart:io';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/template.dart';
import 'package:bangu_lite/models/informations/subjects/group_details.dart';
import 'package:bangu_lite/models/informations/subjects/group_topic_details.dart';
import 'package:bangu_lite/models/informations/subjects/group_topic_info.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:dio/dio.dart';

//全局Model 
//但适用规则 GroupDetails 基本等于 info 
// 而对于 Detail 来说 其子信息应当是 

class GroupsModel extends BaseModel<String?, GroupTopicInfo, GroupTopicDetails>{

  //仅占位
  GroupsModel({
    super.subjectID = 'groups',
    this.selectedGroupInfo
  }){

    if (selectedGroupInfo?.groupName == null) {
      loadGroups();
    }

  }

  GroupInfo? selectedGroupInfo;

  final Map<BangumiSurfGroupType, List<GroupInfo>> groupsData = {
    BangumiSurfGroupType.all: [],
    BangumiSurfGroupType.joined: [],
    BangumiSurfGroupType.created: [],
  };

  Future<bool> loadGroups({ 
    BangumiSurfGroupType mode = BangumiSurfGroupType.all,
    int? limit,
    int? offset,
    Map<String, String>? accessQuery,
    Function(String)? fallbackAction
  }) async {

    try {
      final response = await HttpApiClient.client.get(
        BangumiAPIUrls.groups(),
        queryParameters: BangumiQuerys.groupsQuery(
          modeName: mode == BangumiSurfGroupType.created ? "managed" : mode.name,
          limit: limit,
          offset: offset,
        ),
        options: Options(headers: accessQuery),
      );

      if (response.statusCode == HttpStatus.ok) {
        if (offset == 0) {
          groupsData[mode] = loadGroupsInfo(response.data["data"]);
        } else {
          groupsData[mode]!.addAll(loadGroupsInfo(response.data["data"]));
        }

        notifyListeners();
        return true;
      }

      fallbackAction?.call('${response.statusCode} ${response.data is Map ? response.data["message"] : response.statusMessage}');
      return false;
    } on DioException catch (e) {
      fallbackAction?.call('${e.response?.statusCode} ${extractDioException(e)}');
      return false;
    }
  }

  Future<bool> loadGroupTopics({
    int? offset = 0,
  }) async {

    if (selectedGroupInfo == null) return false;

    return await loadSubjectContentList(
      isReloaded: offset == 0,
      queryParameters: BangumiQuerys.topicsQuery
      ..["offset"] = offset ?? 0
    );
  }

  @override
  List<GroupTopicInfo> createEmptyInfoList() => [GroupTopicInfo.empty()];

  @override
  GroupTopicDetails createEmptyDetails() => GroupTopicDetails.empty();

  @override
  String getContentListUrl(String? subjectID) => BangumiAPIUrls.groupTopics(selectedGroupInfo?.groupName ?? subjectID ?? '');

  @override
  String getContentDetailUrl(int contentID) => BangumiAPIUrls.groupTopic(contentID);

  @override
  List<GroupTopicInfo> convertResponseToList(Response subContentListResponseData) => loadGroupTopicInfo(
    subContentListResponseData.data["data"],
    groupInfo: selectedGroupInfo

  );
  @override
  GroupTopicDetails convertResponseToDetail(Map<String, dynamic> contentResponseData) => loadGroupTopicDetails(contentResponseData);

  /// 外部(列表追加动画完成后)需要让依赖 groupsData/contentListData 的组件刷新时调用
  void notifyGroupDataChanged() => notifyListeners();

}
