import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/models/relation_details.dart';
import 'package:dio/dio.dart';

/// 相关条目 不存在后续的数据
class RelationModel extends BaseModel<RelationDetails,Null>{

  RelationModel({
    required super.subjectID
  }){
    loadSubjectRelations();
  }

  Future<void> loadSubjectRelations({
    SubjectType type = SubjectType.anime,
    int offset = 0
  }) async {
    await loadSubjectSubContentList(
      queryParameters: BangumiQuerys.relationsQuery
        ..["type"] = type.subjectType
        ..["offset"] = offset
    );
  }
  
  @override
  List<RelationDetails> convertResponseToList(Response subContentListResponseData) => loadRelationDetails(subContentListResponseData.data);

  @override
  List<RelationDetails> createEmptyInfoList() => [RelationDetails.empty()];

  @override
  String getContentListUrl(int subjectID) => BangumiAPIUrls.relations(subjectID);
  
  @override
  String getContentDetailUrl(int contentID) => "";
  
}