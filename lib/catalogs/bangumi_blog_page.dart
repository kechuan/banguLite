import 'package:bangu_lite/internal/bus_register_method.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/blog_details.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';

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
import 'package:bangu_lite/models/providers/review_model.dart';
@FFAutoImport()
import 'package:bangu_lite/models/review_details.dart';

@FFRoute(name: '/Blog')
class BangumiBlogPage extends StatefulWidget {
  const BangumiBlogPage({
    super.key,
    required this.reviewModel,
	required this.reviewInfo
  });

  
  final ReviewModel reviewModel;
  final ReviewInfo reviewInfo;

  @override
  State<BangumiBlogPage> createState() => _BangumiBlogPageState();
}

class _BangumiBlogPageState extends LifecycleRouteState<BangumiBlogPage> with RouteLifecycleMixin {
  
  
  Future? blogFuture;
  final ScrollController scrollController = ScrollController();
  
  //在极端状况之下 说不定会出现 (BangumiDetailPageA)EpPage => BangumiDetailPageB => EpPageB...
  //此时 整个路由链存活的 EpPageState 都会触发这个 AppRoute 那就麻烦了, 因此需要加以管控


  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider.value(
		value: widget.reviewModel,
		builder: (context,child){

			blogFuture ??= widget.reviewModel.loadBlog(widget.reviewInfo.blogID!);

			return EasyRefresh.builder(
				scrollController: scrollController,
				childBuilder: (_,physics) {
				
					return Scaffold(

						body: Selector<ReviewModel,BlogDetails>(
							selector: (_, reviewModel) => reviewModel.contentDetailData[widget.reviewInfo.blogID!] ?? BlogDetails(),
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
												title: ScalableText("${widget.reviewInfo.title}"),
												
												backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha:0.6),
													
													actions: [
													
													IconButton(
														onPressed: () async {
														if(await canLaunchUrlString(BangumiWebUrls.blog(widget.reviewInfo.blogID!))){
															await launchUrlString(BangumiWebUrls.blog(widget.reviewInfo.blogID!));
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
								future: blogFuture,
								builder: (_,snapshot) {

									final BlogDetails? currentBlogDetail = widget.reviewModel.contentDetailData[widget.reviewInfo.blogID!]; 

									// 因为 blog 特有的 blog+Comment 同时加载 因此 还需要关注它的列表问题
									// 然后 widget.reviewInfo.repliedCount 的数据并不准确 因为它计入楼中楼 replied 作为总数目
									bool isCommentLoading = 
										currentBlogDetail == null || //没别的意思 只是消除 nullable
										currentBlogDetail.blogID == null ||
										currentBlogDetail.blogReplies == null
									;
							
									int? commentCount;
							
									if(!isCommentLoading){
										if(currentBlogDetail.blogID != 0){
											commentCount = currentBlogDetail.blogReplies!.length;
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
															..userInformation = widget.reviewInfo.userInformation
															..comment = currentBlogDetail.content
															..commentTimeStamp = widget.reviewInfo.reviewTimeStamp
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
											if(widget.reviewInfo.repliedCount == null || widget.reviewInfo.repliedCount == 0){
												return const Center(
													child: Padding(
														padding: EdgeInsets.only(top:64),
														child: ScalableText("该博客暂无评论..."),
													),
												);
											}

											return EpCommentView(epCommentData: currentBlogDetail.blogReplies![topicCommentIndex-1]);
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
