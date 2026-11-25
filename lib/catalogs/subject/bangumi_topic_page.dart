import 'package:bangu_lite/catalogs/subject/bangumi_general_content_page.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/models/informations/subjects/topic_details.dart';
import 'package:bangu_lite/models/informations/subjects/topic_info.dart';
@FFAutoImport()
import 'package:bangu_lite/models/providers/topic_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFRoute(name: '/subjectTopic')
class BangumiTopicPage extends StatelessWidget {
  const BangumiTopicPage({
    super.key,
    required this.topicModel,

    /// 为什么不直接传递 Index：
    /// 因为也有透过 urlLink 直接打开单个 Info 的情况，此时 Index 无意义。
    required this.topicInfo,
    this.themeColor,
    this.referPostContentID,

    // 因为 API 返回 Topic/Blog 时未携带来源标题，由上游传入
    this.sourceTitle,
  });

  final TopicModel topicModel;
  final TopicInfo topicInfo;

  final Color? themeColor;
  final int? referPostContentID;
  final String? sourceTitle;

  @override
  Widget build(BuildContext context) {

    return BangumiGeneralContentView<TopicModel, TopicInfo, TopicDetails>(
      contentModel: topicModel,
      contentInfo: topicInfo,
      createEmptyDetailData: TopicDetails.empty,
      getWebUrl: (topicID) => BangumiWebUrls.subjectTopic(topicID ?? 0),
      postCommentType: PostCommentType.replyTopic,

      themeColor: themeColor,
      sourceTitle: sourceTitle,
      referPostContentID: referPostContentID,

      loadContent: (topicID, {bool isRefresh = false}) {
        return topicModel.loadContentDetail(
          topicID,
          isRefresh: isRefresh,
          fallbackAction: (message) {
            showRequestSnackBar(
              message: message,
              requestStatus: false,
              backgroundColor: getCurrentThemeColor(context),
            );
          },
        );
      },
    );

  }
}
