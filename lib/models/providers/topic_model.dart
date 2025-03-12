import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/models/topic_details.dart';
import 'package:bangu_lite/models/topic_info.dart';
import 'package:dio/dio.dart';

class TopicModel extends BaseModel<TopicInfo, TopicDetails> {
  TopicModel({
    required super.subjectID
  }){
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
  List<TopicInfo> createEmptyInfoList() => [TopicInfo.empty()];
  @override
  TopicDetails createEmptyDetails() => TopicDetails.empty();
  @override
  String getContentListUrl(int subjectID) => BangumiAPIUrls.topics(subjectID);
  @override
  String getContentDetailUrl(int contentID) => BangumiAPIUrls.topicComment(contentID);
  @override
  List<TopicInfo> convertResponseToList(Response subContentListResponseData) => loadTopicsInfo(subContentListResponseData);
  @override
  TopicDetails convertResponseToDetail(Map<String,dynamic> contentResponseData) => loadTopicDetails(contentResponseData);

}