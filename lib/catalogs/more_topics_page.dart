
import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/topic_info.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/topic_model.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart'; // for Non Colorful Icons

@FFRoute(name: '/moreTopics')
class MoreTopicsPage extends StatelessWidget {
  const MoreTopicsPage({
    super.key,
    required this.topicsList,
    required this.topicModel,
    this.title
  });

  final String? title;
  final TopicModel topicModel;
  final List<TopicInfo> topicsList;

  @override
  Widget build(BuildContext context) {

    //final List<TopicInfo> topicsList = [
    //  TopicInfo()
    //    ..topicID = 1
    //    ..topicName = "hi"
    //    ..creatorNickName = "kechuan"
    //    ..createdTime = DateTime.now().millisecondsSinceEpoch - 20000
    //    ..repliesCount = 30
    //    ..lastRepliedNickName = "TVkechuan",

    //   TopicInfo()
    //    ..topicID = 1
    //    ..topicName = "it is a longlonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglongglonglonglonglonglonglonglonglonglonglonglonglonglonglonglong"
    //    ..creatorNickName = "kechuan"
    //    ..createdTime = DateTime.now().millisecondsSinceEpoch - 20000
    //    ..repliesCount = 30
    //    ..lastRepliedNickName = "TVkechuan"
        
    //];


    return Scaffold(
      appBar: AppBar(
        title: Text("Topics: $title"),
      ),
      body: EasyRefresh(
        child: ListView.builder(
          shrinkWrap: true,
          //itemExtent: 100,
          //separatorBuilder: (_,index) => const Divider(height: 1),
          itemCount: topicsList.length,
          itemBuilder: (_,index){
            
            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.pushNamed(
                  context,
                  Routes.subjectTopic,
                  arguments: {"topicInfo":topicsList[index],"topicModel":topicModel}
              );
                },
                title: Text("${topicsList[index].topicName}",maxLines: 2,overflow: TextOverflow.ellipsis,),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                  
                      Text("${topicsList[index].creatorNickName}"),
                  
                      const Spacer(),
                  
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(convertDateTimeToString(DateTime.fromMillisecondsSinceEpoch(topicsList[index].createdTime!*1000))),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 3,
                            children: [
                              Icon(MdiIcons.chat,size: 12),
                              //const Iconify(Zondicons.chat_bubble_dots,size: 12),
                              Text("${topicsList[index].repliesCount}"),
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
    );
  }
}