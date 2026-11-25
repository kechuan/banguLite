import 'package:bangu_lite/catalogs/subject/bangumi_general_content_page.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/models/informations/subjects/group_topic_details.dart';
@FFAutoImport()
import 'package:bangu_lite/models/informations/subjects/group_topic_info.dart';
@FFAutoImport()
import 'package:bangu_lite/models/providers/groups_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFRoute(name: '/groupTopic')
class BangumiGroupTopicPage extends StatelessWidget {
  const BangumiGroupTopicPage({
    super.key,
    required this.groupsModel,
    required this.groupTopicInfo,
    this.themeColor,
    this.referPostContentID,
    this.sourceTitle,
  });

  final GroupsModel groupsModel;
  final GroupTopicInfo groupTopicInfo;

  final Color? themeColor;
  final int? referPostContentID;
  final String? sourceTitle;

  @override
  Widget build(BuildContext context) {

    return BangumiGeneralContentView<GroupsModel, GroupTopicInfo, GroupTopicDetails>(
      contentModel: groupsModel,
      contentInfo: groupTopicInfo,
      createEmptyDetailData: GroupTopicDetails.empty,
      getWebUrl: (groupTopicID) => BangumiWebUrls.groupTopic(groupTopicID ?? 0),
      postCommentType: PostCommentType.replyGroupTopic,

      themeColor: themeColor,
      sourceTitle: sourceTitle,
      referPostContentID: referPostContentID,

      loadContent: (groupTopicID, {bool isRefresh = false}) {
        return groupsModel.loadContentDetail(
          groupTopicID,
          isRefresh: isRefresh,
          fallbackAction: (message) => showRequestSnackBar(
            message: message,
            requestStatus: false,
            backgroundColor: getCurrentThemeColor(context),
          ),
        );
      },
    );

  }
}
