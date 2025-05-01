
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/views/timeline_list_view.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';


@FFRoute(name: '/Timeline')
class BangumiTimelinePage extends StatefulWidget {
  const BangumiTimelinePage({
    super.key,
  });

  @override
  State<BangumiTimelinePage> createState() => _BangumiTimelinePageState();
}

class _BangumiTimelinePageState extends LifecycleRouteState<BangumiTimelinePage> with SingleTickerProviderStateMixin, RouteLifecycleMixin  {
  
  final ValueNotifier<BangumiSurfGroupType> groupTypeNotifier = ValueNotifier(BangumiSurfGroupType.all);
  final PageController timelinePageController = PageController();
  final EasyRefreshController topicListViewEasyRefreshController = EasyRefreshController();
  late TabController tabController; // 新增TabController声明


  @override
  void initState() {

    super.initState();

    tabController = TabController(
      initialIndex : BangumiTimelineType.all.index,
      vsync: this,
      length: BangumiTimelineType.values.length,
    );
    
	  tabController.addListener((){

      if((tabController.index - timelinePageController.page!).abs() < 0.9){
        return;
      }

      timelinePageController.jumpToPage(tabController.index);
	  });
	
  }

  @override
  void dispose() {
    tabController.dispose();
    timelinePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

	
	return Scaffold(
	  appBar: AppBar(
		title: const Text('浏览时间线'),
	  ),
	  body: Column(
		children: [
		  TabBar( // 直接使用显式控制器
			controller: tabController, // 关联控制器
			onTap: (value) {
			  tabController.animateTo(value);
			},
      indicatorSize: TabBarIndicatorSize.tab,
			tabs: List.generate(
			  BangumiTimelineType.values.length, (index){

				if(index == BangumiTimelineType.group.index){
				  return Tab(
            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

              ValueListenableBuilder(
                valueListenable: groupTypeNotifier,
                builder: (_,groupType,child) {
                if(groupType == BangumiSurfGroupType.all) return const SizedBox.shrink();
                  return ScalableText(groupTypeNotifier.value.typeName,style: const TextStyle(fontSize: 12));
                }
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 6,
                children: [
                ScalableText(BangumiTimelineType.values[index].typeName),
                
                PopupMenuButton<BangumiSurfGroupType>(
                  padding: EdgeInsets.zero,
                  initialValue: BangumiSurfGroupType.all,
                  itemBuilder: (_){
                  return BangumiSurfGroupType.values.map(
                    (currentGroupType){
                    return PopupMenuItem<BangumiSurfGroupType>(
                      value: currentGroupType,
                      child: Text(currentGroupType.typeName),
                    );
                    }).toList();
                  },
                  onSelected:(value){

                    timelinePageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut
                    ).then((_){
                      groupTypeNotifier.value = value;
                      topicListViewEasyRefreshController.callRefresh();
                    });

                    
                  },
                  child: const Icon(Icons.arrow_drop_down),
                
                )
                
                ],
              ),
              ],
            ),
          );
				}

				return Tab(text: BangumiTimelineType.values[index].typeName);
			  }
			)
		  ),

		  Expanded(
			  child: EasyRefresh(
          child: PageView.builder(
            controller: timelinePageController,
            onPageChanged: (value) {
              tabController.animateTo(value);
            },
            itemBuilder: (_, timelineIndex){
              return ValueListenableBuilder(
                valueListenable: groupTypeNotifier,
                builder: (_,currentGroupType,__) {

                  return BangumiTimelineContentView(
                    tabController: tabController, 
                    timelinePageController: timelinePageController,
                    groupTypeNotifier: groupTypeNotifier,
                    topicListViewEasyRefreshController: topicListViewEasyRefreshController,

                  );
                
                }
              );
            },
          ),
        ),
		  )
		],
	  ),
	);
  }

}