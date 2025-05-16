
//import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
//import 'package:bangu_lite/internal/request_client.dart';
//import 'package:bangu_lite/models/informations/comment_details.dart';
//import 'package:bangu_lite/models/informations/surf/timeline_chat_details.dart';
//import 'package:bangu_lite/models/providers/base_model.dart';
//import 'package:dio/dio.dart';

// 相关条目 不存在后续的数据
//class TimelineChatModel extends BaseModel<TimelineChatDetails,Null>{

//  TimelineChatModel({
//    required super.subjectID
//  }){
//    loadTimelineChat();
//  }

//  EpCommentDetails? authorComment;

//  Future<void> loadAuthorComment() async {
//    if(authorComment != null) return;

//    final authorCommentResponse = await HttpApiClient.client.get(
//      BangumiAPIUrls.timelineReply(subjectID)
//    );

//    authorComment = loadEpCommentDetails(authorCommentResponse.data)[0];
//  }

//  Future<void> loadTimelineChat({
//    int? timelineID
//  }) async {
//	if(timelineID == null || timelineID == 0) return;

//    await loadSubjectSubContentList();
//  }
  
//  @override
//  List<TimelineChatDetails> convertResponseToList(Response subContentListResponseData) => loadTimelineChatDetails(subContentListResponseData.data);

//  @override
//  List<TimelineChatDetails> createEmptyInfoList() => [TimelineChatDetails.empty()];

//  @override
//  String getContentListUrl(dynamic subjectID) => BangumiAPIUrls.timelineReply(subjectID);
  
//}