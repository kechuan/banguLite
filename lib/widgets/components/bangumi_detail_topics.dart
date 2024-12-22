import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/models/providers/topic_model.dart';
import 'package:bangu_lite/models/topic_info.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BangumiDetailTopics extends StatelessWidget {
  const BangumiDetailTopics({
    super.key,
    //required this.subjectID,
    this.name
  });

  //final int subjectID;
  final String? name;
  
  @override
  Widget build(BuildContext context) {

  ValueNotifier<bool> topicCollapseStatusNotifier = ValueNotifier(true);

    
	  final bangumiModel = context.read<BangumiModel>();
    final topicModel = context.read<TopicModel>();

    return Padding(
        padding: const EdgeInsets.all(12.0),

        child:  Selector<TopicModel,List<TopicInfo>>(
          selector: (_, topicModel){
             if(topicModel.topicInfoData.isEmpty) return [];
             return topicModel.topicInfoData;
          },
          shouldRebuild: (previous, next) {
            if(previous.isEmpty || next.isEmpty) return true;
            //if(previous.last.topicID == 0 || next.last.topicID == 0) return true;
              return previous.last.topicID!=next.last.topicID;
            },
          builder: (_, topicsList, child) {
              return ExpansionTile(
                
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.all(0),
                
                showTrailingIcon: false,
                shape: const Border(),
                onExpansionChanged: (topicCollapseStatus) => topicCollapseStatusNotifier.value = topicCollapseStatus,
                title: Row(
                      
                    children: [
                         Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8), //16
                          child: Row(
                            children: [
                              const Text("讨论版",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
                              ValueListenableBuilder(
                                valueListenable: topicCollapseStatusNotifier,
                                builder: (_,topicCollapseStatus,child){
                                  return topicCollapseStatus ?  const Icon(Icons.arrow_drop_up_outlined) : const Icon(Icons.arrow_drop_down_outlined);
                                }
                              )
                            ],
                          ), // 24*(aspectRatio) => 34
                        ),
              
                        const Spacer(),
              
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          
                          child: TextButton(
              
                            onPressed: (){
              
                              Navigator.pushNamed(
                                context,
                                Routes.moreTopics,
                                arguments: {"topicsList":topicsList,"title":name,"topicModel":topicModel}
                              );
                            },
                            child: const Text("更多讨论 >",style: TextStyle(decoration: TextDecoration.underline,fontSize: 16)),
                          )
                        )
              
              
                      ],
                  ),
                children: [
                  
                  Skeletonizer(
                    enabled: topicsList.isEmpty,
                    child: Builder(
                      builder: (_) {
                        if(topicsList.isEmpty) return const SkeletonListTileTemplate();
                        if(topicsList[0].topicID == 0) return const Center(child: Text("该番剧暂无讨论版..."));
              
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: min(6,topicsList.length),
                          itemBuilder: (context, index) {
              
                            final topicTime = DateTime.fromMillisecondsSinceEpoch(topicsList[index].createdTime!*1000);
                                        
                            return Theme(
                              data: ThemeData(
                                colorSchemeSeed: bangumiModel.bangumiThemeColor,
                                fontFamily: 'MiSansFont'
                              ),
                              child: Card(
                                child: ListTile(
                                  title: Text("${topicsList[index].topicName}"),
                                  trailing: Text(convertDateTimeToString(topicTime)),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.subjectTopic,
                                      arguments: {
                                        "topicInfo":topicsList[index],
                                        "topicModel":context.read<TopicModel>()
                                      }
                                    );
                                  },
                                ),
                              ),
                            );
                                        
                                        
                          },
                        );
                      }
                    ),
                  )
              
              
                ],
              );
          
            },

          
          ),
      );
  }
}