import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/widgets/fragments/refresh_indicator.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(name: 'test')

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  int testCount = 50;

  final dataListScrollController = ScrollController();

  final testList = [
    "[url=https://bangumi.tv/subject/topic/37962]Topic链接[/url]",
    "[url=https://bangumi.tv/blog/363176]Blog链接[/url]",
  ];

  @override
  Widget build(BuildContext context) {
  
    return EasyRefresh(
      footer: const TextFooter(),
      child: Scaffold(
        appBar: AppBar(
          title: const ScalableText('测试页面'),
        ),
        body: CustomScrollView(
          slivers: [
            SliverWaterfallFlow(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(
                  title: BBCodeText(
                    data: testList[index],
                    stylesheet: appDefaultBBStyleSheet(context),
                  )
                ),
                childCount: testList.length,
              ),
              gridDelegate: const SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1
              ),
            )
          ],
        ),

        
      ),
    );
  }
}


class SliverWaterfallFlowDelegateWithMinCrossAxisExtent
    extends SliverWaterfallFlowDelegate {
  const SliverWaterfallFlowDelegateWithMinCrossAxisExtent({
    required this.minCrossAxisExtent,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    super.lastChildLayoutTypeBuilder,
    super.collectGarbage,
    super.viewportBuilder,
    super.closeToTrailing,
  }) : assert(minCrossAxisExtent >= 0);

  final double minCrossAxisExtent;

  @override
  int getCrossAxisCount(SliverConstraints constraints) {
    final int val =
        (constraints.crossAxisExtent / (minCrossAxisExtent + crossAxisSpacing))
            .floor();
    return val < 1 ? 1 : val;
  }

  @override
  bool shouldRelayout(SliverWaterfallFlowDelegate oldDelegate) {
    if (oldDelegate.runtimeType != runtimeType) {
      return true;
    }

    return oldDelegate is SliverWaterfallFlowDelegateWithMaxCrossAxisExtent &&
        (oldDelegate.maxCrossAxisExtent != minCrossAxisExtent ||
            super.shouldRelayout(oldDelegate));
  }
}