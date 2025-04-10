import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/star_slider_panel.dart';
import 'package:flutter/material.dart';

class StarSubjectDialog extends StatelessWidget {
  const StarSubjectDialog({
    super.key,
    this.preseverdText,
    this.starType = StarType.want,
  });

  final String? preseverdText;
  final StarType starType;

  @override
  Widget build(BuildContext context) {

    final ValueNotifier<bool> commentExpandedStatusNotifier = ValueNotifier(starType != StarType.none);
    final ValueNotifier<double> commentRankNotifier = ValueNotifier(0);

    final TextEditingController contentEditingController = TextEditingController();
    final ExpansionTileController commentExpansionTileController = ExpansionTileController();

    final ValueNotifier<StarType> starTypeNotifier = ValueNotifier<StarType>(starType);

    return Dialog(
      child: ValueListenableBuilder(
        valueListenable: commentExpandedStatusNotifier,
        builder: (_,commentExpandedStatus,child) {
          return AnimatedContainer(
            padding: const EdgeInsets.all(16),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            width: max(300, MediaQuery.sizeOf(context).width/2.5),
            height: max(250, MediaQuery.sizeOf(context).height/3) + (commentExpandedStatus ? 150 : 0),
            child: Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ScalableText(starTypeNotifier.value != StarType.none ? "修改该番剧的收藏状态" : "收藏该番剧",style: const TextStyle(fontSize: 20)),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ScalableText("Bangumi收藏状态 :"),
                    
                    ValueListenableBuilder(
                      valueListenable: starTypeNotifier,
                        builder: (_,starType,child) {
                        return PopupMenuButton<StarType>(
                          initialValue: starTypeNotifier.value,
                          position:PopupMenuPosition.under,
                          itemBuilder: (_) => List.generate(
                            StarType.values.length,
                            (index){
                              return PopupMenuItem(
                                value: StarType.values[index],
                                child: ScalableText(StarType.values[index].starTypeName)
                              );
                            }
                          ),
                          onSelected: (starType){
                            starTypeNotifier.value = starType;
                            if(starType == StarType.none){
                              commentExpandedStatusNotifier.value = false;
                              commentExpansionTileController.collapse();
                            }
                            
                          },
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Padding(
                                  padding: PaddingH6,
                                  child: ScalableText(starType.starTypeName),
                                ),
                            
                                const Icon(Icons.arrow_drop_down)
                            
                              ],
                            ),
                          ),
                          
                          
                        );
                      }
                    )
                  ],
                ),

                if(!commentExpandedStatus) const Spacer(),

              ValueListenableBuilder(
                valueListenable: starTypeNotifier,
                  builder: (_,starType,child) {
                    return ExpansionTile(
                      controller: commentExpansionTileController,
                      enabled: starType != StarType.none,
                      onExpansionChanged: (value) => commentExpandedStatusNotifier.value = value,
                      initiallyExpanded: starType != StarType.none,
                      title: const Text("展开评论与评分"),
                      children: [
                    
                        Center(
                          child: StarSliderPanel(
                            valueNotifier: commentRankNotifier,
                            onChanged: (value) => commentRankNotifier.value = value,
                          ),
                        ),
                    
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: contentEditingController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Typing words...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          
                        )
                      ],
                    );
                  }
                ),

                const Spacer(),


                Row(
                  children: [
                    
                    TextButton(
                      onPressed: () {
                        //仅作本地收藏
                      },
                      child: const ScalableText("仅本地收藏")
                    ),

                    const Spacer(),
     


                    Row(
                      children: [
                        TextButton(
                          onPressed: (){
                    
                            
                              
                            // Navigator.of(context).pop();
                          }, 
                          child: const ScalableText("取消")
                        ),
                        TextButton(
                          onPressed: (){
                              
                            // Navigator.of(context).pop();
                          }, 
                          child: const ScalableText("确定")
                        ),
                      ],
                    ),
                  ],
                )
            
              ],
            ),
          );
        }
      ),
    );
  }
}

void showStarSubjectDialog(
  BuildContext context,
  {String? preseverdText}
){
  showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "'!barrierDismissible || barrierLabel != null' is not true",
      context: context,
      pageBuilder: (_,inAnimation,outAnimation){
        return StarSubjectDialog(
          preseverdText: preseverdText,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation,child: child),
      transitionDuration: const Duration(milliseconds: 300)
    );
}