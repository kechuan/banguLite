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
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
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

class _BangumiGroupsPageState extends State<BangumiGroupsPage> with SingleTickerProviderStateMixin{

  late TabController tabController;

  final expansionTileController = ExpansionTileController();
  final groupTitleNotifier = ValueNotifier<String?>(null);
  final sliverAnimatedListKey = GlobalKey<SliverAnimatedListState>();

  final animatedGroupTopicsListController = ScrollController();
  final animatedGroupsListController = ScrollController();

  @override
  void initState() {
    
    tabController = TabController(length: BangumiSurfGroupType.values.length-1, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final timelineFlowModel = context.read<TimelineFlowModel>();

    return ChangeNotifierProvider(
		// Pass 0 return;
		create: (_) => GroupsModel(subjectID: 'groups'),
		child: Scaffold(
		
			body: Builder(
				builder: (context) {

					final groupsModel = context.read<GroupsModel>();

					return EasyRefresh(
						header: const MaterialHeader(),
						footer: const MaterialFooter(),
						refreshOnStart: true,
						onRefresh: (){
							

							invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

              final Function() invokeRequest;
						
							List selectedGroupData = groupTitleNotifier.value == null ?
							timelineFlowModel.timelinesData[BangumiTimelineType.group] ?? [] :
							groupsModel.contentListData;

							final initalLength = selectedGroupData.length;

							if(groupTitleNotifier.value == null){
								invokeRequest = () => timelineFlowModel.requestSelectedTimeLineType(
									BangumiTimelineType.group,
								);
							}

							else{
								invokeRequest = () => groupsModel.loadGroupTopics();
							}

                invokeRequest().then((result){
          
                  List newSelectedGroupData = groupTitleNotifier.value == null ?
                  timelineFlowModel.timelinesData[BangumiTimelineType.group] ?? [] :
                  groupsModel.contentListData;

        
                  animatedListAppendContentCallback(
                    result,
                    initalLength,
                    newSelectedGroupData,
                    sliverAnimatedListKey,
                    fallbackAction: invokeToaster,
                  );

                  groupsModel.notifyListeners();

                  
                });


						},
						onLoad: () {

							invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

              final Function() invokeRequest;
						
							List selectedGroupData = groupTitleNotifier.value == null ?
							timelineFlowModel.timelinesData[BangumiTimelineType.group] ?? [] :
							groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]] ?? [];

							final initalLength = selectedGroupData.length;

							if(groupTitleNotifier.value == null){

                invokeRequest = () => timelineFlowModel.requestSelectedTimeLineType(
                  BangumiTimelineType.group,
                  isAppend: true,
                  queryParameters: BangumiQuerys.groupsTopicsQuery(offset: initalLength)
                );

							}

							else{
                invokeRequest = () => groupsModel.loadGroupTopics(offset: initalLength);
							}

                invokeRequest().then((result){
				
									List newSelectedGroupData = groupTitleNotifier.value == null ?
                  timelineFlowModel.timelinesData[BangumiTimelineType.group] ?? [] :
                  groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]] ?? [];
				
									animatedListAppendContentCallback(
										result,
										initalLength,
										newSelectedGroupData,
										sliverAnimatedListKey,
										fallbackAction: invokeToaster,
										animatedListController: animatedGroupTopicsListController
									);

									groupsModel.notifyListeners();
									
									
								});

						},
							
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

													//IconButton(
													//	onPressed: (){
													//		sliverAnimatedListKey.currentState?.removeAllItems(
													//			(_,animation)=> const SizedBox.shrink()
													//		);

													//		animatedListAppendContentCallback(
													//			true,
													//			0,
													//			groupsModel.contentListData,
													//			sliverAnimatedListKey,
													//		);
													//	}, 
													//	icon: const Icon(Icons.delete)
													//)
												],
												),
												children: [
								
                          TabBar(
                            controller: tabController,
                            onTap: (value) async {

                              //unknown error

                              invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

                              if(groupsModel.groupsData[BangumiSurfGroupType.values[value]]!.isEmpty){
                                await groupsModel.loadGroups(
                                  mode: BangumiSurfGroupType.values[value],
                                  fallbackAction: invokeToaster,
                                ).then((result){
                                  
                                  List newSelectedGroupData = groupsModel.groupsData[BangumiSurfGroupType.values[value]]!;

                                  animatedListAppendContentCallback(
                                    result,
                                    0,
                                    newSelectedGroupData,
                                    sliverAnimatedListKey,
                                    fallbackAction: invokeToaster,
                                    animatedListController: animatedGroupTopicsListController
                                  );

                                  groupsModel.notifyListeners();


                                });
                              }

                              
                            },
                            tabs: List.generate(
                              BangumiSurfGroupType.values.length-1,
                              (index)=> Tab(text: BangumiSurfGroupType.values[index].groupsType)
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                          ),
                  
                          SizedBox(
                            height: 200,
                            child: PageView.builder(
                            itemBuilder: (_,index){
                              return EasyRefresh(
                                triggerAxis: Axis.vertical,
                              child: Padding(
                                padding: Padding6,
                                child: Consumer<GroupsModel>(
                                builder: (_, groupsModel, child) {
                                  return GridView.builder(
                                    controller:animatedGroupsListController,
                                      itemCount: groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?.length ?? 0,
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent: 180
                      
                                      ),
                                      itemBuilder: (_,index){
                                        return Column(
                                        spacing: 20,
                                        children: [
                                        
                                          Expanded(
                                          child: InkResponse(
                                            containedInkWell: true,
                                            onTap:() async {

                                              invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

                                              groupsModel.selectedGroupInfo = groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index];
                                              groupTitleNotifier.value = groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupTitle;

                                              expansionTileController.collapse();

                                              


                                              await groupsModel.loadGroupTopics().then((result){

                                                if(result){

                      
                                                  sliverAnimatedListKey.currentState?.removeAllItems(
                                                    (_,animation)=> const SizedBox.shrink()
                                                  );
                                                }

                                                
                                                animatedListAppendContentCallback(
                                                  result,
                                                  0,
                                                  groupsModel.contentListData,
                                                  sliverAnimatedListKey,
                                                  fallbackAction: invokeToaster,
                                                );
        
                                              });

                                              

                                              

                                            },
                                            highlightColor: Colors.transparent,
                                            child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minWidth: 100,
                                              minHeight: 120,
                                            ),
                                            
                                            child: CachedImageLoader(
                                              imageUrl: groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupAvatar,
                                              borderDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            ),
                                          ),
                                          ),
                                        
                                          SizedBox(
                                          height: 65,
                                          child: Center(
                                                            
                                            child: Text(
                                            "${groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupTitle}"
                                            "\n(${groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].membersCount}成员)",
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            ),
                                            
                                          )
                                          ),
                                        
                                        ],
                                        );
                                      }
                                    );
                                },
                                
                                )
                              ),
                              );
                            }
                            ),
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
													
											    	key: sliverAnimatedListKey,
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
}