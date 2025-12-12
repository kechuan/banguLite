
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/catalogs/subject/bangumi_general_more_content_page.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/topic_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/informations/subjects/topic_info.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/topic_model.dart';

@FFRoute(name: '/moreTopics')
class MoreTopicsPage extends StatefulWidget {
  const MoreTopicsPage({
    super.key,
    
    required this.topicModel,
    this.bangumiThemeColor,
    this.title
  });

  final String? title;
  final Color? bangumiThemeColor;
  final TopicModel topicModel;

  @override
  State<MoreTopicsPage> createState() => MoreTopicsPageState();
}

class MoreTopicsPageState extends BangumiGeneralMoreContentPageState
<
  MoreTopicsPage,
  TopicModel,
  TopicInfo
>{

  @override
  TopicModel getContentModel() => widget.topicModel;
  
  @override
  Future<void> loadSubjectTopics({int? offset})=> getContentModel().loadSubjectTopics(offset: offset);

  @override
  String? get title => '讨论版块: ${widget.title}';

  @override
  Color? get bangumiThemeColor => widget.bangumiThemeColor;

  @override
  Function(int index)? get onTap => (index){
    Navigator.pushNamed(
      context,
        Routes.subjectTopic,
        arguments: {
          "topicModel":getContentModel(),
          "topicInfo":getContentModel().contentListData[index],
          "themeColor": bangumiThemeColor,
          "sourceTitle":widget.title
        }
      );
  };

  @override
  Function((String,String))? get onPostContent => (message){

    getContentModel().contentListData.add(
      TopicInfo(
        id: -1,
        contentTitle: message.$1
      )
       
        ..updatedTime = DateTime.now().millisecondsSinceEpoch
        ..userInformation = AccountModel.loginedUserInformations.userInformation
    );
    

    getContentModel().contentDetailData[-1] = 
      TopicDetails()
        ..content = message.$2
        ..updatedTime = DateTime.now().millisecondsSinceEpoch
        ..userInformation = AccountModel.loginedUserInformations.userInformation
    ;


    Navigator.pushNamed(
      context, 
      Routes.subjectTopic,
      arguments: {
        "topicModel":getContentModel(),
        "topicInfo": getContentModel().contentListData.last,
        "themeColor": judgeDetailRenderColor(context,bangumiThemeColor),
        "sourceTitle":widget.title
      }
    );

  };

  @override
  PostCommentType? get postCommentType => PostCommentType.postTopic;
             
  @override
  String? get webUrl => BangumiWebUrls.subjectTopics(getContentModel().subjectID);

}