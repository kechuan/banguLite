import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/models/providers/timeline_flow_model.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_timeline_tile.dart';
import 'package:bangu_lite/widgets/fragments/refresh_indicator.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@FFRoute(name: '/TrendTopic')
class BangumiTrendTopic extends StatefulWidget {
  const BangumiTrendTopic({super.key});

  @override
  State<BangumiTrendTopic> createState() => _BangumiTrendTopicState();
}

class _BangumiTrendTopicState extends State<BangumiTrendTopic> {
  final scrollController = ScrollController();

  final refreshNotifier = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bangumi 热点话题')),
      body: EasyRefresh(
        refreshOnStart: true,
        header: const TextHeader(),
        footer: const TextFooter(reverse: true),
        onRefresh: () => loadTrendTopicContent(context),
        onLoad: () => loadTrendTopicContent(context, isAppend: true),
        child: ValueListenableBuilder(
          valueListenable: refreshNotifier,
          builder: (_, __, ___) {

            final timelineFlowModel = context.read<TimelineFlowModel>();

            return Padding(
              padding: EdgeInsetsGeometry.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
              child: ListView.builder(
                controller: scrollController,
                itemCount: 
                timelineFlowModel.trendTimelinesData.isEmpty ? 
                  1 :
                  timelineFlowModel.trendTimelinesData.length,
                  shrinkWrap: true,
                itemBuilder: (_, index) {
              
                  if (timelineFlowModel.trendTimelinesData.isEmpty){
                    return const SizedBox(
                      height: 400,
                      child: Center(child: Text("¯\\_(ツ)_/¯"))
                    );
                  }
              
                  
                  if (index >= timelineFlowModel.trendTimelinesData.length) {
                    return const SizedBox();
                  }
              
                  return Container(
                    padding: PaddingH12,
                    color: index % 2 == 0 ? null : Colors.grey.withValues(alpha: 0.3),
                    child: Provider<SurfTimelineDetails>.value(
                      value: timelineFlowModel.trendTimelinesData.elementAt(index),
                      child: const BangumiTimelineTile(),
                    )
                  );
              
                }
              ),
            );
          }
        ),

      ),
    );
  }

  void loadTrendTopicContent(
    BuildContext context,
    {bool? isAppend}
  ) async{

    final timelineFlowModel = context.read<TimelineFlowModel>();
    timelineFlowModel.requestTrendTopicTimelineCompleter = null;

    invokeToaster({String? message}) => fadeToaster(context: context, message: message ?? "没有更多内容了");

    Map<String, dynamic> queryParameters = 
      isAppend == true ?
        (BangumiQuerys.trendTopicQuery..["offset"] = timelineFlowModel.trendTimelinesData.length) :
        BangumiQuerys.trendTopicQuery 
    ;

    await timelineFlowModel.requestTrendTopicTimeline(
      queryParameters: queryParameters,
      fallbackAction: (message) => invokeToaster(message: message),
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
}
