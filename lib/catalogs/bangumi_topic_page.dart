import 'package:bangu_lite/catalogs/bangumi_general_content_page.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/topic_details.dart';
import 'package:bangu_lite/models/topic_info.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/topic_model.dart';

@FFRoute(name: '/subjectTopic')
class BangumiTopicPage extends StatefulWidget {
  const BangumiTopicPage({
    super.key,
    required this.topicModel,
	  required this.topicInfo
  });

  final TopicModel topicModel;
  final TopicInfo topicInfo;

  @override
  State<BangumiTopicPage> createState() => _BangumiTopicPageState();
}

class _BangumiTopicPageState extends BangumiContentPageState 
<
	BangumiTopicPage,
	TopicModel,
	TopicInfo,
	TopicDetails
>{

  @override
  TopicInfo getContentInfo() => widget.topicInfo;

  @override
  TopicModel getContentModel() => widget.topicModel;

  @override
  TopicDetails createEmptyDetailData() => TopicDetails.empty();

  @override
  int? getCommentCount(TopicDetails? contentDetail, bool isLoading){
    if(!isContentLoading(contentDetail?.topicID)){
      if(contentDetail?.topicID != null){
        return contentDetail!.topicRepliedComment!.isEmpty ? 0 : contentDetail.topicRepliedComment!.length;
      }
    }
    return null;
  }

  @override
  String getWebUrl(int? topicID) => BangumiWebUrls.subjectTopic(topicID ?? 0);

  @override
  Future<void> loadContent(int topicID) => getContentModel().loadContentDetail(topicID);
  
}
