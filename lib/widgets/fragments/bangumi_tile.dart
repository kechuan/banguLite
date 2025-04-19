import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/bangumi_details.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';

class BangumiListTile extends ListTile {
  const BangumiListTile({
    super.key,

    required this.imageSize,
    this.bangumiDetails,
    super.trailing,
    super.subtitle,
    super.onTap,


  });

  final BangumiDetails? bangumiDetails;
  final Size imageSize;

  @override
  Widget build(BuildContext context) {

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16),   
      title: Row(
        spacing: 12,
        children: [
          
          SizedBox(
            height: imageSize.height,
            width: imageSize.width, // size 1
            child: CachedImageLoader(
              imageUrl: bangumiDetails?.coverUrl,
            )
          ),
    
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Builder(
                builder: (_) {
                  
                  final currentBangumiTime = DateTime.tryParse(bangumiDetails?.informationList["air_date"] ?? "");

                  return Column(
                    spacing: 6,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  
                        ScalableText(
                          bangumiDetails?.name ?? "name",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  

                        DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: judgeDarknessMode(context) ? Colors.white : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            color: judgeCurrentThemeColor(context).withValues(alpha: 0.2)
                          ),
                          child: Padding(
                            padding: PaddingH12V6,
                            child: Builder(
                              builder: (_) {
                                
                                return ScalableText(
                                  "${currentBangumiTime?.year ?? "-"} 年 ${currentBangumiTime?.month ?? "-"} 月",
                                  
                                  style: const TextStyle(fontSize: 12),
                                );
                              }
                            ),
                          ),
                        ),
                  
                        
                        //获取了bgm信息的话。。说不定可以在收藏页面里面 获取到 自己看了多少集??
                        //唉 真是又一个饼啊。。
                  
                        Builder(
                          builder: (_) {

                            int totalEps = bangumiDetails?.informationList["eps"];
                            int airedEps = currentBangumiTime != null ? convertAiredEps(currentBangumiTime.toString()) : 0;

                            return ScalableText(
                              "共 $totalEps 话"
                              " · ${ airedEps != 0 ? airedEps >= totalEps ? "已完结" : "更新至第 $airedEps 话" : "暂未放送"}",
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                        ),
                  
                        Builder(
                          builder: (_) {
                  
                            return ScalableText(
                              "评分 ${convertDecimalDigitNumString(bangumiDetails?.ratingList["score"])}"
                              "${bangumiDetails?.ratingList["rank"] == 0 ? "" : " #${bangumiDetails?.ratingList["rank"]}"}"
                              ,
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                        ),
                  
                        
                  
                        Builder(
                          builder: (_) {
                  
                            List resultTagList = bangumiDetails?.tagsList.keys.toList() ?? [];

                            if(resultTagList.length > 3){
                              resultTagList = resultTagList.sublist(0,3);
                            }
                  
                            return ScalableText(
                             resultTagList.join(" / ") ,
                              style: const TextStyle(fontSize: 14),
                            );
                          }
                        ),
                  
                        subtitle ?? const SizedBox()
                  
                    ]
                    
                  );
                }
              ),
            ),
          ),
          
          trailing ?? const SizedBox()

        ],
      ),
      onTap: onTap,
    
    );
  }
}

class BangumiGridTile extends StatelessWidget {
    const BangumiGridTile({
      super.key,
      
      this.imageUrl,
      this.bangumiTitle,
      this.onTap, 
      
    });

    final String? imageUrl;
    final String? bangumiTitle;

    final void Function()? onTap;
  
  @override
  Widget build(BuildContext context) {

    return GridTile(
        
      footer: ListTile(
        title: Center(
          child: ScalableText(
            bangumiTitle ?? "loading",
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        )
      ),
    
      child: Stack(
          children: [
                                          
            Positioned.fill(
              child: CachedImageLoader(imageUrl: imageUrl),
            ),
                                          
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin:Alignment.bottomCenter,
                    end:Alignment(0, 0.2),
                    
                    colors:[Color.fromARGB(255, 35, 35, 35),Colors.transparent]
                  ),
                ),
              )
            ),
                                                      
            Positioned.fill(
              child: InkResponse(
                containedInkWell: true,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: onTap,
              )
            )
        
          ],
        ),

    );
  }
}