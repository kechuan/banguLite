import 'package:bangu_lite/catalogs/subject/bangumi_general_content_page.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/request_client.dart';


import 'package:bangu_lite/models/group_topic_details.dart';

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/groups_model.dart';

@FFAutoImport()
import 'package:bangu_lite/models/group_topic_info.dart';

@FFRoute(name: '/groupTopic')
class BangumiGroupTopicPage extends StatefulWidget {
  const BangumiGroupTopicPage({
    super.key,
    required this.groupsModel,
    required this.groupTopicInfo,
    //required this.index,
    this.themeColor
  });

  final GroupsModel groupsModel;
  final GroupTopicInfo groupTopicInfo;
  final Color? themeColor;

  @override
  State<BangumiGroupTopicPage> createState() => _BangumiGroupTopicPageState();
}

class _BangumiGroupTopicPageState extends BangumiContentPageState 
<
	BangumiGroupTopicPage,
	GroupsModel,
	GroupTopicInfo,
	GroupTopicDetails
>{

  @override
  GroupTopicInfo getContentInfo() => widget.groupTopicInfo;

  @override
  GroupsModel getContentModel() => widget.groupsModel;

  @override
  Color? getcurrentSubjectThemeColor() => widget.themeColor;

  @override
  GroupTopicDetails createEmptyDetailData() => GroupTopicDetails.empty();

  @override
  PostCommentType? getPostCommentType() => PostCommentType.replyGroupTopic;

  @override
  int? getCommentCount(GroupTopicDetails? contentDetail, bool isLoading){
    if(!isContentLoading(contentDetail?.groupTopicID)){
      if(contentDetail?.groupTopicID != null){
        return contentDetail!.contentRepliedComment?.length ?? contentDetail.topicReplyCount;
      }
    }
    return null;
  }

  @override
  int? getSubContentID() => getContentInfo().topicInfo?.topicID;

  @override
  String getWebUrl(int? groupTopicID) => BangumiWebUrls.groupTopic(groupTopicID ?? 0);

  @override
  Future<void> loadContent(int groupTopicID) => getContentModel().loadContentDetail(groupTopicID);
  
}
