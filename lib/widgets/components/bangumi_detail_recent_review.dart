
import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
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
    this.name
  });

  final String? name;

  @override
  Widget build(BuildContext context) {

    final ValueNotifier<bool> reviewCollapseStatusNotifier = ValueNotifier(true);


    return Padding(
      padding: Padding16,
      child: Consumer<ReviewModel>(
        builder: (_,reviewModel,child) {

          bool isReviewEmpty =  
            reviewModel.contentListData.isEmpty ||
            reviewModel.contentListData.first.reviewID == 0
          ;

            return ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.all(0),
              showTrailingIcon: false,
              shape: const Border(),
              onExpansionChanged: (topicCollapseStatus) => reviewCollapseStatusNotifier.value = topicCollapseStatus,
              title: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8), //16
                    child: Row(
                      children: [
                        const ScalableText("长评",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
                        ValueListenableBuilder(
                          valueListenable: reviewCollapseStatusNotifier,
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

                        if(reviewModel.contentListData.first.reviewID == 0) return;


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
                      child: ScalableText(
                        "更多长评 >",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: isReviewEmpty ? Colors.grey : null
                        )
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
                          fontFamily: 'MiSansFont',
                          brightness: judgeDarknessMode(context) ? Brightness.dark : null, 
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: min(3,reviewModel.contentListData.length),
                          separatorBuilder: (_, __) => const Divider(height: 1,),
                          itemBuilder: (context, index) {
                                    
                            final reviewTime = DateTime.fromMillisecondsSinceEpoch(reviewModel.contentListData[index].createdTime!*1000);
                                        
                            return ListTile(
                              
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 16,
                                children: [

                                  SizedBox(
                                    width: 150,
                                    child: BuildReviewAvatar(
                                      avatarUri: reviewModel.contentListData[index].userInformation?.avatarUrl,
                                      userName: reviewModel.contentListData[index].userInformation?.nickName,
                                    ),
                                  ),


                                  Expanded(
                                    child: Column(
                                      spacing: 6,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ScalableText("${reviewModel.contentListData[index].reviewTitle}"),

										                    //summary 被api限制在最大 120 长度之中
                                        ScalableText("${reviewModel.contentListData[index].summary}${reviewModel.contentListData[index].summary?.length == 120 ? "..." : null} "),

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

                                reviewModel.selectedBlogID = reviewModel.contentListData[index].blogID ?? 0;

                                Navigator.pushNamed(
                                  context,
                                  Routes.blog,
                                  arguments: {
                                    "reviewInfo":reviewModel.contentListData[index],
                                    "reviewModel":reviewModel
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
          width: 100,
          height: 100,
          child: CachedImageLoader(
            imageUrl: avatarUri,
            borderDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0)
            ),
          ),
        ),
    
        ScalableText(
          "$userName",
          style:const TextStyle(decoration: TextDecoration.underline),
          textAlign: TextAlign.center,
        )
    
      ],
    ),
  );

  }
}

