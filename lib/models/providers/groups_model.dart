import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/group_details.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:dio/dio.dart';

class GroupsModel extends BaseModel<GroupDetails,Null>{
  GroupsModel({
    required super.subjectID
  }){
    loadGroups();
  }

  Future<void> loadGroups({
    BangumiSurfGroupType mode = BangumiSurfGroupType.all,
    int? limit,
    int? offset
  }) async {
    await loadSubjectSubContentList(
      queryParameters: BangumiQuerys.groupsTopicsQuery(
        mode: mode,
        limit: limit,
        offset: offset,
      )
    );
  }

  @override
  String getContentListUrl(int subjectID) => BangumiAPIUrls.groups();

  @override
  List<GroupDetails> convertResponseToList(Response subContentListResponseData) => loadGroupDetails(subContentListResponseData.data);

  @override
  List<GroupDetails> createEmptyInfoList() => [GroupDetails.empty()];



}