import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/models/informations/subjects/relation_details.dart';
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
  String getContentListUrl(dynamic subjectID) => BangumiAPIUrls.relations(subjectID);
  
}