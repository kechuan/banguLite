import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/models/providers/history_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

class HistoryRangeSelectDialog extends StatefulWidget {
  const HistoryRangeSelectDialog({
    super.key,
    required this.currentPageIndex
  });

  final int currentPageIndex;

  @override
  State<HistoryRangeSelectDialog> createState() => _HistoryRangeSelectDialogState();
}

class _HistoryRangeSelectDialogState extends State<HistoryRangeSelectDialog> {

  final historyModel = HistoryModel();
  late final FixedExtentScrollController historyPageSelectorController;

  int selectedPageIndex = 0;

  @override
  void initState() {
    historyPageSelectorController = FixedExtentScrollController(initialItem: widget.currentPageIndex);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        height: 250,
        width: 550,
        child: Padding(
          padding: Padding16,
          child: EasyRefresh(
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScalableText("历史记录跳转",style: TextStyle(fontSize: 24)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    	SizedBox(
                        height: 120,
                        width: 250,
                        child: ListWheelScrollView.useDelegate(
                          onSelectedItemChanged: (value) => selectedPageIndex = value,
                          itemExtent: 50,
                          controller: historyPageSelectorController,
                          physics: const FixedExtentScrollPhysics(),
                          childDelegate: ListWheelChildBuilderDelegate(
                            // 因为 localHistoryMap 记录的是 终点 
                            // 而因为最终的数值需要额外一个空间记录 隐藏在范围显示 其实是应该扣除的
                          childCount: historyModel.localHistoryPageMap.length,
                          builder: (_,index){
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ScalableText(
                                  "${historyModel.groupIndices.keys.elementAt(historyModel.convertHistoryPageStartIndex(index))} ~ ${historyModel.groupIndices.keys.elementAt(historyModel.convertHistoryPageEndIndex(index))}"
                                ),
                                const Divider(height: 1)
                              ],
                            );
                          }
                        ),
                      
                        ),
                      ),

                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: ()=>Navigator.of(context).pop(),
                      child: const ScalableText("取消")
                    ),
                    TextButton(
                      onPressed: ()=> Navigator.of(context).pop(selectedPageIndex),
                      child: const ScalableText("确认")
                    )
                  ],
                )

              ],
            ),
          ),
        )
      )
    );
  }
}

Future<int?> showHistoryDateRangeSelectDialog (
  BuildContext context,
  int currentPageIndex,
) async {

    return showGeneralDialog<int?>(
      barrierDismissible: true,
      barrierLabel: "'!barrierDismissible || barrierLabel != null' is not true",
      context: context,
      pageBuilder: (_,inAnimation,outAnimation)=> HistoryRangeSelectDialog(
        currentPageIndex: currentPageIndex,
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation,child: child),
      transitionDuration: const Duration(milliseconds: 300)
    );

}
