import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
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

        required this.currentTimelineSurfType,
        required this.groupTypeNotifier,
        required this.timelineSortTypeNotifier,
        required this.timelineViewEasyRefreshController,

    });

    final BangumiSurfTimelineType currentTimelineSurfType;

    final ValueNotifier<BangumiSurfGroupType> groupTypeNotifier;
    final ValueNotifier<BangumiTimelineSortType> timelineSortTypeNotifier;

    final EasyRefreshController timelineViewEasyRefreshController;

    @override
    State<BangumiTimelineContentView> createState() => _BangumiTimelineContentView();


}

class _BangumiTimelineContentView extends LifecycleRouteState<BangumiTimelineContentView> 
    with SingleTickerProviderStateMixin, RouteLifecycleMixin {

    
    final ScrollController scrollController = ScrollController();

    final refreshNotifier = ValueNotifier(0);

    @override
    Widget build(BuildContext context) {
        final timelineFlowModel = context.read<TimelineFlowModel>();

        debugPrint("timelineList rebuild: ${widget.currentTimelineSurfType.typeName}");

        return EasyRefresh(
            controller: widget.timelineViewEasyRefreshController,
            triggerAxis: Axis.vertical,
            header: const TextHeader(),
            footer: const TextFooter(reverse: true),
            refreshOnStart: interceptSelectedSurfTimelineType(
              timelineFlowModel.timelinesData,
              bangumiSurfTimelineType: widget.currentTimelineSurfType
            ).isEmpty,
            callRefreshOverOffset: 15,
            onRefresh: () => loadTimelineContent(context),
            onLoad: () => loadTimelineContent(context, isAppend: true),

            child: Column(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                      valueListenable: refreshNotifier,
                      builder: (_, __, ___) {

                        final currentTimelineTypeDetails = interceptSelectedSurfTimelineType(
                          timelineFlowModel.timelinesData,
                          bangumiSurfTimelineType: widget.currentTimelineSurfType
                        )
                        .toList()
                        ..sort(
                          (prev,next) => next.updatedAt?.compareTo(prev.updatedAt ?? 0) ?? 0
                        );



                        return ListView.builder(
                          controller: scrollController,
                          itemCount: interceptSelectedSurfTimelineType(timelineFlowModel.timelinesData,bangumiSurfTimelineType: widget.currentTimelineSurfType).length,
                          shrinkWrap: true,
                          itemBuilder: (_, index) {
                              //Animated Question
                              if (index >= currentTimelineTypeDetails.length) {
                                return const SizedBox();
                              }
                      
                              return Container(
                                padding: PaddingH12,
                                color: index % 2 == 0 ? null : Colors.grey.withValues(alpha: 0.3),
                                child: BangumiTimelineTile(
                                  key: ValueKey(currentTimelineTypeDetails.elementAt(index).detailID),
                                  surfTimelineDetails: currentTimelineTypeDetails.elementAt(index),
                                )
                              );
                      
                          }
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

        timelineFlowModel.requestTimelineCompleter = null;

        invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

        if (accountModel.isLogined() == false) {
            if (
                widget.currentTimelineSurfType == BangumiSurfTimelineType.group &&
                widget.groupTypeNotifier.value != BangumiSurfGroupType.all
            ) {
                invokeToaster(message: "登录以获取更多内容");
                return;
            }
        }

        Map<String, dynamic> queryParameters = {};
        
        final selectSurfTimelineTypeContent = 
          interceptSelectedSurfTimelineType(
            timelineFlowModel.timelinesData,
            bangumiSurfTimelineType: widget.currentTimelineSurfType
        )
          .toList()
          ..sort(
            (prev,next) => next.updatedAt?.compareTo(prev.updatedAt ?? 0) ?? 0
          )
        ;
        

        if (isAppend == true) {

            switch (widget.currentTimelineSurfType){

                //默认以最后一个数据的 until为准 如果获取失败 则期望杯返回空数据 并触发提示
                case BangumiSurfTimelineType.all:{
                  queryParameters = BangumiQuerys.timelineQuery(until: selectSurfTimelineTypeContent.last.detailID ?? 0);
                }

                case BangumiSurfTimelineType.subject:{queryParameters = BangumiQuerys.groupTopicQuery..["offset"] = selectSurfTimelineTypeContent.length;
                }
                case BangumiSurfTimelineType.group:{
                    queryParameters = BangumiQuerys.groupsTopicsQuery(mode: widget.groupTypeNotifier.value, offset: selectSurfTimelineTypeContent.length);
                }
                case BangumiSurfTimelineType.timeline:{
                    queryParameters = 
                    BangumiQuerys.timelineQuery(
                        mode: widget.timelineSortTypeNotifier.value,
                        until: selectSurfTimelineTypeContent.last.detailID ?? 0 
                    );
                }
            }
        }

        else {

            switch (widget.currentTimelineSurfType){

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
            widget.currentTimelineSurfType,
            isAppend: isAppend,
            queryParameters: queryParameters
        ).then((result) {
          if (result){
            double recordOffset = scrollController.offset;
            scrollController.animateTo(recordOffset+3*kToolbarHeight,duration: const Duration(milliseconds: 300),curve: Curves.ease);

            refreshNotifier.value += 1;
            
          }

        });

    }

    @override 
    void dispose() {
        scrollController.dispose();
        super.dispose();
    }

}
