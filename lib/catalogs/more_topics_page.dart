
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/topic_info.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/topic_model.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

@FFRoute(name: '/moreTopics')
class MoreTopicsPage extends StatelessWidget {
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
  Widget build(BuildContext context) {

    
    final List<TopicInfo> topicsList = topicModel.contentListData;

    return Theme(
      data: ThemeData(
        brightness: Theme.of(context).brightness,
        //primaryColor: judgeDetailRenderColor(context,linearColor),
        colorSchemeSeed: judgeDetailRenderColor(context,bangumiThemeColor),
        fontFamily: 'MiSansFont',
      ),
      child: Scaffold(
        appBar: AppBar(
          title: ScalableText("讨论板块: $title"),
        ),
        body: EasyRefresh(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: topicsList.length,
            itemBuilder: (_,index){
              
              return Card(
                color: judgeDetailRenderColor(context,bangumiThemeColor),
                child: ListTile(
                  onTap: () {
                    Navigator.pushNamed(
                    context,
                    Routes.subjectTopic,
                    arguments: {"topicInfo":topicsList[index],"topicModel":topicModel}
                );
                  },
                  title: ScalableText("${topicsList[index].contentTitle}",maxLines: 2,overflow: TextOverflow.ellipsis,),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                    
                        ScalableText("${topicsList[index].userInformation?.nickName}"),
                    
                        const Spacer(),
                    
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ScalableText(convertDateTimeToString(DateTime.fromMillisecondsSinceEpoch(topicsList[index].createdTime!*1000))),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 3,
                              children: [
                                Icon(MdiIcons.chat,size: 12),
                                ScalableText("${topicsList[index].repliesCount}"),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
          )
        ),
      ),
    );
  }
}