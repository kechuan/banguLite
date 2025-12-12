import 'package:bangu_lite/catalogs/subject/bangumi_general_content_page.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/topic_details.dart';
import 'package:bangu_lite/models/informations/subjects/topic_info.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/topic_model.dart';

@FFRoute(name: '/subjectTopic')
class BangumiTopicPage extends StatefulWidget {
  const BangumiTopicPage({
    super.key,
    required this.topicModel,
	  required this.topicInfo,
    this.themeColor,
    this.referPostContentID,

    //因为API数据返回 Topic/Blog 的时候并没有携带这种数据 只能自己手动传过来了..
    this.sourceTitle
  });

  final TopicModel topicModel;
  final TopicInfo topicInfo;
  final Color? themeColor;
  final int? referPostContentID;

  final String? sourceTitle;

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
  String? sourceTitle() => widget.sourceTitle;

  @override
  TopicInfo getContentInfo() => widget.topicInfo;

  @override
  TopicModel getContentModel() => widget.topicModel;

  @override
  Color? getcurrentSubjectThemeColor() => widget.themeColor;

  @override
  TopicDetails createEmptyDetailData() => TopicDetails.empty();

  @override
  PostCommentType? getPostCommentType() => PostCommentType.replyTopic;


  /// API 把 主楼信息的 content 也归类为 Replies内 也就是 Replies.first
  /// 按道理来说 是不可能会出现 .isEmpty 的情况的
  /// 隔壁的 GroupTopic 的数据也是如此
  @override
  int? getCommentCount(TopicDetails? contentDetail, bool isLoading){

    if(!isContentLoading(contentDetail?.topicID)){
      if(contentDetail?.topicID != null){
        return contentDetail!.topicRepliedComment?.length ?? 0;
      }
    }

    return null;
  }

  @override
  String getWebUrl(int? topicID) => BangumiWebUrls.subjectTopic(topicID ?? 0);

  @override
  Future<void> loadContent(int topicID,{bool isRefresh = false}){
    return getContentModel().loadContentDetail(
      topicID,
      isRefresh:isRefresh,
      fallbackAction: (message) {
        showRequestSnackBar(
          message: message,
          requestStatus: false,
          backgroundColor: judgeCurrentThemeColor(context)
        );
      },
    );
  }

  

  @override
  int? getReferPostContentID() => widget.referPostContentID;
  
}
