
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/catalogs/subject/bangumi_general_more_content_page.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/topic_info.dart';

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
          //"topicInfo":getContentModel().contentListData[index],
          "topicModel":getContentModel(),
          "index": index,
        }
      );
  }; 
             
  

}