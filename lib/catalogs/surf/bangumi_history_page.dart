 

import 'dart:async';

import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/models/providers/history_model.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:bangu_lite/widgets/dialogs/history_range_select_dialog.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_timeline_tile.dart';
import 'package:bangu_lite/widgets/fragments/refresh_indicator.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

@FFRoute(name: '/history')

class BangumiHistoryPage extends StatefulWidget {

    const BangumiHistoryPage({super.key});	

    @override
    State<BangumiHistoryPage> createState() => BangumiHistoryPageState();
}

class BangumiHistoryPageState extends State<BangumiHistoryPage>
    with TickerProviderStateMixin {

    final historyModel = HistoryModel.instance;
    

    @override
    void initState() {

        historyModel.historyPageController = PageController();

        historyModel.bottomBarController = AnimationController(
            duration: const Duration(milliseconds: 200),
            vsync: this,
        );

        historyModel.initData();

        super.initState();
    }

    @override
    void dispose() {
        // 清理所有动画控制器
        for (final controller in historyModel.deleteControllers.values) {
            controller.dispose();
        }

        historyModel.bottomBarController.dispose();
        historyModel.disposeData();
        super.dispose();
    }

    // 创建删除动画控制器
    void createDeleteAnimation(int itemID) {
        if (historyModel.deleteControllers.containsKey(itemID)) return;

        final controller = AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
        );

        final animation = Tween<double>(
            begin: 1.0,
            end: 0.0,
        ).animate(CurvedAnimation(
                    parent: controller,
                    curve: Curves.easeInOut,
                ));

        historyModel.deleteControllers[itemID] = controller;
        historyModel.deleteAnimations[itemID] = animation;
    }

    // 删除单个项目
    Future<void> deleteSingleItem(int itemID) async {
        if (historyModel.deletingItems.contains(itemID)) return;

        setState(() {
          historyModel.deletingItems.add(itemID);
        });

        createDeleteAnimation(itemID);

        // 开始动画
        await historyModel.deleteControllers[itemID]!.forward();

        // 执行删除
        MyHive.historySurfDataBase.delete(itemID);

        // 清理
        historyModel.deleteControllers[itemID]!.dispose();
        historyModel.deleteControllers.remove(itemID);
        historyModel.deleteAnimations.remove(itemID);

        setState(() {
          historyModel.deletingItems.remove(itemID);
        });

        if (mounted) {
          fadeToaster(context: context, message: '记录已删除');
          historyModel.initData();
        }
    }

    // 批量删除选中项目
    Future<void> deleteSelectedItems() async {
        if (historyModel.selectedItems.isEmpty) return;

        final itemsToDelete = List<int>.from(historyModel.selectedItems);

        // 开始删除动画
        setState(() {
          for (final itemID in itemsToDelete) {
              historyModel.deletingItems.add(itemID);
              createDeleteAnimation(itemID);
          }
        });

        // 并行执行所有动画
        await Future.wait(
            itemsToDelete.map((itemID) => historyModel.deleteControllers[itemID]!.forward())
        ).then((_) {

                    for (final itemID in itemsToDelete) {
                        MyHive.historySurfDataBase.delete(itemID);
                        historyModel.deleteControllers[itemID]?.dispose();
                    }

                    historyModel.clearAllSelectionData();

                    setState(() {
                            historyModel.toggleMultiSelectMode();
                            historyModel.multiSelectCountNotifier.value = 0;
                        });

                    if (mounted) {
                        fadeToaster(
                            context: context, 
                            message: '已删除 ${itemsToDelete.length} 条记录'
                        );

                        historyModel.initData();
                    }
                });

    }

    @override
    Widget build(BuildContext context) {

        debugPrint("bangumi_history_page build");

        return Scaffold(
            appBar: AppBar(
                title: const ScalableText('历史记录'),
                leading: ValueListenableBuilder(
                    valueListenable: historyModel.multiSelectModeNotifier,
                    builder: (_, multiSelectModeNotifier, child) {
                        return PopScope(
                          canPop: !multiSelectModeNotifier,
                          onPopInvokedWithResult: (popStatus, result) async {

                            if(historyModel.multiSelectModeNotifier.value){
                              historyModel.toggleMultiSelectMode();
                            }
                            
                          },
                          child: IconButton(
                              onPressed: () {
                                  multiSelectModeNotifier ? historyModel.toggleMultiSelectMode() : Navigator.of(context).pop();
                              },
                              icon: multiSelectModeNotifier ? const Icon(Icons.close) : const Icon(Icons.arrow_back),
                          ),
                        );
                    }
                ),
                actions: buildAppBarActions(),
            ),
            body: EasyRefresh(
                triggerAxis: Axis.vertical,
                onRefresh: () => setState(() {
                        historyModel.initData();
                    }),
                header: const TextHeader(),
        
                child: HistoryPageContent(
                  onDeleteSingleItem: deleteSingleItem,
                ),
        
            ),
            bottomNavigationBar: buildBottomActionBar()
        
        );
    }

    ///很抽象的写法 
    ///但这也让我明白有些写法的意义究竟会在哪里
    List<Widget> buildAppBarActions() {

        return [
            ValueListenableBuilder(
                valueListenable: historyModel.multiSelectModeNotifier,
                builder: (_, multiSelectMode, child) {
                    return Row(
                        spacing: 6,
                        children: [

                          if(kDebugMode)
                            IconButton(
                                onPressed: () {

                                  debugPrint(
									"totalCount:${historyModel.dataSource.length}\n"
									"localHistoryPageMap:${historyModel.localHistoryPageMap}"
								  );

                                },
                                icon: Icon(Icons.date_range),
                            ),


                            if(kDebugMode)
                            IconButton(
                                onPressed: () {

                                    Map<dynamic, SurfTimelineDetails> patchedDetails = {};

                                    debugPrint("execute fix detailID null issue.");

                                    patchedDetails.addEntries(
                                        MyHive.historySurfDataBase.toMap().entries.where((currentItem) {
                                                if (currentItem.value.detailID == null) return true;
                                                return false;
                                            })
                                    );

                                    patchedDetails.updateAll((key, value) {
                                            debugPrint("Before Patch: ${patchedDetails.keys} ${patchedDetails.values.map((it) => it.detailID)}");
                                            value.detailID = key;
                                            return value;
                                        });

                                    debugPrint("After Patch: ${patchedDetails.keys} ${patchedDetails.values.map((it) => it.detailID)}");

                                    MyHive.historySurfDataBase.putAll(patchedDetails);

                                },
                                icon: Icon(Icons.auto_fix_high),
                            ),

                            if (multiSelectMode) 
                            IconButton(
                                onPressed: (){
                                  if(mounted){
                                    historyModel.toggleSelectCurrentPage(historyModel.historyPageController.page!.toInt());
                                  }
                                },
                                icon: Icon(
                                    historyModel.selectedItems.length == MyHive.historySurfDataBase.length
                                        ? Icons.deselect
                                        : Icons.select_all
                                ),
                            ),

                            if(!multiSelectMode) 

                            ...[
                                IconButton(
                                    onPressed: () => historyModel.toggleMultiSelectMode(),
                                    icon: const Icon(Icons.checklist),
                                    tooltip: '多选模式',
                                ),
                                IconButton(
                                    onPressed: () {
                                        showTransitionAlertDialog(
                                            context,
                                            title: "清空全部历史记录",
                                            content: "确定要清空全部历史记录吗？",
                                            confirmAction: () {

                                                setState(() {
                                                        historyModel.toggleMultiSelectMode(isOpen: false);
                                                        MyHive.historySurfDataBase.clear();
                                                    });

                                                fadeToaster(context: context, message: '历史记录已清空');
                                            }

                                        );

                                    },
                                    icon: const Icon(Icons.delete_sweep),
                                    tooltip: '清空全部',
                                ),
                            ]

                        ],
                    );
                },
            )
        ];

    }

    // 构建底部操作栏
    Widget buildBottomActionBar() {

        return Padding(
            padding: PaddingH12V16,
            child: AnimatedBuilder(
                animation: historyModel.bottomBarController,
                builder: (_, child) {

                    if (historyModel.bottomBarController.value < 0.1) return const SizedBox.shrink();
                    if (historyModel.bottomBarController.value > 0.9) return child!;

                    return Offstage(
                        offstage: historyModel.bottomBarController.value == 0,
                        child: Opacity(
                            opacity: historyModel.bottomBarController.value,
                            child: Transform.translate(
                                offset: Offset(0, 60 - historyModel.bottomBarController.value * 60),
                                child: child!,
                            ),
                        ),
                    );
                },

                child: Container(

                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                            top: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 0.5,
                            ),
                        ),
                    ),
                    child: SafeArea(
                        child: Row(
                            children: [

                                Expanded(
                                    child: ValueListenableBuilder(
                                        valueListenable: historyModel.multiSelectCountNotifier,
                                        builder: (_, multiSelectCount, __) {
                                            return ScalableText(
                                                '已选择 $multiSelectCount 项',
                                            );
                                        }
                                    ),
                                ),

                                ElevatedButton.icon(
                                    onPressed: () {

                                        if (historyModel.selectedItems.isEmpty) return;

                                        showTransitionAlertDialog(
                                            context,
                                            title: '历史记录删除',
                                            content: '确定要删除选中的 ${historyModel.selectedItems.length} 条记录吗？',
                                            confirmAction: () {
                                                deleteSelectedItems();
                                            },
                                        );

                                    },
                                    icon: const Icon(Icons.delete),
                                    label: const ScalableText('删除'),
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                ),
                            ],
                        ),
                    ),
                )

            ),
        );
    }


}


