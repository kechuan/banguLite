import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class BangumiSummary extends StatelessWidget {
  const BangumiSummary({
    super.key,
    this.summary
  });

  final String? summary;

  @override
  Widget build(BuildContext context) {

    final ValueNotifier<bool> expandedSummaryNotifier = ValueNotifier<bool>(false);

    //功能等待实现: 1初始时固定size 用户展开时 变成滚动组件 也可以恢复成原来的样子
    debugPrint("summary rebuild");

    if(summary == null || summary!.isEmpty){
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
              padding: EdgeInsets.symmetric(vertical: 8), //16
              child: ScalableText("简介",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)), // 24*(aspectRatio) => 34
            ),
        
            Center(child: ScalableText("该番剧暂无简介..."),)
          ],
        ),
      );
                            
    }

    return ValueListenableBuilder(
      valueListenable: expandedSummaryNotifier,
      builder: (_,expandedStatus,child) {
        return Stack(
          children: [

            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: expandedStatus ? 300 : MediaQuery.sizeOf(context).height/4,
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width,
              ),
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (_,constraint) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8), //16
                        child: ScalableText("简介",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)), // 24*(aspectRatio) => 34
                      ),
                  
                      expandedStatus ? 
                      Expanded(child: child!) : 
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: constraint.maxHeight - 50, // 16 + 34 => 50
                        ),
                        child: child!,
                      ),
                  
                      expandedStatus ?
                      Align(
                        alignment: const Alignment(1.0, 0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1,color: Colors.green),
                            borderRadius: BorderRadius.circular(24),
                            
                          ),
                          child: TextButton(
                            onPressed: ()=> expandedSummaryNotifier.value = false, 
                            child: const ScalableText("收缩")
                          ),
                        )) :
                      const SizedBox.shrink()
                  
                    ],
                  );
                }
              ),
            ),

            Positioned.fill(
              child: Offstage(
                offstage: expandedStatus,
                child: InkResponse(
                  onTap: () => expandedSummaryNotifier.value = !expandedSummaryNotifier.value,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment(0, 0.3),
                        colors: [
                          Color.fromRGBO(162, 167, 146, 0.329),Colors.transparent
                        ]
                      )
                    ),
                  ),
                ),
              ),
            )
          
          ],
        );
      },
      child: 
        SizedBox(
          width: double.infinity,
          child: ScalableText(
            selectable: true,
            summary ?? "no Data",
            style: const TextStyle(overflow: TextOverflow.ellipsis),          
          ),
        )
        
          
        //debugPrint("summary constriant:${constriant.maxHeight}, context:${MediaQuery.sizeOf(context).aspectRatio}");
             
          
        
      
    );
  }
}