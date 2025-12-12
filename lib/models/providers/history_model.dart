import 'package:bangu_lite/delegates/star_sort_strategy.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:flutter/material.dart';

class HistoryModel {

    HistoryModel._();

    static final HistoryModel instance = HistoryModel._();

    factory HistoryModel() => instance;

    List<SurfTimelineDetails> dataSource = [];

    ///示例 groupIndices.key / currentPageSize : {	5: 26, 10: 26, ... }
    //final Map<int, int> localHistoryMap = {};
    final Map<String, int> groupIndices = {};

    //示例:
    final Map<int,List<int>> localHistoryPageMap = {};

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

                int previousHistoryIndexRecord = 
                  localHistoryPageMap.isEmpty ? 
                  0 : 
                  localHistoryPageMap.values.elementAt(localHistoryPageMap.length-1).last + 1
                    
                ;

                if (itemCount + currentCount >= pageCount) {



                    //单独一组数据已经超过30个的情况 单开一页并跳过
                    if (currentCount >= pageCount) {
                        currentGroupIndex += 1;
                        

                        localHistoryPageMap[currentGroupIndex] = [
                          previousHistoryIndexRecord,
                          localHistoryPageMap.isEmpty ? (itemCount - 1) : previousHistoryIndexRecord+itemCount,
                        ];


                        itemCount = 0;
                        continue;
                    }

                    else {

                        localHistoryPageMap[currentGroupIndex] = [
                          previousHistoryIndexRecord,
                          localHistoryPageMap.isEmpty ? (itemCount - 1) : previousHistoryIndexRecord+itemCount,
                        ];


                        itemCount = currentCount;
                    }

                }

                else {
                    itemCount += currentCount;
                    if (currentGroupIndex == groupCounts.length - 1) {

                      localHistoryPageMap[currentGroupIndex] = [
                        previousHistoryIndexRecord,
                        dataSource.length-1,
                      ];

                    }
                }

            }


        debugPrint("localHistoryPageMap: $localHistoryPageMap");
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
    void toggleSelectCurrentPage(int pageIndex) {

      int startIndex = convertHistoryPageStartIndex(pageIndex);
      int endIndex = convertHistoryPageEndIndex(pageIndex) + (pageIndex != (localHistoryPageMap.length - 1) ? 1 : 0);

      //debugPrint("page: $pageIndex/${localHistoryPageMap.length - 1} startIndex: $startIndex, endIndex: $endIndex localHistoryPageMap:$localHistoryPageMap");

        final rangeData = dataSource.sublist(
          groupIndices.values.elementAt(startIndex), 
          (
            pageIndex != (localHistoryPageMap.length - 1) ? 
            groupIndices.values.elementAt(endIndex) : 
            dataSource.length
          )
        );

        for(var currentItem in rangeData){
          if(selectedItems.contains(currentItem.detailID)){
            selectedItems.remove(currentItem.detailID);
          }
          

          else {
            selectedItems.add(currentItem.detailID!);
          }
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
      localHistoryPageMap.clear();
      groupIndices.clear();
    }

  int getCurrentPageGroupCount(int pageIndex){

    if(pageIndex == 0){
      return localHistoryPageMap.keys.elementAt(pageIndex);
    }

    else{
      //在最后的范围判定时 
      return 
        localHistoryPageMap.keys.elementAt(pageIndex) - 
        localHistoryPageMap.keys.elementAt(pageIndex - 1) + 
        (pageIndex == localHistoryPageMap.length - 1 ?  1 : 0)
      ;

   
      
    }
	}

  int convertHistoryPageStartIndex(int pageIndex){
		return pageIndex == 0 ? 
		0 : 
		convertHistoryPageEndIndex(pageIndex-1) + 1;
	}

	int convertHistoryPageEndIndex(int pageIndex){
    return 
      pageIndex == localHistoryPageMap.length - 1 ?
      localHistoryPageMap.keys.last :
      localHistoryPageMap.isEmpty ? 0 : localHistoryPageMap.keys.elementAt(pageIndex) - 1
    ;
	}

}



// 分组数量计算逻辑
List<int> calculateGroupCounts(Map<String, int> groups, int total) {
    final indices = groups.values.toList()..add(total);
    return List.generate(groups.length, (i) => indices[i + 1] - indices[i]);
}