class HistoryPageContent extends StatefulWidget {
    const HistoryPageContent({
        super.key,
        this.onDeleteSingleItem
    });

    final Function(int)? onDeleteSingleItem;

    @override
    State<HistoryPageContent> createState() => _HistoryPageContentState();
}


class _HistoryPageContentState extends State<HistoryPageContent> {

    final historyModel = HistoryModel.instance;

    //final PageController historyPageController = PageController();

    List<Widget> buildPageSection(BuildContext context, int pageIndex) {

        int currentPageloadStartIndex = historyModel.convertHistoryPageStartIndex(pageIndex);
		    int currentPageGroupSize = historyModel.getCurrentPageGroupCount(pageIndex);
        
        final List<int> groupCounts = calculateGroupCounts(historyModel.groupIndices, historyModel.dataSource.length);

        return List.generate(
            currentPageGroupSize, (index) {

              
              int startIndex = historyModel.groupIndices.values.elementAt(currentPageloadStartIndex + index);
              int itemCount = groupCounts[currentPageloadStartIndex + index];

              String headerText = 
                "${historyModel.groupIndices.keys.elementAt(currentPageloadStartIndex + index)}${kDebugMode ? '\t[index:$startIndex]' : '' }";



                      return MultiSliver(
                          pushPinnedChildren: true,
                          children: [
                              buildSectionHeader(context, headerText),
                              buildSectionList(
                                  context,
                                  data: historyModel.dataSource,
                                  startIndex: startIndex,
                                  itemCount: itemCount,
                              ),
                          ],
                      );

                  }
              );
    }

