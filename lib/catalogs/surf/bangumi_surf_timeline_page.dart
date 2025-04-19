import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/timeline_flow_model.dart';
import 'package:bangu_lite/models/timeline_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_timeline_tile.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


@FFRoute(name: '/Timeline')
class BangumiTimelinePage extends StatefulWidget {
  const BangumiTimelinePage({super.key});

  @override
  State<BangumiTimelinePage> createState() => _BangumiTimelinePageState();
}

class _BangumiTimelinePageState extends LifecycleRouteState<BangumiTimelinePage> with SingleTickerProviderStateMixin, RouteLifecycleMixin  {
  
  final ValueNotifier<BangumiSurfGroupType> groupTypeNotifier = ValueNotifier(BangumiSurfGroupType.all);
  final PageController timelinePageController = PageController();
  late TabController tabController; // 新增TabController声明

  @override
  void initState() {

	super.initState();

	tabController = TabController(
	  vsync: this,
	  length: BangumiTimelineType.values.length,
	);
	
	  tabController.addListener((){
		//疑问:
		//如果不添加这种设置 在左右划屏幕的时候 就会直接被取消动画 而
		//但如果添加了这种设置 那么主动点击的时候。。就直接被return掉了

		//只能这样了 阈值设置在 1 之内 好在jumpPage的时候只能是整数值

		if((tabController.index - timelinePageController.page!).abs() < 0.9){
		  return;
		}

		timelinePageController.jumpToPage(
		  tabController.index, 
		);
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

	final timelineFlowModel = context.read<TimelineFlowModel>();
	
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
						  
								groupTypeNotifier.value = value;

								timelinePageController.animateToPage(
								  index,
								  duration: const Duration(milliseconds: 300),
								  curve: Curves.easeOut
								);
							  },
							  child: const Icon(Icons.arrow_drop_down),
						  
							)
						  
						  ],
						),
					  ],
					),
				  );
				}

				return Tab(
				  text: BangumiTimelineType.values[index].typeName,
				);
			  }
			)
		  ),

		  Expanded(
			child: EasyRefresh(
				triggerAxis: Axis.vertical,
				header: const MaterialHeader(),
				onRefresh: () {
					timelineFlowModel.requestSelectedTimeLineType(
						BangumiTimelineType.values[tabController.index],
						queryParameters: 
							BangumiTimelineType.values[tabController.index] == BangumiTimelineType.group ?	
							BangumiQuerys.groupsTopicsQuery(mode: groupTypeNotifier.value) :
							null
					);
				},
				child: PageView.builder(
					controller: timelinePageController,
					onPageChanged: (value) {
						tabController.animateTo(value);
					},
					itemBuilder: (_, timelineIndex){
						return ValueListenableBuilder(
							valueListenable: groupTypeNotifier,
							builder: (_,currentGroupType,__) {
							
								return AnimatedList(
									initialItemCount: 15,
									shrinkWrap: true,
									itemBuilder: (_,index,animation){
										return Container(
											color: index % 2 == 0 ? null : Colors.grey.withValues(alpha: 0.3),
											//height: 70,
											child: BangumiTimelineTile(
												timelineDetails: TimelineDetails(),
											)
											//child: ScalableText("$timelineIndex - $index"),
										);
									}
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