
import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/providers/bangumi_model.dart';
import 'package:bangu_lite/models/providers/review_model.dart';
import 'package:bangu_lite/widgets/fragments/cached_image_loader.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';


class BangumiDetailRecentReview extends StatelessWidget {
  const BangumiDetailRecentReview({
    super.key,
    this.name,
    required this.collapseStatusNotifer,
  });

  final String? name;
  final ValueNotifier<bool> collapseStatusNotifer;

  @override
  Widget build(BuildContext context) {

    //final ValueNotifier<bool> reviewCollapseStatusNotifier = ValueNotifier(true);

    return Padding(
      padding: Padding16,
      child: Consumer<ReviewModel>(
        builder: (_,reviewModel,child) {

            return ExpansionTile(
              initiallyExpanded: !collapseStatusNotifer.value,
              tilePadding: const EdgeInsets.all(0),
              showTrailingIcon: false,
              shape: const Border(),
              onExpansionChanged: (topicExpandedStatus) => collapseStatusNotifer.value = !topicExpandedStatus,
              title: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8), //16
                    child: Row(
                      children: [
                        const ScalableText("长评",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
                        ValueListenableBuilder(
                          valueListenable: collapseStatusNotifer,
                          builder: (_,topicCollapseStatus,__)=> topicCollapseStatus ? const Icon(Icons.arrow_drop_down_outlined) : const Icon(Icons.arrow_drop_up_outlined)
                        )
                      ],
                    ), 
                  ),
        
                  const Spacer(),
        
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    
                    child: TextButton(
                      onPressed: (){

                        final bangumiModel = context.read<BangumiModel>();

                        //if(reviewModel.contentListData.first.reviewID == 0) return;


                        Navigator.pushNamed(
                          context,
                          Routes.moreReviews,
                          arguments: {
                            "title":name,
                            "reviewModel": reviewModel,
                            "bangumiThemeColor":bangumiModel.bangumiThemeColor
                          }
                        );

                      },
                      child: const ScalableText(
                        "更多长评 >",
                        style: TextStyle(decoration: TextDecoration.underline)
                      ),  
                    )
                  )
            
                ],
              ),
              children: [
                Skeletonizer(
                  enabled: reviewModel.contentListData.isEmpty,
                  child: Builder(
                    builder: (_) {
                      if(reviewModel.contentListData.isEmpty) return const SkeletonListTileTemplate();
                      if(reviewModel.contentListData.first.reviewID == 0) return const Center(child: ScalableText("该番剧暂无用户长评..."));
            
                      return Theme(
                        data: ThemeData(
                          fontFamilyFallback: convertSystemFontFamily(),
                          brightness: judgeDarknessMode(context) ? Brightness.dark : null, 
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: min(3,reviewModel.contentListData.length),
                          separatorBuilder: (_, __) => const Divider(height: 1,),
                          itemBuilder: (context, index) {
                                    
                            final reviewTime = DateTime.fromMillisecondsSinceEpoch(reviewModel.contentListData[index].createdTime!*1000);


                            final previewContent = reviewModel.contentListData[index].summary
                              ?.split(quoteBBcodeRegexp)
                              .last
                              .replaceAll(bbcodeRegexp, '') ?? "";
                                        
                            return ListTile(
                              
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16,
                                children: [

                                  BuildReviewAvatar(
                                    avatarUri: reviewModel.contentListData[index].userInformation?.avatarUrl,
                                    userName: reviewModel.contentListData[index].userInformation?.nickName,
                                  ),


                                  Expanded(
                                    child: Column(
                                      spacing: 6,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ScalableText("${reviewModel.contentListData[index].reviewTitle}",style: const TextStyle(fontWeight: FontWeight.bold),),

										                    //summary 被api限制在最大 120 长度之中
                                        ScalableText(
                                          previewContent,
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 6, //兼顾移动端
                                        ),

                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ScalableText(convertDateTimeToString(reviewTime))
                                        ),
                      
                                                                
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                              onTap: () {



                                //reviewModel.selectedBlogID = reviewModel.contentListData[index].blogID ?? 0;

                                Navigator.pushNamed(
                                  context,
                                  Routes.blog,
                                   arguments: {
                                    "reviewModel":reviewModel,
                                    //"selectedBlogIndex": index,
                                    "reviewInfo": reviewModel.contentListData[index],
                                    //"themeColor": judgeDetailRenderColor(context,bangumiThemeColor),
                                  }
                                );
 
                              },
                            );
                                        
                                        
                          },
                        ),
                      );
                    }
                  ),
                )
              
              ]
            );


        }
      ),
    );
  }
}

class BuildReviewAvatar extends StatelessWidget {
  const BuildReviewAvatar({
    super.key,
    this.avatarUri,
    this.userName
  });

  final String? avatarUri;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    
  return UnVisibleResponse(
    onTap: () {
      //用户界面...
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 24,
      children: [
    
        SizedBox(
          width: judgeLandscapeMode(context) ? 100 : 75,
          height: judgeLandscapeMode(context) ? 100 : 75,
          child: CachedImageLoader(
            imageUrl: avatarUri,
            borderDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0)
            ),
          ),
        ),
    
        SizedBox(
          width: 100,
          
          child: ScalableText(
            "$userName",
            style:const TextStyle(decoration: TextDecoration.underline),
            textAlign: TextAlign.center,
          ),
        )
    
      ],
    ),
  );

  }
}