    // 构建分区列表
    List<Widget> buildSection(BuildContext context) {

        List<SurfTimelineDetails> dataSource = historyModel.dataSource;

        final List<int> groupCounts = calculateGroupCounts(historyModel.groupIndices, dataSource.length);

        return List.generate(historyModel.groupIndices.length, (index) {

                String headerText = historyModel.groupIndices.keys.elementAt(index);
                int startIndex = historyModel.groupIndices.values.elementAt(index);
                int itemCount = groupCounts[index];

                return MultiSliver(
                    pushPinnedChildren: true,
                    children: [
                        buildSectionHeader(context, headerText),
                        buildSectionList(
                            context,
                            data: dataSource,
                            startIndex: startIndex,
                            itemCount: itemCount,
                        ),
                    ],
                );
            });
    }

    // 构建分区标题
    Widget buildSectionHeader(BuildContext context, String dateTimeText) {
        //Debug HotReload特性 即使透过navigation跳转也会强制build上一个页面
        if(kDebugMode && ModalRoute.of(context)?.isCurrent == true){
          debugPrint("buildSectionHeader: $dateTimeText");
        }

        return SliverPinnedHeader(
            child: Container(
                padding: PaddingH12,
                decoration: BoxDecoration(
                    border: Border(bottom: Divider.createBorderSide(context)),
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                ),
                child: SizedBox(
                    height: 50,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: ScalableText(dateTimeText, style: const TextStyle(fontSize: 14))
                    )
                ),
            ),
        );
    }

    // 构建分区列表
    Widget buildSectionList(
        BuildContext context,
        {
            required List<SurfTimelineDetails> data,
            required int startIndex,
            required int itemCount,
        }
    ) {
        DateTime recordTime = DateTime(0);
        List<SurfTimelineDetails> rangeData = data.sublist(startIndex, startIndex + itemCount);

        return Padding(
            padding: PaddingH6V12,
            child: ListView.builder(
                padding: const EdgeInsets.all(0),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                    final item = rangeData[index];
                    final itemID = item.detailID;
                    final isDeleting = historyModel.deletingItems.contains(itemID);
                    // final isSelected = selectedItems.contains(itemID);

                    final currentTime = DateTime.fromMillisecondsSinceEpoch(item.updatedAt ?? 0);

                    // 15分钟为节点
                    if (currentTime.difference(recordTime).inMinutes.abs() > 15) {
                        recordTime = currentTime;
                    }

                    // 如果有删除动画，使用动画包装
                    Widget itemWidget = buildHistoryItem(
                        item: item,
                        isNearlyTime: recordTime == currentTime,
                    );

                    if (isDeleting && historyModel.deleteAnimations.containsKey(itemID)) {
                        itemWidget = AnimatedBuilder(
                            animation: historyModel.deleteAnimations[itemID]!,
                            builder: (context, child) {
                                return SizeTransition(
                                    sizeFactor: historyModel.deleteAnimations[itemID]!,
                                    child: FadeTransition(
                                        opacity: historyModel.deleteAnimations[itemID]!,
                                        child: child,
                                    ),
                                );
                            },
                            child: itemWidget,
                        );
                    }

                    return itemWidget;
                },
            ),
        );
    }

    // 构建单个历史记录项
    Widget buildHistoryItem(
    {
        required SurfTimelineDetails item,
        required bool isNearlyTime,
    }
    ) {

        final currentTime = DateTime.fromMillisecondsSinceEpoch(item.updatedAt ?? 0);

        return GestureDetector(

            onLongPress: () {
                if (!historyModel.multiSelectModeNotifier.value) historyModel.toggleMultiSelectMode();
            },
            onTap: () {
                if (historyModel.multiSelectModeNotifier.value) historyModel.toggleItemSelection(item.detailID!);
            },

            child: Stack(
                children: [

                    Positioned.fill(
                        child: ValueListenableBuilder(
                            valueListenable: historyModel.multiSelectCountNotifier,
                            builder: (_, __, ___) {
                                return Container(
                                    decoration: BoxDecoration(
                                        color: historyModel.selectedItems.contains(item.detailID) ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : null,
                                        borderRadius: BorderRadius.circular(8),
                                    ),
                                );
                            }
                        ),
                    ),

                    Row(
                        spacing: 6,
                        children: [

                            // 多选模式下显示的框 其单个项目的选择框伴随着 
                            // 多选模式的一同的动画

                            AnimatedBuilder(
                                animation: historyModel.bottomBarController,
                                builder: (_, child) {

                                    if (historyModel.bottomBarController.value < 0.1) return const SizedBox.shrink();
                                    if (historyModel.bottomBarController.value > 0.9) return child!;

                                    return Offstage(
                                        offstage: historyModel.bottomBarController.value == 0,
                                        child: SizedBox(
                                            width: historyModel.bottomBarController.value * 60,
                                            child: Opacity(
                                                opacity: historyModel.bottomBarController.value,
                                                child: Transform.translate(
                                                    offset: Offset(historyModel.bottomBarController.value * 60 - 60, 0),
                                                    child: child!,
                                                ),
                                            ),
                                        ),
                                    );

                                },
                                child: ValueListenableBuilder(
                                    valueListenable: historyModel.multiSelectCountNotifier,
                                    builder: (_, __, ___) {
                                        return Checkbox(
                                            value: historyModel.selectedItems.contains(item.detailID),
                                            onChanged: (value) => historyModel.toggleItemSelection(item.detailID!),
                                        );
                                    }),
                            ),

                            // 时间显示
                            Padding(
                                padding: judgeLandscapeMode(context) ? PaddingH16 + PaddingH12 : PaddingH12,
                                child: ScalableText(
                                    '${convertDigitNumString(currentTime.hour)}:${convertDigitNumString(currentTime.minute)}',
                                    style: TextStyle(
                                        color: isNearlyTime ? Colors.grey : Colors.transparent,
                                        fontWeight: FontWeight.bold
                                    ),
                                ),
                            ),

                            // 主要内容
                            Expanded(
                                child: Padding(
                                    padding: PaddingH12,
                                    child: BangumiTimelineTile(
                                        onTap: () {
                                            if (historyModel.multiSelectModeNotifier.value) { 
                                                if (item.detailID != null) {
                                                    historyModel.toggleItemSelection(item.detailID!);
                                                }

                                                return false;
                                            }

                                            return true;

                                        },
                                        surfTimelineDetails: item,
                                        isRecordMode: true,
                                    ),
                                ),
                            ),

                            // 删除按钮（非多选模式下显示）

                            ValueListenableBuilder(
                                valueListenable: historyModel.multiSelectModeNotifier,
                                builder: (_, multiSelectModeNotifier, child) {
                                    if (multiSelectModeNotifier) return child!;
                                    return const SizedBox.shrink();
                                },
                                child: IconButton(
                                    onPressed: () {
                                      widget.onDeleteSingleItem?.call(item.detailID!);
                                    },
                                    icon: const Icon(Icons.close),
                                ),
                            ),
                        ],
                    ),

                ],
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return SafeArea(
            child: Padding(
                padding: Padding16,
                child: Column(
                    spacing: 12,
                    children: [

                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: judgeCurrentThemeColor(context).withValues(alpha: 0.5),

                          ),
                          
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                          
                                 

                                  IconButton(
                                      onPressed: () {
                                          historyModel.historyPageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                      },
                                      icon: Icon(Icons.arrow_back_ios_new_outlined),
                                  ),
                          
                                  AnimatedBuilder(
                                      animation: historyModel.historyPageController, 
                                      builder: (_, rangeButton) {
                          
                                          int startIndex = 0;
                                          int endIndex = 0;
                          
                                          if(historyModel.historyPageController.hasClients){
                                            startIndex = historyModel.convertHistoryPageStartIndex(historyModel.historyPageController.page!.toInt());
                                            endIndex = historyModel.convertHistoryPageEndIndex(historyModel.historyPageController.page!.toInt());
                                          }
                          
                                          else{
                                            startIndex = historyModel.convertHistoryPageStartIndex(0);
                                            endIndex = historyModel.convertHistoryPageEndIndex(0);
                                          }
                          
                          
                                          return Row(
                                            spacing: 12,
                                            children: [
                          
                                              ScalableText(
                                                "${historyModel.groupIndices.keys.elementAtOrNull(startIndex) ?? ""}"
                                                " ~ "
                                                "${historyModel.groupIndices.keys.elementAtOrNull(endIndex) ?? ""}",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                          
                                              rangeButton!
                                            ],
                                          );
                          
                          
                                          
                                      },
                          
                                      child: IconButton(
                                        onPressed: (){
                                          if(historyModel.historyPageController.hasClients){
                                            showHistoryDateRangeSelectDialog(context, historyModel.historyPageController.page!.toInt()).then((index){
                                              if(index != null){
                                                historyModel.historyPageController.jumpToPage(index);
                                              }
                                            });
                                          }
                                        }, 
                                        icon: Icon(Icons.date_range)
                                      ),
                                  ),
                          
                                  IconButton(
                                      onPressed: () {
                                          historyModel.historyPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                      },
                                      icon: Icon(Icons.arrow_forward_ios_outlined),
                                  ),
                          
                              ],
                          ),
                        ),

                        Expanded(
                            child: PageView(
                                controller: historyModel.historyPageController,
                                children: [
                                  if(historyModel.localHistoryPageMap.isEmpty)
                                    Center(
                                      child: ScalableText("空空如也"),
                                    )
                                  else
                                    ...List.generate(historyModel.localHistoryPageMap.length, (index) => CustomScrollView(
                                      slivers: buildPageSection(context, index)
                                    )),
                                ]
                            )
                        )

                    ],
                ),
            ),
        );
    }

}

