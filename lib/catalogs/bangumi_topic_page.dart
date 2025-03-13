import 'package:bangu_lite/internal/bus_register_method.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';

import 'package:bangu_lite/models/topic_details.dart';
import 'package:bangu_lite/models/topic_info.dart';
import 'package:bangu_lite/models/user_details.dart';

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
import 'package:bangu_lite/models/providers/topic_model.dart';

@FFRoute(name: '/subjectTopic')
class BangumiTopicPage extends StatefulWidget {
  const BangumiTopicPage({
    super.key,
    required this.topicModel,
	  required this.topicInfo
  });

  final TopicModel topicModel;
  final TopicInfo topicInfo;

  @override
  State<BangumiTopicPage> createState() => _BangumiTopicPageState();
}

class _BangumiTopicPageState extends LifecycleRouteState<BangumiTopicPage> with RouteLifecycleMixin{

  Future? topicFuture;
  final ScrollController scrollController = ScrollController();
  
  @override
  Widget build(BuildContext context) {

    final topicModel = widget.topicModel;

    return ChangeNotifierProvider.value(
			value: topicModel,
			builder: (context,child){

        if(widget.topicInfo.topicID == 0) return const SizedBox.shrink();

				topicFuture ??= topicModel.loadTopic(widget.topicInfo.topicID!);

				return EasyRefresh.builder(
          scrollController: scrollController,
					childBuilder: (_,physics) {
					
						return Scaffold(

							body: Selector<TopicModel,TopicDetails>(
								selector: (_, topicModel) => topicModel.contentDetailData[widget.topicInfo.topicID!] ?? TopicDetails(),
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

										final TopicDetails? currentTopicDetail = topicModel.contentDetailData[widget.topicInfo.topicID!]; 
								
										bool isCommentLoading = currentTopicDetail == null || currentTopicDetail.topicID == 0;
								
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
                                      ..userInformation = 
                                        (
                                          UserDetails()
                                            ..userID = widget.topicInfo.userInformation?.userID
                                            ..avatarUrl = widget.topicInfo.userInformation?.avatarUrl
                                            ..nickName =  widget.topicInfo.userInformation?.nickName
                                            ..sign = widget.topicInfo.userInformation?.sign
                                        )
                                      
                                      ..comment = currentTopicDetail.content
                                      ..commentTimeStamp = currentTopicDetail.createdTime
                                  ),
                                
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      spacing: 12,
                                      children: [
                                        const ScalableText("回复",style: TextStyle(fontSize: 24)),
                                                  
                                        ScalableText("$commentCount",style: const TextStyle(color: Colors.grey)),
                                                  
                                      ],
                                    ),
                                  ),

                                ],
                              );
                      
                            }
                      
                            //TODO 待修改 改为 first 无评论的显示状态
                            if(currentTopicDetail.topicRepliedComment?.isEmpty == true){
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

