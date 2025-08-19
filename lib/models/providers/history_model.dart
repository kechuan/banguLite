import 'package:bangu_lite/delegates/star_sort_strategy.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:flutter/material.dart';

class HistoryModel {

    HistoryModel._();

    static final HistoryModel instance = HistoryModel._();

    factory HistoryModel() => instance;

    List<SurfTimelineDetails> dataSource = [];

    final Map<int, int> localHistoryMap = {};
    final Map<String, int> groupIndices = {};

    late AnimationController bottomBarController;

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
        dataSource.sort((prev, next) => next.updatedAt!.compareTo(prev.updatedAt!));

          for (int starIndex = 0; starIndex < dataSource.length; starIndex++) {

              String headerText = SurfTimeSortStrategy().generateHeaderText(
                  dataSource[starIndex].updatedAt ?? 0
              );

              groupIndices[headerText] ??= starIndex;

          }

          final List<int> groupCounts = calculateGroupCounts(groupIndices, dataSource.length);

          int itemCount = 0;

          for (int currentGroupIndex = 0; currentGroupIndex < groupCounts.length; currentGroupIndex++){
                int currentCount = groupCounts[currentGroupIndex];
                //方案一: 最多30个记录为一页

                if (itemCount + currentCount >= pageCount) {

                    if (currentCount >= pageCount) {
                        currentGroupIndex += 1;
                        localHistoryMap[currentGroupIndex] = itemCount;
                        itemCount = 0;
                        continue;
                    }

                    else {
                        localHistoryMap[currentGroupIndex] = itemCount;
                        //已有的数据 需要额外加入上一个信息的偏移
                        itemCount = currentCount;
                    }

                }

                else {
                    itemCount += currentCount;
                    if (currentGroupIndex == groupCounts.length - 1) {
                        localHistoryMap[currentGroupIndex] = itemCount;
                    }
                }

            }


        debugPrint("localHistoryMap EndOffset/Size: $localHistoryMap");
    }

    // 切换多选模式 -> onToggleSelectionMode
    void toggleMultiSelectMode({bool? isOpen}) async {

      selectedItems.clear();
      multiSelectCountNotifier.value = 0;

          multiSelectModeNotifier.value = isOpen ?? !multiSelectModeNotifier.value;
      
          multiSelectModeNotifier.value ? 
      await bottomBarController.forward() : 
      await bottomBarController.reverse() ;

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

    // 全选/取消全选
    void toggleSelectAll() {
        final dataSource = MyHive.historySurfDataBase.values.toList();

        if (multiSelectCountNotifier.value == dataSource.length) {
            selectedItems.clear();
        }

        else {

            selectedItems.clear();
            selectedItems.addAll(dataSource.map((item) => item.detailID!));
        }

        multiSelectCountNotifier.value = selectedItems.length;

    }

    void clearAllSelectionData(){
      deleteControllers.clear();
      deleteAnimations.clear();
      deletingItems.clear();
      selectedItems.clear();
    }

    void disposeData(){
      localHistoryMap.clear();
      groupIndices.clear();
    }

	int convertHistoryPageStartIndex(int pageIndex){
		return pageIndex == 0 ? 
		0 : 
		localHistoryMap.keys.elementAt(pageIndex - 1);
	}

	int convertHistoryPageEndIndex(int pageIndex){
		return pageIndex == 0 ? 
		localHistoryMap.keys.elementAt(pageIndex) - 1 : 
		localHistoryMap.keys.elementAt(pageIndex);
	}
}


// 分组数量计算逻辑
List<int> calculateGroupCounts(Map<String, int> groups, int total) {
    final indices = groups.values.toList()..add(total);
    return List.generate(groups.length, (i) => indices[i + 1] - indices[i]);
}

