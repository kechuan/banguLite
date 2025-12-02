
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class BangumiRankBox extends StatefulWidget {
  const BangumiRankBox({
    super.key,
    required this.bangumiDetails,
    required this.constraint,
  });

  final BoxConstraints constraint;
  final BangumiDetails bangumiDetails;

  @override
  State<BangumiRankBox> createState() => _BangumiRankBoxState();
}

class _BangumiRankBoxState extends State<BangumiRankBox> {

  final scoreUpdateNotifier = ValueNotifier(false);

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 300),(){
      scoreUpdateNotifier.value = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: widget.constraint.maxWidth,
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
                width: widget.constraint.maxWidth,
                child: Padding(
                  padding: PaddingH12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                              
                          Row(
                            spacing: 12,
                            
                            children: [
                          
                              ScalableText(
                                "${widget.bangumiDetails.ratingList["score"]?.toDouble()}",
                                style: TextStyle(
                                  color: judgeDarknessMode(context) ? Colors.white : Color.fromRGBO(255-(255*((widget.bangumiDetails.ratingList["score"] ?? 0)/10)).toInt(), (255*(((widget.bangumiDetails.ratingList["score"] as num))/10).toInt()), 0, 1),
                                  fontWeight: FontWeight.bold,
                                  decoration: widget.bangumiDetails.ratingList["rank"]!=0 ? null : TextDecoration.lineThrough ,
                                  decorationThickness: 5,
                                  decorationColor: Theme.of(context).scaffoldBackgroundColor,
                                  
                                )
                              ),
                          
                              ScalableText(convertScoreRank(widget.bangumiDetails.ratingList["score"]?.toDouble()),style: const TextStyle()),
                          
                          
                            ],
                          ),
                      

                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ScalableText(widget.bangumiDetails.ratingList["rank"]!=0 ? 'Rank ${convertSubjectType(widget.bangumiDetails.type)} #${widget.bangumiDetails.ratingList["rank"]}' : "Rank ${convertSubjectType(widget.bangumiDetails.type)} #-"),
                          ),

                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ScalableText("标准差 ${convertRankBoxStandardDiffusion(widget.bangumiDetails.ratingList["total"], widget.bangumiDetails.ratingList["count"].values.toList(), widget.bangumiDetails.ratingList["score"])}",),

                          ScalableText("${widget.bangumiDetails.ratingList["total"]} vote(s)",style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    
                    
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemExtent: (widget.constraint.maxWidth/10),
                  physics: const NeverScrollableScrollPhysics(), //禁止用户滑动进度条
                  itemBuilder: (_,index){
                
                    double currentRankRatio;
                
                    if(widget.bangumiDetails.ratingList["total"] == 0){
                       currentRankRatio = 0;
                    }
                
                    else{
                      currentRankRatio = widget.bangumiDetails.ratingList["count"]["${index+1}"] / widget.bangumiDetails.ratingList["total"];
                    }
                
                    return Tooltip(
                      verticalOffset: -24,
                      triggerMode: TooltipTriggerMode.tap,
                      message: "${widget.bangumiDetails.ratingList["count"]["${index+1}"]} vote(s), ${(currentRankRatio*100).toStringAsFixed(2)}%",
                      child: Padding(
                        padding: PaddingH6,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          
                          children: [
                                    
                            ValueListenableBuilder(
                              valueListenable: scoreUpdateNotifier,
                              builder: (_, updateFlag, __) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300), 
                                  height: updateFlag ? (150*currentRankRatio).clamp(0, 90).toDouble() : 0, //理论上最大值应该是200 毕竟极端值 1:1 但不想顶到上方的Score区域
                                  //height: 0, 
                                  color:Theme.of(context).scaffoldBackgroundColor,
                                );
                              }
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
