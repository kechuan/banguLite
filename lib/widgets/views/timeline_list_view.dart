

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

  });

   final TabController tabController; // 新增TabController声明
   final PageController timelinePageController;
   final ValueNotifier<BangumiSurfGroupType> groupTypeNotifier;

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
              triggerAxis: Axis.vertical,
              header: const MaterialHeader(),
              footer: const MaterialFooter(),
              //refreshOnStart: true,
              onRefresh: () async {
  
                invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");
  
                final initalLength = timelineFlowModel.timelinesData[
                  BangumiTimelineType.values[widget.tabController.index]
                ]?.length ?? 0;

                await timelineFlowModel.requestSelectedTimeLineType(
                  BangumiTimelineType.values[widget.tabController.index],
                  queryParameters: 
                    BangumiTimelineType.values[widget.tabController.index] == BangumiTimelineType.group ?  
                    BangumiQuerys.groupsTopicsQuery(mode: widget.groupTypeNotifier.value) :
                    null
                ).then((result){
                    
                  final currentTimelineData = timelineFlowModel.timelinesData[BangumiTimelineType.values[widget.tabController.index]];

                  animatedListAppendContentCallback(
                    result,
                    initalLength,
                    currentTimelineData,
                    animatedListKey:animatedKey,
                    fallbackAction: invokeToaster,
                  );
                  
                });
              },

              child: Column(
                children: [
                  Expanded(
                    child: AnimatedList(
                      controller: scrollController,
                      key: animatedKey,
                      initialItemCount: timelineFlowModel.timelinesData[BangumiTimelineType.values[widget.tabController.index]]?.length ?? 0,
                      shrinkWrap: true,
                      itemBuilder: (_,index,animation){
                        return Container(
                          padding: PaddingH12,
                          color: index % 2 == 0 ? null : Colors.grey.withValues(alpha: 0.3),
                          child: BangumiTimelineTile(
                            surfTimelineDetails: timelineFlowModel.timelinesData[BangumiTimelineType.values[widget.tabController.index]]![index],
                            timelineType: BangumiTimelineType.values[widget.tabController.index],
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

}