import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class BangumiRankBox extends StatelessWidget {
  const BangumiRankBox({
    super.key,
    required this.bangumiDetails,
    required this.constraint,
  });

  final BoxConstraints constraint;
  final BangumiDetails bangumiDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: constraint.maxWidth,
      decoration: BoxDecoration(
        
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha:0.4)
        
      ),
      child: Center(
        child: Theme(
          data: ThemeData(
            scrollbarTheme: const ScrollbarThemeData(
              thickness: WidgetStatePropertyAll(0.0),
            ),
            highlightColor: Colors.transparent,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                width: constraint.maxWidth,
                child: Padding(
                  padding: PaddingH12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                              
                          Row(
                            
                            children: [
                          
                              ScalableText(
                                "${bangumiDetails.ratingList["score"]?.toDouble()}",
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Color.fromRGBO(255-(255*((bangumiDetails.ratingList["score"] ?? 0)/10)).toInt(), (255*(((bangumiDetails.ratingList["score"] as num))/10).toInt()), 0, 1),
                                  fontWeight: FontWeight.bold,
                                  decoration: bangumiDetails.ratingList["rank"]!=0 ? null : TextDecoration.lineThrough ,
                                  decorationThickness: 5,
                                  decorationColor: Theme.of(context).scaffoldBackgroundColor,
                                  
                                )
                              ),
                          
                              const Padding(padding: PaddingH6),
                          
                              ScalableText(convertScoreRank(bangumiDetails.ratingList["score"]?.toDouble()),style: const TextStyle()),
                          
                          
                            ],
                          ),
                      
                          //const Padding(padding: PaddingH6),
                      
                          Row(
                            children: [
                              //ScalableText("${bangumiDetails.ratingList["total"]} vote(s)",style: const TextStyle(color: Colors.grey)),
                          
                              const Padding(padding: EdgeInsets.only(left: 6)),
                          
                          
                              ScalableText(bangumiDetails.ratingList["rank"]!=0 ? 'Rank ${convertSubjectType(bangumiDetails.type)} #${bangumiDetails.ratingList["rank"]}' : "暂无排名"),
                                          
                            ],
                          )
                      
                              
                        ],
                      ),

                      ScalableText("${bangumiDetails.ratingList["total"]} vote(s)",style: const TextStyle(color: Colors.grey)),
                    
                    
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemExtent: (constraint.maxWidth/10),
                  physics: const NeverScrollableScrollPhysics(), //禁止用户滑动进度条
                  itemBuilder: (_,index){
                
                    double currentRankRatio;
                
                    if(bangumiDetails.ratingList["total"] == 0){
                       currentRankRatio = 0;
                    }
                
                    else{
                      currentRankRatio = bangumiDetails.ratingList["count"]["${index+1}"] / bangumiDetails.ratingList["total"];
                    }
                
                
                    return Tooltip(
                      verticalOffset: -24,
                      triggerMode: TooltipTriggerMode.tap,
                      message: "${bangumiDetails.ratingList["count"]["${index+1}"]} vote(s), ${(currentRankRatio*100).toStringAsFixed(2)}%",
                      child: Padding(
                        padding: PaddingH6,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          
                          children: [
                                    
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300), 
                              height: min(100,175*currentRankRatio), //理论上最大值应该是200 毕竟极端值 1:1 但不想顶到上方的Score区域
                              color:Theme.of(context).scaffoldBackgroundColor,
                            ),
                                    
                            ScalableText(
                              "${index+1}",
                              style: TextStyle(fontSize: 10,color: currentRankRatio > 0.2 ?Colors.white : Colors.black)
                            ),
                                    
                            
                          ],
                        ),
                      ),
                    );
                    
                    
                    
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
