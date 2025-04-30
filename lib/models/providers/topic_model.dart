import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/models/topic_details.dart';
import 'package:bangu_lite/models/topic_info.dart';
import 'package:dio/dio.dart';

class TopicModel extends BaseModel<TopicInfo, TopicDetails> {
  TopicModel({
    required super.subjectID
  }){
    if(subjectID == 'topic') return;
    loadSubjectTopics();
  }

  Future<void> loadSubjectTopics({int? offset = 0}) async {
    await loadSubjectSubContentList(
      queryParameters: BangumiQuerys.topicsQuery
        ..["offset"] = offset ?? 0
    );
  }

  Future<void> loadTopic(int topicID) async => await loadContentDetail(topicID);

  @override
  createEmptyInfoList() => [TopicInfo.empty()];
  @override
  TopicDetails createEmptyDetails() => TopicDetails.empty();
  @override
  String getContentListUrl(dynamic subjectID) => BangumiAPIUrls.topic(subjectID);
  @override
  String getContentDetailUrl(int contentID) => BangumiAPIUrls.topicComment(contentID);
  @override
  convertResponseToList(Response subContentListResponseData) => loadTopicsInfo(subContentListResponseData.data["data"]);
  @override
  TopicDetails convertResponseToDetail(Map<String,dynamic> contentResponseData) => loadTopicDetails(contentResponseData);

}