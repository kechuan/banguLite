import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/const.dart';
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



@FFRoute(name: '/Groups')
class BangumiGroupsPage extends StatefulWidget {
  const BangumiGroupsPage({super.key});

  @override
  State<BangumiGroupsPage> createState() => _BangumiGroupsPageState();
}

class _BangumiGroupsPageState extends State<BangumiGroupsPage> with SingleTickerProviderStateMixin{

  late TabController tabController;

  final groupTitleNotifier = ValueNotifier<String?>(null);

  final sliverAnimatedListKey = GlobalKey<SliverAnimatedListState>();

  @override
  void initState() {
    
    tabController = TabController(length: BangumiSurfGroupType.values.length-1, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final timelineFlowModel = context.read<TimelineFlowModel>();

    return ChangeNotifierProvider(
      create: (_) => GroupsModel(),
      child: Scaffold(
      
        body: EasyRefresh(
          header: const MaterialHeader(),
          footer: const MaterialFooter(),
          onRefresh: (){
            groupTitleNotifier.value = "热门小组话题列表";
          },
          onLoad: () {
            
          },
      
          child: CustomScrollView(
            slivers: [
          
              MultiSliver(
                pushPinnedChildren: true,
                children: [
          
                  SliverPinnedHeader(
                    
                    child: Container(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha:0.8),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            IconButton(onPressed: ()=> Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back)),
                        
                            ValueListenableBuilder(
                              valueListenable: groupTitleNotifier,
                              builder: (_, groupTitle, __)=> ScalableText(groupTitle ?? "小组话题列表"),
                            ),
                          ],
                        ),
                        children: [
          
                          TabBar(
                            controller: tabController,
                            tabs: List.generate(
                              BangumiSurfGroupType.values.length-1,
                              (index)=> Tab(text: BangumiSurfGroupType.values[index].groupsType)
                            )
                          ),
          
                          SizedBox(
                            height: 200,
                            child: PageView.builder(
                              itemBuilder: (_,index){
                                return EasyRefresh(
                                  child: Padding(
                                    padding: Padding6,
                                    child: Consumer<GroupsModel>(
                                      builder: (_, groupModel, child) {
                                        return GridView.builder(
                                          itemCount: groupModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?.length ?? 0,
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
                                                    onTap:(){},
                                                    highlightColor: Colors.transparent,
                                                    child: ConstrainedBox(
                                                      constraints: const BoxConstraints(
                                                        minWidth: 100,
                                                        minHeight: 120,
                                                      ),
                                                      
                                                      child: CachedImageLoader(
                                                        imageUrl: groupModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupAvatar,
                                                        borderDecoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            
                                                SizedBox(
                                                  height: 65,
                                                  child: Center(
                                                                                   
                                                    child: Text(
                                                      "${groupModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].groupTitle}"
                                                      "\n(${groupModel.groupsData[BangumiSurfGroupType.values[tabController.index]]?[index].membersCount}成员)",
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
                      builder: (_, groupsModel, __) {

                        List selectedGroupData = groupsModel.groupsData[BangumiSurfGroupType.values[tabController.index]] ?? [];

                        if(groupTitleNotifier.value == null){
                          selectedGroupData = timelineFlowModel.timelinesData[BangumiTimelineType.group] ?? [];
                          if(selectedGroupData.isEmpty){
                            timelineFlowModel.requestSelectedTimeLineType(
                              BangumiTimelineType.group,
                            ).then((result){
                              //待封装
                              if(result){
                                sliverAnimatedListKey.currentState?.insertAllItems(
                                  0,
                                  selectedGroupData.length,
                                );
                              }
                            });
                          }
                        }

                        return SliverAnimatedList(
                          key: sliverAnimatedListKey,
                          initialItemCount: selectedGroupData.length,
                          itemBuilder: (_,index,animation){
                            return BangumiTimelineTile(
                              surfTimelineDetails: selectedGroupData[index],
                              timelineType: BangumiTimelineType.group,
                            );
                          }
                        );
                      },
                      
                    ),
                  ),
          
                ]
              ),
          
              
          
             
               
            ],
          ),
        ),
      
      ),
    );
  }
}