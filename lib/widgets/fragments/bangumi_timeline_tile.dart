
import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/group_details.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_user_avatar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/star_score_list.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class BangumiTimelineTile extends StatelessWidget {

  const BangumiTimelineTile({
    super.key,
    required this.surfTimelineDetails,
    this.isRecordMode
    
  });

  final SurfTimelineDetails surfTimelineDetails;
  final bool? isRecordMode;


  @override
  Widget build(BuildContext context) {
	  return ListTile(
    contentPadding: const EdgeInsets.all(0),
		onTap: () {

			debugPrint("timeline DetailID:${surfTimelineDetails.detailID} timelineType:${surfTimelineDetails.bangumiTimelineType}");

      ///历史记录的updatedAt 与 展示用的 updatedAt 效果不一致
			switch(surfTimelineDetails.bangumiTimelineType){
				case BangumiTimelineType.subject:{

          if(surfTimelineDetails.sourceTitle == null){
            Navigator.pushNamed(
              context,
              Routes.subjectDetail,
              arguments: {"subjectID":surfTimelineDetails.detailID},
            );
          }

          else{

            MyHive.historySurfDataBase.put(
              surfTimelineDetails.detailID,
              surfTimelineDetails.copyWithUpdateAt(surfTimelineDetails)
            );

            bus.emit(
              "AppRoute",
              BangumiWebUrls.subjectTopic(surfTimelineDetails.detailID ?? 0)
            );

          }
          

				}
					
				case BangumiTimelineType.group:{


          MyHive.historySurfDataBase.put(
            surfTimelineDetails.detailID,
            surfTimelineDetails.copyWithUpdateAt(surfTimelineDetails)
          );

					bus.emit(
            "AppRoute",
            '${BangumiWebUrls.groupTopic(surfTimelineDetails.detailID ?? 0)}?groupTitle=${surfTimelineDetails.title}'
          );
        }

				default:{}
			}


		},
	  title: Column(
		spacing: 6,
	    children: [

        Row(
          spacing: 12,
          children: [

            BangumiUserAvatar(
              size: 50,
              userInformation: surfTimelineDetails.commentDetails?.userInformation,
            ),

            Expanded(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                BBCodeText(
                  data: '${surfTimelineDetails.title}',
                  stylesheet: appDefaultStyleSheet(context)
                ),
                

                if(
                  surfTimelineDetails.commentDetails?.rate != null &&
                  surfTimelineDetails.commentDetails?.rate != 0
                )
                  SizedBox(
                    height: 50,
                    child: StarScoreList(
                      ratingScore: surfTimelineDetails.commentDetails?.rate ?? 0,
                      themeColor: judgeCurrentThemeColor(context),
                    )
                  )
              ],
              ),
            ),


            if(surfTimelineDetails.replies != null)
              Row(
                children: [
                  Icon(MdiIcons.chat,size: 16,color: Colors.grey.shade700),
                  ScalableText("${surfTimelineDetails.replies}",style: TextStyle(fontSize: 14,color: Colors.grey.shade700)),
                ],
              ),
              
          ],
        ),

	      LayoutBuilder(
	        builder: (_,constraint) {
	        if(surfTimelineDetails.commentDetails?.comment != null){
            return Align(
	            alignment: Alignment.centerLeft,
	            child: ConstrainedBox(
	              constraints: BoxConstraints(
	                minWidth: min(constraint.maxWidth*2/3, 250),
	                maxWidth: constraint.maxWidth - 80,
	              ),
	              child: BBCodeText(
	                data: "[quote]${surfTimelineDetails.commentDetails?.comment}[/quote]",
	                stylesheet: appDefaultStyleSheet(context,richless: true)
	              )
	            ),
	          );
          }
	          

          return const SizedBox.shrink();
	        }
	      ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 6,
          children: [
          Flexible(
            flex: 3,
            child: Row(
                            
              children: [
            
                ScalableText(
                  "${surfTimelineDetails.bangumiTimelineType?.typeName ?? ""}"
                  "${surfTimelineDetails.sourceTitle == null ? "" : " · "}"
                  ,
                  style: const TextStyle(fontSize: 14,color: Colors.grey)
                ),

                Flexible(
                  child: UnVisibleResponse(
                  onTap: (){

                    debugPrint("sourceID: ${surfTimelineDetails.sourceID}");

                    //if(surfTimelineDetails.bangumiTimelineType != BangumiTimelineType.timeline){
                    //  MyHive.historySurfDataBase.put(
                    //    surfTimelineDetails.sourceID,
                    //    SurfTimelineDetails(
                    //      detailID: surfTimelineDetails.sourceID
                    //    )
                    //      ..updatedAt = DateTime.now().millisecondsSinceEpoch
                    //      ..title = surfTimelineDetails.sourceTitle
                    //      ..sourceTitle = null
                    //      ..commentDetails = null
                          
                    //  );
                    //}



                    //MyHive.historySurfDataBase.putAt(index, value)

                    switch(surfTimelineDetails.bangumiTimelineType) {

                      //利用callback 加载数据? 否则历史记录里面会缺失avatar 
                      //或者干脆直接在subjectDetail里加载得了。。
                      case BangumiTimelineType.subject:{
                        Navigator.pushNamed(
                        context,
                        Routes.subjectDetail,
                          arguments: {"subjectID":surfTimelineDetails.sourceID},
                        );
                      }
                          
                      case BangumiTimelineType.group:{
                        Navigator.pushNamed(
                          context,
                          Routes.groups,
                          arguments: {
                            "selectedGroupInfo":GroupInfo(
                              id:surfTimelineDetails.detailID
                            )
                            ..groupName = surfTimelineDetails.sourceID
                            ..groupTitle = surfTimelineDetails.sourceTitle
                          },
                        );
                      }

                      default:{}

                    }

                    
                  },
                  child: ScalableText(                              
                    surfTimelineDetails.sourceTitle ?? "",
                    style: const TextStyle(fontSize: 14,color: Colors.grey,decoration: TextDecoration.underline),
                    maxLines: 2,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
      
          Expanded(
            flex: 2,
            child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 6,
            
            children: [
                Flexible(
                  child: ScalableText(
                  surfTimelineDetails.commentDetails?.userInformation?.nickName ?? "",
                  style: const TextStyle(fontSize: 12,color: Colors.grey)
                  ),
                ),


                if(isRecordMode != true)
                  ScalableText(
                    covertPastDifferentTime(surfTimelineDetails.updatedAt),
                    style: const TextStyle(fontSize: 12,color: Colors.grey)
                  ),

            ],
            ),
          ),
          ],
        )
      
	    ],
	  ),

	);
  }
}