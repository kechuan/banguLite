
import 'dart:math';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/group_topic_info.dart';
import 'package:bangu_lite/models/providers/groups_model.dart';
import 'package:bangu_lite/models/surf_timeline_details.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_user_avatar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BangumiTimelineTile extends StatelessWidget {

  const BangumiTimelineTile({
    super.key,
    required this.surfTimelineDetails, 
    this.timelineType,
    this.groupTopicInfo
	
  });

  final SurfTimelineDetails surfTimelineDetails;
  final BangumiTimelineType? timelineType;

  final GroupTopicInfo? groupTopicInfo;

  @override
  Widget build(BuildContext context) {
	return ListTile(
    contentPadding: const EdgeInsets.all(0),
		onTap: () {

			debugPrint("timeline DetailID:${surfTimelineDetails.detailID}");

      //web Match but not Match in PostID

			switch(timelineType){
				//等待逻辑分离 => Topic/Blog 以便timeline也能访问。。
				case BangumiTimelineType.subject:{
					//Navigator.pushNamed(
					//	context,
					//	Routes.subjectTopic,
					//	arguments: {
					//		"topicModel":context.read<TopicModel>(),
					//		"index":index,
					//		"themeColor":judgeDetailRenderColor(context,bangumiModel.bangumiThemeColor)
					//	}
					//);

          launchUrlString(BangumiWebUrls.subjectTopic(surfTimelineDetails.detailID ?? 0));
				}
					
				case BangumiTimelineType.group:{

					Navigator.pushNamed(
						context,
						Routes.groupTopic,
						arguments: {
							'groupsModel':context.read<GroupsModel>(),
              'groupTopicInfo':groupTopicInfo,
						}
					);
				}
					

				default:{}
			}


		  
		  
		},
	  title: Row(
		spacing: 12,
		children: [

		  BangumiUserAvatar(
			size: 50,
			userInformation: surfTimelineDetails.commentDetails?.userInformation,
		  ),

		  Expanded(
			child: LayoutBuilder(
			  builder: (_,constraint) {
				return Column(
				  crossAxisAlignment: CrossAxisAlignment.start,
				  children: [
				
					Row(
					  mainAxisAlignment: MainAxisAlignment.spaceBetween,
					  children: [
						ConstrainedBox(
						  constraints: BoxConstraints(
							minWidth: min(constraint.maxWidth*2/3, 250),
							maxWidth: constraint.maxWidth - 80,
						  ),
						  child: BBCodeText(
							data: "${surfTimelineDetails.title}",
							stylesheet: appDefaultStyleSheet(context)
						  )
						),
						
						Row(
						  children: [
							Icon(MdiIcons.chat,size: 16,color: Colors.grey.shade700),
							ScalableText("${surfTimelineDetails.replies}",style: TextStyle(fontSize: 14,color: Colors.grey.shade700)),
						  ],
						),
					  ],
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
									"${timelineType?.typeName == BangumiTimelineType.timeline.typeName ? timelineType?.typeName : "${timelineType?.typeName} · "}",
									
									style: const TextStyle(fontSize: 14,color: Colors.grey)
								),

								Flexible(
									child: UnVisibleResponse(
										onTap: (){

											switch(timelineType) {
											  
											  case BangumiTimelineType.subject:{
												Navigator.pushNamed(
													context,
													Routes.subjectDetail,
													arguments: {"subjectID":surfTimelineDetails.sourceID},
												);
											  }
											    
											    
												//case BangumiTimelineType.group:{
												//		Navigator.pushNamed(
												//			context,
												//			Routes.group,
												//			arguments: {"groupID":surfTimelineDetails.sourceID},
												//		);
												//}

											  default:{}
											    
											    

											}

											
										},
										child: UnVisibleResponse(
											onTap: (){
												debugPrint("${surfTimelineDetails.sourceID}");
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
									surfTimelineDetails.commentDetails?.userInformation?.nickName ?? "匿名用户",
									style: TextStyle(fontSize: 12,color: Colors.grey.shade700)
									),
								),

								ScalableText(
									covertPastDifferentTime(surfTimelineDetails.updatedAt),
									style: TextStyle(fontSize: 12,color: Colors.grey.shade700)
								),
							],
						  ),
						),
					  ],
					)
				
				  ],
				);
			  }
			),
		  )


		  
		],
	  ),

	);
  }
}