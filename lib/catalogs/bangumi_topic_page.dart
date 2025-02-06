import 'package:bangu_lite/internal/bus_register_method.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';

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

class _BangumiTopicPageState extends LifecycleRouteState<BangumiTopicPage> {


  bool isActived = true;
  Future? topicFuture;
  final ScrollController scrollController = ScrollController();
  
  //在极端状况之下 说不定会出现 (BangumiDetailPageA)EpPage => BangumiDetailPageB => EpPageB...
  //此时 整个路由链存活的 EpPageState 都会触发这个 AppRoute 那就麻烦了, 因此需要加以管控

  @override
  void initState() {
    bus.on(
      'AppRoute',
      (link) {
        if(!isActived) return;
        if(!mounted) return;
        appRouteMethod(context,link);
      }
    );
    
    super.initState();
  }

  @override
  void didPushNext() {
    isActived = false;
    super.didPushNext();
  }

  @override
  void didPopNext() {
    isActived = true;
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {

    final topicModel = widget.topicModel;

    return ChangeNotifierProvider.value(
			value: topicModel,
			builder: (context,child){


				topicFuture ??= topicModel.loadTopic(widget.topicInfo.topicID!);

				return EasyRefresh.builder(
          scrollController: scrollController,
					header: const MaterialHeader(),

					childBuilder: (_,physics) {
					
						return Scaffold(

							body: Selector<TopicModel,TopicDetails>(
								selector: (_, topicModel) => topicModel.topicDetailData[widget.topicInfo.topicID!] ?? TopicDetails(),
								shouldRebuild: (previous, next) => previous != next,
								builder: (_,topicDetailData,topicComment) {

									return Scrollbar(
                    thumbVisibility: true,
                    interactive: true,
                    thickness: 8,
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

										final TopicDetails? currentTopicDetail = topicModel.topicDetailData[widget.topicInfo.topicID!]; 
								
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
