import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/callback.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/timeline_flow_model.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_timeline_tile.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class BangumiTimelineContentView extends StatefulWidget {

  const BangumiTimelineContentView({
    super.key, 
    required this.tabController,
    required this.timelinePageController,
    required this.groupTypeNotifier, 
    required this.topicListViewEasyRefreshController,

  });

   final TabController tabController; // 新增TabController声明
   final PageController timelinePageController;
   final ValueNotifier<BangumiSurfGroupType> groupTypeNotifier;

   final EasyRefreshController topicListViewEasyRefreshController;


  @override
  State<BangumiTimelineContentView> createState() => _BangumiTimelineContentView();
}

class _BangumiTimelineContentView extends LifecycleRouteState<BangumiTimelineContentView> with SingleTickerProviderStateMixin, RouteLifecycleMixin  {

  GlobalKey<AnimatedListState> animatedKey = GlobalKey();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<TimelineFlowModel>(
      builder: (_,timelineFlowModel,__) {
        return EasyRefresh(
          controller: widget.topicListViewEasyRefreshController,
          triggerAxis: Axis.vertical,
          header: const MaterialHeader(),
          footer: const MaterialFooter(),
          refreshOnStart: timelineFlowModel.timelinesData[BangumiTimelineType.values[widget.tabController.index]]?.isEmpty ?? true,
          onRefresh: () => loadTimelineContent(context),
          onLoad: () => loadTimelineContent(context,isAppend: true),
        
          child: Column(
            children: [
              Expanded(
                child: AnimatedList(
                  controller: scrollController,
                  key: animatedKey,
                  initialItemCount: timelineFlowModel.timelinesData[BangumiTimelineType.values[widget.tabController.index]]?.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (_,index,animation){
                    
                    //Animated Question

                    if(index >= timelineFlowModel.timelinesData[BangumiTimelineType.values[widget.tabController.index]]!.length){
                      return const SizedBox();
                    }
                    
        
                    return Container(
                      padding: PaddingH12,
                      color: index % 2 == 0 ? null : Colors.grey.withValues(alpha: 0.3),
                      child: BangumiTimelineTile(
                        surfTimelineDetails: timelineFlowModel.timelinesData[BangumiTimelineType.values[widget.tabController.index]]![index],
                      )
                    );
        
                  }
                ),
              ),
            ],
          ),
        
        );
      }
    );
  }

  void loadTimelineContent(
    BuildContext context,
    { bool? isAppend }
  ) async{
      final timelineFlowModel = context.read<TimelineFlowModel>();

      invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

      Map<String,dynamic> queryParameters = {};
      final initData = timelineFlowModel.timelinesData[BangumiTimelineType.values[widget.tabController.index]];
      int initalLength = initData?.length ?? 0;


      if(isAppend == true){

        switch(BangumiTimelineType.values[widget.tabController.index]){
          case BangumiTimelineType.subject:{queryParameters = BangumiQuerys.groupTopicQuery..["offset"] = initalLength;}
          case BangumiTimelineType.group:{
            queryParameters = BangumiQuerys.groupsTopicsQuery(mode: widget.groupTypeNotifier.value,offset: initalLength);
          }
          case BangumiTimelineType.timeline:{queryParameters = BangumiQuerys.timelineQuery..["until"] = initData?.last.detailID ?? 0;}
          default:{}
        }
      }

      else{
        if(BangumiTimelineType.values[widget.tabController.index] == BangumiTimelineType.group){
          queryParameters = BangumiQuerys.groupsTopicsQuery(mode: widget.groupTypeNotifier.value);
        }
      }

      

      await timelineFlowModel.requestSelectedTimeLineType(
        BangumiTimelineType.values[widget.tabController.index],
        isAppend:isAppend,
        queryParameters: queryParameters
      ).then((result){

        final currentTimelineData = timelineFlowModel.timelinesData[BangumiTimelineType.values[widget.tabController.index]];

        int receiveLength = max(0,currentTimelineData?.length ?? 0 - initalLength);

        

        animatedListAppendContentCallback(
          result,
          initalLength,
          receiveLength,
          animatedListKey:animatedKey,
          animatedListController: scrollController,
          fallbackAction: invokeToaster,
        );
        
      });
              
  }

  
}