//仅限小组页面使用

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/group_topic_details.dart';
import 'package:bangu_lite/models/group_topic_info.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:dio/dio.dart';

class GroupTopicsModel extends BaseModel<GroupTopicInfo,GroupTopicDetails>{
  GroupTopicsModel({required super.subjectID})  {
     loadGroupTopics();
  }

  Future<void> loadGroupTopics({int? offset = 0}) async {
    await loadSubjectSubContentList(
      queryParameters: BangumiQuerys.topicsQuery
        ..["offset"] = offset ?? 0
    );
  }

  //final Map<int,GroupTopicDetails> groupsData = {};

  // Future<void> loadGroupTopics({ 
  //  BangumiSurfGroupType mode = BangumiSurfGroupType.all,
  //  int? offset
  //}) async {
  //  await loadSubjectSubContentList(
  //    queryParameters: BangumiQuerys.groupTopicQuery..["offset"] = offset ?? 0
  //  );
  //}

  @override
  List<GroupTopicInfo> createEmptyInfoList() => [GroupTopicInfo.empty()];
  @override
  GroupTopicDetails createEmptyDetails() => GroupTopicDetails.empty();
  
  @override
  //String getContentDetailUrl(int contentID) => BangumiAPIUrls.userBlog(selectedBlogID);
  String getContentDetailUrl(int contentID) => BangumiAPIUrls.userBlog(contentID);
  @override
  List<GroupTopicInfo> convertResponseToList(Response subContentListResponseData) => loadGroupTopicInfo(subContentListResponseData.data);
  @override
  GroupTopicDetails convertResponseToDetail(Map<String,dynamic> contentResponseData) => loadGroupTopicDetails(contentResponseData);

  @override
  String getContentListUrl(dynamic subjectID) => BangumiAPIUrls.groupTopics(subjectID);

  



  

  

  

}