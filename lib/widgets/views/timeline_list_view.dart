import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
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

      child: ValueListenableBuilder(
        valueListenable: refreshNotifier,
        builder: (_, __, ___) {

          final currentTimelineTypeDetails = interceptSelectedSurfTimelineType(
            timelineFlowModel.timelinesData,
            bangumiSurfTimelineType: widget.currentTimelineSurfType
          )
            .toList()
            ..sort(
              (prev, next) => next.updatedAt?.compareTo(prev.updatedAt ?? 0) ?? 0
            );

          return ListView.builder(
            controller: scrollController,
            itemCount: currentTimelineTypeDetails.isEmpty ? 1 : currentTimelineTypeDetails.length,
            // 高度不固定 必须使用shrinkWrap
            // 这里是滚动区域 并不强制需要约束 并不用搞什么约束传给内部
            itemBuilder: (_, index) {

              if (currentTimelineTypeDetails.isEmpty) {
                return const SizedBox(
                  height: 400,
                  child: Center(
                    child: Text("¯\\_(ツ)_/¯"),
                  ),
                );

              }

              if (index >= currentTimelineTypeDetails.length) {
                return const SizedBox();
              }

              return Container(
                padding: PaddingH12,
                color: index % 2 == 0 ? null : Colors.grey.withValues(alpha: 0.3),
                child: Provider<SurfTimelineDetails>.value(
                  value: currentTimelineTypeDetails.elementAt(index),
                  child: const BangumiTimelineTile(),
                )
              );

            }
          );
        }
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

    List<Map<String, dynamic>> queryParameters = [];

    final selectedSurfTypeTimelines = interceptSelectedSurfTimelineType(
      timelineFlowModel.timelinesData,
      bangumiSurfTimelineType: widget.currentTimelineSurfType
    );

    final latestSelectedSurfTypeTimeline = 
      selectedSurfTypeTimelines.isEmpty ? 
        null :
        selectedSurfTypeTimelines.reduce((prev, next) => (prev.updatedAt ?? 0) > (next.updatedAt ?? 0) ? prev : next)
    ;

    if (isAppend == true) {

      switch (widget.currentTimelineSurfType){

        //默认以最后一个数据的 until为准 如果获取失败 则期望杯返回空数据 并触发提示
        case BangumiSurfTimelineType.all:{
          //全局数据获取
          queryParameters = [
            BangumiQuerys.topicsQuery..["offset"] = selectedSurfTypeTimelines.length,
            BangumiQuerys.groupsTopicsQuery(mode: widget.groupTypeNotifier.value, offset: selectedSurfTypeTimelines.length),
            BangumiQuerys.timelineQuery(
              mode: widget.timelineSortTypeNotifier.value,
              until: latestSelectedSurfTypeTimeline?.detailID ?? 0 
            )

          ];
        }

        case BangumiSurfTimelineType.subject:{queryParameters = [
            BangumiQuerys.topicsQuery..["offset"] = selectedSurfTypeTimelines.length
          ];
        }
        case BangumiSurfTimelineType.group:{
          queryParameters = [BangumiQuerys.groupsTopicsQuery(mode: widget.groupTypeNotifier.value, offset: selectedSurfTypeTimelines.length)];
        }
        case BangumiSurfTimelineType.timeline:{
          queryParameters = [
            BangumiQuerys.timelineQuery(
              mode: widget.timelineSortTypeNotifier.value,
              until: latestSelectedSurfTypeTimeline?.detailID ?? 0 
            )
          ];
        }
      }
    }

    else {

      switch (widget.currentTimelineSurfType){

        case BangumiSurfTimelineType.group:{
          queryParameters = [BangumiQuerys.groupsTopicsQuery(mode: widget.groupTypeNotifier.value)];
        }
        case BangumiSurfTimelineType.timeline:{
          queryParameters = [
            BangumiQuerys.timelineQuery(
              mode: widget.timelineSortTypeNotifier.value,
            )
          ];
        }

        default:{}

      }

    }

    await timelineFlowModel.requestSelectedTimeLineType(
      widget.currentTimelineSurfType,
      //isAppend: isAppend,
      queryParameters: queryParameters
    ).then((result) {
          if (result) {
            double recordOffset = scrollController.offset;

            if (recordOffset != 0) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  scrollController.animateTo(recordOffset + 3 * kToolbarHeight, duration: const Duration(milliseconds: 300), curve: Curves.ease);
                });
            }

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
