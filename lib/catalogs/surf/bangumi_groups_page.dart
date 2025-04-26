import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/callback.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/group_topic_info.dart';

import 'package:bangu_lite/models/providers/groups_model.dart';
import 'package:bangu_lite/models/providers/timeline_flow_model.dart';
import 'package:bangu_lite/models/surf_timeline_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_timeline_tile.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/views/groups_select_view.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

@FFAutoImport()
import 'package:bangu_lite/models/group_details.dart';


@FFRoute(name: '/Groups')
class BangumiGroupsPage extends StatefulWidget {
  const BangumiGroupsPage({
    super.key,
    
    this.selectedGroupInfo
  });

  //其他地方理应也可以透过 这个信息 直接达到这个页面且选定小组
  final GroupInfo? selectedGroupInfo;

  @override
  State<BangumiGroupsPage> createState() => _BangumiGroupsPageState();
}

class _BangumiGroupsPageState extends State<BangumiGroupsPage>{

  final expansionTileController = ExpansionTileController();
  final groupTitleNotifier = ValueNotifier<String?>(null);
  final sliverAnimatedListKey = GlobalKey<SliverAnimatedListState>();

  final animatedGroupTopicsListController = ScrollController();

  @override
  Widget build(BuildContext context) {

    final timelineFlowModel = context.read<TimelineFlowModel>();

    return ChangeNotifierProvider(
		//prevent Pass 0 return;
		create: (_) => GroupsModel(subjectID: 'groups'),
		child: Scaffold(
		
			body: Builder(
				builder: (context) {

					return EasyRefresh(
						header: const MaterialHeader(),
						footer: const MaterialFooter(),
						refreshOnStart: true,
						onRefresh: ()=> loadGroupTopics(context),
						onLoad: ()=> loadGroupTopics(context,isAppend: true),
							
						child: CustomScrollView(
							controller: animatedGroupTopicsListController,
							slivers: [
						
								MultiSliver(
									pushPinnedChildren: true,
									children: [
							
										SliverPinnedHeader(
											
											child: Container(
											color: Theme.of(context).colorScheme.surface.withValues(alpha:0.8),
											child: ExpansionTile(
												controller: expansionTileController,
												title: Row(
                          children: [
                            IconButton(onPressed: ()=> Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
                          
                            ValueListenableBuilder(
                              valueListenable: groupTitleNotifier,
                              builder: (_, groupTitle, __)=> ScalableText(groupTitle ?? "小组话题列表")
                            ),

                          ],
												),
												children: [
                          GroupsSelectView(
                            animatedGroupsListController:animatedGroupTopicsListController,
                            sliverAnimatedListKey:sliverAnimatedListKey, 
                            expansionTileController: expansionTileController, 
                            groupTitleNotifier: groupTitleNotifier,
                            loadGroupTopicCallback: (context){
                              expansionTileController.collapse();
                              loadGroupTopics(context);
                            },
                          )
												
												],
											),
											),
										),
								
										SliverPadding(
											padding: Padding16,
											sliver: Consumer<GroupsModel>(
											  builder: (_,groupsModel,__) {
											
												List selectedGroupData = groupTitleNotifier.value == null ?
												timelineFlowModel.timelinesData[BangumiTimelineType.group] ?? [] :
												loadSurfTimelineDetails(
													groupsModel.contentListData,
													bangumiTimelineType:BangumiTimelineType.group
												)
												;

												//debugPrint("currentTopic : ${groupsModel.selectedGroupInfo?.groupName}");
											
											    return SliverAnimatedList(
													
											    	key:sliverAnimatedListKey,
											    	initialItemCount: selectedGroupData.length,
											    	itemBuilder: (_,index,animation){
											    													  
														// AnimatedList 奇怪的问题.. selectedGroupData 指向的好像不是同一个?? 这是怎么回事??
														if(index >= selectedGroupData.length) return const SizedBox.shrink();
																										
														return BangumiTimelineTile(
															surfTimelineDetails: selectedGroupData[index],
															timelineType: BangumiTimelineType.group,
															
															groupTopicInfo: 
																groupsModel.contentListData.isEmpty ?
																GroupTopicInfo.fromSurfTimeline(selectedGroupData[index]) :
																groupsModel.contentListData[index],

														);
													}
											    );
											  }
											),
										),
							
									]
								),
							
							],
						),
					);
				}
			),
		
		),
    );
  }

  void loadGroupTopics(
    BuildContext context,
    {
      bool? isAppend,
    }
  ){
    
      final timelineFlowModel = context.read<TimelineFlowModel>();
      final groupsModel = context.read<GroupsModel>();

      invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

      final Function() invokeRequest;
    
      List selectedGroupData = groupTitleNotifier.value == null ?
      timelineFlowModel.timelinesData[BangumiTimelineType.group] ?? [] :
      groupsModel.contentListData;

      final initalLength = selectedGroupData.length;

      if(groupTitleNotifier.value == null){

        invokeRequest = () => timelineFlowModel.requestSelectedTimeLineType(
          BangumiTimelineType.group,
          isAppend: isAppend,
          queryParameters: BangumiQuerys.groupsTopicsQuery(offset: initalLength)
        );
      }

      else{
        invokeRequest = () => groupsModel.loadGroupTopics(offset: initalLength,isAppend: isAppend);
      }

      invokeRequest().then((result){

          //groupsModel 的 修改是 .contentListData.addAll(result); 而不是直接重新赋值
          //无法让 selectedGroupData 重新获取引用 只能再次赋值变量

          List newSelectedGroupData = groupTitleNotifier.value == null ?
          timelineFlowModel.timelinesData[BangumiTimelineType.group] ?? [] :
          groupsModel.contentListData;

          animatedListAppendContentCallback(
            result,
            initalLength,
            newSelectedGroupData,
            animatedListKey:sliverAnimatedListKey,
            fallbackAction: invokeToaster,
            animatedListController: animatedGroupTopicsListController
          );

          groupsModel.notifyListeners();
          
          
        });

  }


}