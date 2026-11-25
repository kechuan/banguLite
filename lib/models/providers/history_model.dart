import 'package:bangu_lite/delegates/star_sort_strategy.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:flutter/material.dart';

/// 单个历史分页对应的分组与条目索引范围（闭区间）。
class HistoryPageRange {
  const HistoryPageRange({
    required this.startGroupIndex,
    required this.endGroupIndex,
    required this.startItemIndex,
    required this.endItemIndex,
  });

  final int startGroupIndex;
  final int endGroupIndex;
  final int startItemIndex;
  final int endItemIndex;

  int get groupCount => endGroupIndex - startGroupIndex + 1;
}

/// 历史记录页面的页面级控制器（不再作为全局单例持有页面 UI Controller）。
class HistoryModel {
  HistoryModel();

  List<SurfTimelineDetails> dataSource = [];

  final Map<String, int> groupIndices = {};

  /// 分页范围列表，按页码顺序排列
  final List<HistoryPageRange> historyPages = [];

  /// 兼容调试展示：key 为该页结束分组下标，value 为 `[startItemIndex, endItemIndex]`
  final Map<int, List<int>> localHistoryPageMap = {};

  late AnimationController bottomBarController;
  late PageController historyPageController;

  final ValueNotifier<int> multiSelectCountNotifier = ValueNotifier(0);
  final ValueNotifier<bool> multiSelectModeNotifier = ValueNotifier(false);

  final Set<int> selectedItems = {};

  // 正在删除的项目
  final Set<int> deletingItems = {};

  // 删除动画控制器
  final Map<int, AnimationController> deleteControllers = {};
  final Map<int, Animation<double>> deleteAnimations = {};

  void initData({int pageCount = 30}) {
    clearAllSelectionData();
    disposeData();

    dataSource = MyHive.historySurfDataBase.values.toList();
    dataSource.sort((prev, next) => (next.updatedAt ?? 0).compareTo(prev.updatedAt ?? 0));

    for (int starIndex = 0; starIndex < dataSource.length; starIndex++) {
      final String headerText = SurfTimeSortStrategy().generateHeaderText(
        dataSource[starIndex].updatedAt ?? 0,
      );
      groupIndices[headerText] ??= starIndex;
    }

    final List<int> groupCounts = calculateGroupCounts(groupIndices, dataSource.length);
    final pages = buildHistoryPages(groupCounts, pageCount: pageCount);

    historyPages.addAll(pages);
    for (final page in pages) {
      localHistoryPageMap[page.endGroupIndex] = [page.startItemIndex, page.endItemIndex];
    }

    debugPrint("localHistoryPageMap: $localHistoryPageMap");
  }

  // 切换多选模式 -> onToggleSelectionMode
  Future<void> toggleMultiSelectMode({bool? isOpen}) async {
    selectedItems.clear();
    multiSelectCountNotifier.value = 0;

    multiSelectModeNotifier.value = isOpen ?? !multiSelectModeNotifier.value;

    multiSelectModeNotifier.value
        ? await bottomBarController.forward()
        : await bottomBarController.reverse();
  }

  // 切换项目选中状态 -> onToggleItemStatus
  void toggleItemSelection(int itemID) {
    if (selectedItems.contains(itemID)) {
      selectedItems.remove(itemID);
    }

    else {
      selectedItems.add(itemID);
    }

    multiSelectCountNotifier.value = selectedItems.length;
  }

  // 全选/取消全选当前页
  void toggleSelectCurrentPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= historyPages.length) return;

    final page = historyPages[pageIndex];
    final rangeData = dataSource.sublist(page.startItemIndex, page.endItemIndex + 1);
    final pageIds = rangeData.map((item) => item.detailID).whereType<int>().toList();

    final bool allSelected = pageIds.isNotEmpty && pageIds.every(selectedItems.contains);

    if (allSelected) {
      selectedItems.removeAll(pageIds);
    }

    else {
      selectedItems.addAll(pageIds);
    }

    multiSelectCountNotifier.value = selectedItems.length;
  }

  void clearAllSelectionData() {
    for (final controller in deleteControllers.values) {
      controller.dispose();
    }

    deleteControllers.clear();
    deleteAnimations.clear();
    deletingItems.clear();
    selectedItems.clear();
  }

  void disposeData() {
    historyPages.clear();
    localHistoryPageMap.clear();
    groupIndices.clear();
  }

  void dispose() {
    clearAllSelectionData();
    bottomBarController.dispose();
    historyPageController.dispose();
    multiSelectCountNotifier.dispose();
    multiSelectModeNotifier.dispose();
    disposeData();
  }

  int getCurrentPageGroupCount(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= historyPages.length) return 0;

    return historyPages[pageIndex].groupCount;
  }

  int convertHistoryPageStartIndex(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= historyPages.length) return 0;

    return historyPages[pageIndex].startGroupIndex;
  }

  int convertHistoryPageEndIndex(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= historyPages.length) return 0;

    return historyPages[pageIndex].endGroupIndex;
  }
}

// 分组数量计算逻辑
List<int> calculateGroupCounts(Map<String, int> groups, int total) {
  final indices = groups.values.toList()..add(total);

  return List.generate(groups.length, (i) => indices[i + 1] - indices[i]);
}

/// 将按时间分组后的每组条数切分为页，单页不超过 [pageCount] 条；
/// 若单个分组本身已达到或超过 [pageCount]，该分组独占一页，不会跳过相邻分组。
List<HistoryPageRange> buildHistoryPages(
  List<int> groupCounts, {
  int pageCount = 30,
}) {
  if (groupCounts.isEmpty) return const [];

  final List<HistoryPageRange> pages = [];

  int startGroupIndex = 0;
  int startItemIndex = 0;
  int currentPageItemCount = 0;
  int currentItemIndex = 0;

  for (int groupIndex = 0; groupIndex < groupCounts.length; groupIndex++) {
    final int currentCount = groupCounts[groupIndex];

    if (currentCount >= pageCount) {
      // 先结算前面累积的小分组
      if (currentPageItemCount > 0) {
        pages.add(
          HistoryPageRange(
            startGroupIndex: startGroupIndex,
            endGroupIndex: groupIndex - 1,
            startItemIndex: startItemIndex,
            endItemIndex: currentItemIndex - 1,
          ),
        );
        currentPageItemCount = 0;
      }

      // 超大分组独占一页
      pages.add(
        HistoryPageRange(
          startGroupIndex: groupIndex,
          endGroupIndex: groupIndex,
          startItemIndex: currentItemIndex,
          endItemIndex: currentItemIndex + currentCount - 1,
        ),
      );

      currentItemIndex += currentCount;
      startGroupIndex = groupIndex + 1;
      startItemIndex = currentItemIndex;
      continue;
    }

    if (currentPageItemCount > 0 && currentPageItemCount + currentCount > pageCount) {
      pages.add(
        HistoryPageRange(
          startGroupIndex: startGroupIndex,
          endGroupIndex: groupIndex - 1,
          startItemIndex: startItemIndex,
          endItemIndex: currentItemIndex - 1,
        ),
      );

      startGroupIndex = groupIndex;
      startItemIndex = currentItemIndex;
      currentPageItemCount = 0;
    }

    currentPageItemCount += currentCount;
    currentItemIndex += currentCount;
  }

  if (currentPageItemCount > 0) {
    pages.add(
      HistoryPageRange(
        startGroupIndex: startGroupIndex,
        endGroupIndex: groupCounts.length - 1,
        startItemIndex: startItemIndex,
        endItemIndex: currentItemIndex - 1,
      ),
    );
  }

  return pages;
}
