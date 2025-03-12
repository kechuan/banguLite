import 'package:bangu_lite/internal/bus_register_method.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/review_model.dart';
import 'package:bangu_lite/models/review_details.dart';

import 'package:bangu_lite/models/topic_details.dart';
import 'package:bangu_lite/models/topic_info.dart';

import 'package:bangu_lite/widgets/views/ep_comments_view.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher_string.dart';


@FFAutoImport()
@FFRoute(name: '/Blog')
class BangumiBlogPage extends StatelessWidget {
  const BangumiBlogPage({
    super.key,
    required this.reviewModel,
	  required this.ReviewInfo
  });

  
  final ReviewModel reviewModel;
  final ReviewInfo ReviewInfo;

  final TopicInfo topicInfo;

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
			value: reviewModel,
			builder: (context,child){


				topicFuture ??= reviewModel.loadTopic(widget.topicInfo.topicID!);

				return EasyRefresh.builder(
          scrollController: scrollController,
					childBuilder: (_,physics) {
					
						return Scaffold(

							body: Selector<reviewModel,TopicDetails>(
								selector: (_, reviewModel) => reviewModel.contentDetailData[widget.topicInfo.topicID!] ?? TopicDetails(),
								shouldRebuild: (previous, next) => previous != next,
								builder: (_,contentDetailData,topicComment) {

									return Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    thickness: 6,
                    controller: scrollController,
                      child: CustomScrollView(
                        controller: scrollController,
                        physics:physics,
                        slivers: [
                      
                          MultiSliver(
                            children: [
                                                
                              SliverPinnedHeader(
                                child: AppBar(
                                  title: ScalableText("${widget.topicInfo.topicName}"),
                                  
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
                        
                      ),
                    );
									
								},
									
								child: FutureBuilder(
									future: topicFuture,
									builder: (_,snapshot) {

										final TopicDetails? currentTopicDetail = reviewModel.contentDetailData[widget.topicInfo.topicID!]; 
								
										bool isCommentLoading = currentTopicDetail == null ||	currentTopicDetail.topicID == null;
								
										int? commentCount;
								
										if(!isCommentLoading){
											if(currentTopicDetail.topicID != 0){
												commentCount = currentTopicDetail.topicRepliedComment!.isEmpty ? 0 : currentTopicDetail.topicRepliedComment!.length;
											}
										}
								
										return SliverPadding(
                      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
                      sliver: Skeletonizer.sliver(
                        enabled: isCommentLoading,
                        child: SliverList.separated(
                          itemCount: (commentCount ?? 3)+1,
                          itemBuilder: (_,topicCommentIndex){
                            //Loading...
                            if(isCommentLoading){
                              return const SkeletonListTileTemplate(scaleType: ScaleType.min);
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
                                  ),
                                
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        const ScalableText("回复",style: TextStyle(fontSize: 24)),
                                                  
                                        const Padding(padding: PaddingH6),
                                                  
                                        ScalableText("$commentCount",style: const TextStyle(color: Colors.grey)),
                                                  
                                                  
                                      ],
                                    ),
                                  ),

                                ],
                              );
                      
                            }
                      
                            //无评论的显示状态
                            if(currentTopicDetail.topicRepliedComment!.isEmpty){
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top:64),
                                  child: ScalableText("该帖子暂无人评论..."),
                                ),
                              );
                            }

                            return EpCommentView(epCommentData: currentTopicDetail.topicRepliedComment![topicCommentIndex-1]);
                          },
                          separatorBuilder: (_,__,) => const Divider(height: 1)
                        ),
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
              ScalableText("${topicInfoData.topicName}"),
              const Padding(padding: PaddingH6),
            //  ScalableText("${topicInfoData.}",style: const TextStyle(fontSize: 14,color: Colors.grey)),
            ],
          ),
          
        ),

        //ListTile(
        //  title:  ScalableText("${topicInfoData.!.description}"),
        //),

       
      ],
    );
  }
}
