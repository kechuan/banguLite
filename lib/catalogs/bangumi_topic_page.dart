import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';

import 'package:bangu_lite/models/topic_details.dart';
import 'package:bangu_lite/models/topic_info.dart';

import 'package:bangu_lite/widgets/components/ep_comments.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher_string.dart';

@FFAutoImport()
import 'package:bangu_lite/models/providers/topic_model.dart';

@FFRoute(name: '/subjectTopic')
class BangumiTopicPage extends StatefulWidget {
  const BangumiTopicPage({
    super.key,
    //required this.topicID,
    required this.topicModel,
	required this.topicInfo
  });

  final TopicModel topicModel;
  final TopicInfo topicInfo;
//  final int topicID;

  @override
  State<BangumiTopicPage> createState() => _BangumiTopicPageState();
}

class _BangumiTopicPageState extends State<BangumiTopicPage> {
  @override
  Widget build(BuildContext context) {

    Future? topicFuture;

    //return const SizedBox.shrink();

       return ChangeNotifierProvider.value(
			value: widget.topicModel,
			builder: (context,child){

				final topicModel = widget.topicModel;


				topicFuture ??= topicModel.loadTopic(widget.topicInfo.topicID!);

				return EasyRefresh.builder(
					header: const MaterialHeader(),

					childBuilder: (_,physics) {
					
						return Scaffold( //Listview need materialDesign

							body: Selector<TopicModel,TopicDetails>(
								selector: (_, topicModel) => topicModel.topicDetailData[widget.topicInfo.topicID!] ?? TopicDetails(),
								shouldRebuild: (previous, next) => previous != next,
								builder: (_,topicDetailData,topicComment) {

									return CustomScrollView(
										physics:physics,
										slivers: [

											MultiSliver(
												children: [
													SliverPinnedHeader(
														child: AppBar(
															title: Text("${widget.topicInfo.topicName}"),
															
															backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha:0.6),
							
																actions: [
								
																	IconButton(
																		onPressed: () async {
																			if(await canLaunchUrlString(BangumiWebUrls.subjectTopic(widget.topicInfo.topicID!))){
																			await launchUrlString(BangumiWebUrls.subjectTopic(widget.topicInfo.topicID!));
																			}
																		},
																		icon: Transform.rotate(
																			angle: -45,
																			child: const Icon(Icons.link),
																		)
																	),
								
								
																],
															)
													),

													topicComment!
									
												]
											)

										
										],
										
										
									);
									
								},
									
								child: FutureBuilder(
									future: topicFuture,
									builder: (_,snapshot) {

										final TopicDetails? currentTopicDetail = topicModel.topicDetailData[widget.topicInfo.topicID!]; 
								
								
										bool isCommentLoading = 
											currentTopicDetail == null ||
											currentTopicDetail.id == null
										;
								
										int? commentCount;
								
										if(!isCommentLoading){
											if(currentTopicDetail.id != 0){
												commentCount = currentTopicDetail.repliedComment!.isEmpty ? 1 : currentTopicDetail.repliedComment!.length;
											}
										}

										
								
								
										return Skeletonizer.sliver(
											enabled: isCommentLoading,
											child: SliverList.separated(
												itemCount: (commentCount ?? 3)+1,
												itemBuilder: (_,topicCommentIndex){
													//Loading...
													if(isCommentLoading){
														return const SkeletonListTileTemplate();
													}

													if(topicCommentIndex == 0){

														return ListView(
															physics: const NeverScrollableScrollPhysics(),
															
															shrinkWrap: true,
															children: [
																EpCommentView(
																	epCommentData: EpCommentDetails()
																		..avatarUrl = widget.topicInfo.creatorAvatarUrl
																		..nickName =  widget.topicInfo.creatorNickName
																		..sign = widget.topicInfo.creatorSign
																		..comment = currentTopicDetail.content
																		..commentTimeStamp = currentTopicDetail.createdTime
																		//..epCommentIndex = "0"
															
															
																		
																),
															
																Padding(
																	padding: const EdgeInsets.all(16),
																	child: Row(
																		children: [
																			const Text("回复",style: TextStyle(fontSize: 24)),
																								
																			const Padding(padding: PaddingH6),
																								
																			Text("${commentCount!-1}",style: const TextStyle(color: Colors.grey)),
																								
																								
																		],
																	),
																),
															
															
															],
														);


														//final TopicInfo = ;

														
													}
								
												
												
													//无评论的显示状态
													if(currentTopicDetail.repliedComment!.isEmpty){
														return const Center(
															child: Padding(
																padding: EdgeInsets.only(top:64),
																child: Text("该集数暂无人评论...",style: TextStyle(fontSize: 16)),
															),
														);
													}
													
												
													return EpCommentView(epCommentData: currentTopicDetail.repliedComment![topicCommentIndex-1]);
												},
												separatorBuilder: (_,__,) => const Divider(height: 1), 
											),
										);
								
									}
								),
									
						

							)
						);
					}

				);
			},
		);
   
   }
}

class TopicInfoWidget extends StatelessWidget {
  
  const TopicInfoWidget({
    super.key,
	required this.topicInfoData
    
    
  });

  final TopicInfo topicInfoData;

  @override
  Widget build(BuildContext context) {

    if(topicInfoData.topicID == null){
      return const Skeletonizer(
        child: SkeletonListTileTemplate()
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ListTile(
          title: Row(
            children: [
              Text("${topicInfoData.topicName}"),
              const Padding(padding: PaddingH6),
            //  Text("${topicInfoData.}",style: const TextStyle(fontSize: 14,color: Colors.grey)),
            ],
          ),
          
        ),

        //ListTile(
        //  title:  SelectableText("${topicInfoData.!.description}"),
        //),

       
      ],
    );
  }
}
