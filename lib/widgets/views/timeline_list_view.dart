import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/timeline_flow_model.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_timeline_tile.dart';
import 'package:bangu_lite/widgets/fragments/refresh_indicator.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class BangumiTimelineContentView extends StatefulWidget{

    const BangumiTimelineContentView({
        super.key,

        required this.currentPageIndex,
        required this.groupTypeNotifier,
        required this.timelineSortTypeNotifier,

        required this.timelineViewEasyRefreshController,

    });

    final int currentPageIndex;

    final ValueNotifier<BangumiSurfGroupType> groupTypeNotifier;
    final ValueNotifier<BangumiTimelineSortType> timelineSortTypeNotifier;

    final EasyRefreshController timelineViewEasyRefreshController;

    @override
    State<BangumiTimelineContentView> createState() => _BangumiTimelineContentView();


}

class _BangumiTimelineContentView extends LifecycleRouteState<BangumiTimelineContentView> 
    with SingleTickerProviderStateMixin, RouteLifecycleMixin {

    
    final ScrollController scrollController = ScrollController();

    @override
    Widget build(BuildContext context) {
        final timelineFlowModel = context.read<TimelineFlowModel>();

        debugPrint("timelineList rebuild: ${widget.currentPageIndex}");

        return EasyRefresh(
            controller: widget.timelineViewEasyRefreshController,
            triggerAxis: Axis.vertical,
            header: const TextHeader(),
            footer: const TextFooter(reverse: true),
            refreshOnStart: timelineFlowModel.timelinesData[BangumiSurfTimelineType.values[widget.currentPageIndex]]?.isEmpty ?? true,
            callRefreshOverOffset: 15,
            onRefresh: () => loadTimelineContent(context),
            onLoad: () => loadTimelineContent(context, isAppend: true),

            child: Column(
                children: [
                    Expanded(
                        child: ListView.builder(
                            controller: scrollController,
                            itemCount: timelineFlowModel.timelinesData[BangumiSurfTimelineType.values[widget.currentPageIndex]]?.length ?? 0,
                            shrinkWrap: true,
                            itemBuilder: (_, index) {
                                //Animated Question

                                if (index >= timelineFlowModel.timelinesData[BangumiSurfTimelineType.values[widget.currentPageIndex]]!.length) {
                                    return const SizedBox();
                                }

                                return Container(
                                    padding: PaddingH12,
                                    color: index % 2 == 0 ? null : Colors.grey.withValues(alpha: 0.3),
                                    child: BangumiTimelineTile(
                                        key: ValueKey(timelineFlowModel.timelinesData[BangumiSurfTimelineType.values[widget.currentPageIndex]]![index].detailID),
                                        surfTimelineDetails: timelineFlowModel.timelinesData[BangumiSurfTimelineType.values[widget.currentPageIndex]]![index],
                                    )
                                );

                            }
                        ),
                    ),
                ],
            ),

        );
    }

    void loadTimelineContent(
        BuildContext context,
        {bool? isAppend}
    ) async{
        final timelineFlowModel = context.read<TimelineFlowModel>();
        final accountModel = context.read<AccountModel>();

        invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

        if (accountModel.isLogined() == false) {
            if (
                widget.currentPageIndex == BangumiSurfTimelineType.group.index &&
                widget.groupTypeNotifier.value != BangumiSurfGroupType.all
            ) {
                invokeToaster(message: "登录以获取更多内容");
                return;
            }
        }

        Map<String, dynamic> queryParameters = {};
        final initData = timelineFlowModel.timelinesData[BangumiSurfTimelineType.values[widget.currentPageIndex]];
        int initalLength = initData?.length ?? 0;

        if (isAppend == true) {

            switch (BangumiSurfTimelineType.values[widget.currentPageIndex]){

                //默认以最后一个数据的 until为准 如果获取失败 则期望杯返回空数据 并触发提示
                case BangumiSurfTimelineType.all:{
                  queryParameters = BangumiQuerys.timelineQuery(until: timelineFlowModel.timelinesData[BangumiSurfTimelineType.all]?.last.detailID ?? 0);
                }

                case BangumiSurfTimelineType.subject:{queryParameters = BangumiQuerys.groupTopicQuery..["offset"] = initalLength;
                }
                case BangumiSurfTimelineType.group:{
                    queryParameters = BangumiQuerys.groupsTopicsQuery(mode: widget.groupTypeNotifier.value, offset: initalLength);
                }
                case BangumiSurfTimelineType.timeline:{
                    queryParameters = 
                    BangumiQuerys.timelineQuery(
                        mode: widget.timelineSortTypeNotifier.value,
                        until: initData?.last.detailID ?? 0 
                    );
                }
            }
        }

        else {

            switch (BangumiSurfTimelineType.values[widget.currentPageIndex]){

                case BangumiSurfTimelineType.group:{
                    queryParameters = BangumiQuerys.groupsTopicsQuery(mode: widget.groupTypeNotifier.value);
                }
                case BangumiSurfTimelineType.timeline:{
                    queryParameters = 
                    BangumiQuerys.timelineQuery(
                        mode: widget.timelineSortTypeNotifier.value,
                    );
                }

                default:{}

            }

        }

        await timelineFlowModel.requestSelectedTimeLineType(
            BangumiSurfTimelineType.values[widget.currentPageIndex],
            isAppend: isAppend,
            queryParameters: queryParameters
        ).then((result) {
          if (result){
            double recordOffset = scrollController.offset;
            scrollController.animateTo(recordOffset+3*kToolbarHeight,duration: const Duration(milliseconds: 300),curve: Curves.ease);
            setState(() { });
          }

        });

    }

    @override 
    void dispose() {
        scrollController.dispose();
        super.dispose();
    }

}
