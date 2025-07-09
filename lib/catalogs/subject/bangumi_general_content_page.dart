import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/judge_condition.dart';

import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/widgets/fragments/animated/animated_transition.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_content_appbar.dart';
import 'package:bangu_lite/widgets/fragments/comment_filter.dart';
import 'package:bangu_lite/widgets/components/general_replied_line.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:bangu_lite/widgets/views/ep_comments_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';

abstract class BangumiContentPageState<
  W extends StatefulWidget,
  M extends BaseModel,
  I extends ContentInfo,
  D extends ContentDetails
> extends LifecycleRouteState<W> with RouteLifecycleMixin {

  //widget.*信息获取
  M getContentModel();
  I getContentInfo();
  D createEmptyDetailData();

  String getWebUrl(int? contentID);


  //同上理由 因为 reviewID 不与 blogID 相匹配
  int? getSubContentID() => null;

  Future<void> loadContent(int contentID,{bool isRefresh = false});

  //blog 与 其他的 commentLoading 与 CommentCount 判定标注不一样 需要针对重写
  bool isContentLoading(int? contentID){
    return getContentModel().contentDetailData[contentID] == null || 
           getContentModel().contentDetailData[contentID]?.detailID == 0;
  }

  List<String>? getTrailingPhotosUri() => null;
  
  int? getCommentCount(D? contentDetail, bool isLoading);

  PostCommentType? getPostCommentType();
  Color? getcurrentSubjectThemeColor();

  BangumiCommentRelatedType? referCommentRelatedType;

  //子内容加载(评论)
  Future? contentFuture;

  final ScrollController scrollController = ScrollController();
  final GlobalKey<SliverAnimatedListState> animatedSliverListKey = GlobalKey();

  final ValueNotifier<int> refreshNotifier = ValueNotifier(0);
  late final ValueNotifier<BangumiCommentRelatedType> commentFilterTypeNotifier = ValueNotifier(referCommentRelatedType ?? BangumiCommentRelatedType.normal);

  bool isInitaled = false;
  // For Record Comment Type List
  List<EpCommentDetails> resultFilterCommentList = [];

  // For record Local comment Change.
  final Map<int,String> userCommentMap = {};
  

  @override
  Widget build(BuildContext context) {

    //widget.获取
    final contentModel = getContentModel();
    final contentInfo = getContentInfo();
    
    return ChangeNotifierProvider.value(
      //因为下方的 Selector 需求 使用 带有contentModel 的context环境
      value: contentModel,
      builder: (context, child) {

        debugPrint('sub / id :${getSubContentID()} / ${contentInfo.id}');

        contentFuture ??= loadContent(getSubContentID() ?? contentInfo.id ?? 0);
        
        return EasyRefresh.builder(
          scrollController: scrollController,
          //重新获取When...
          header: const MaterialHeader(),
          onRefresh: (){
            contentFuture = loadContent(getSubContentID() ?? contentInfo.id ?? 0,isRefresh: true);
            refreshNotifier.value += 1;
          },
          childBuilder: (_, physics) {
            return Theme(
              data: Theme.of(context).copyWith(
                scaffoldBackgroundColor: judgeDarknessMode(context) ? null : getcurrentSubjectThemeColor(),
              ),
              child: Scaffold(
                body: Selector<M, D>(
                  selector: (_, model) => (contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?) ?? createEmptyDetailData(),
                  shouldRebuild: (previous, next) => true,
                  builder: (_, contentDetailData, contentComment) {

					//final bool isCommentLoading = isContentLoading(getSubContentID() ?? contentInfo.id) && contentInfo.id != -1;

                    return Scrollbar(
                      thumbVisibility: true,
                      interactive: true,
                      thickness: 6,
                      controller: scrollController,
                      child: CustomScrollView(
                        controller: scrollController,
                        physics: physics,
                        slivers: [
                          MultiSliver(
                            children: [
                              
								SliverPinnedHeader(
									child: SafeArea(
									bottom: false,
									child: BangumiContentAppbar(
										contentID: getSubContentID() ?? contentInfo.id,
										titleText: contentDetailData.contentTitle ?? contentInfo.contentTitle,
										webUrl: getWebUrl(getSubContentID() ?? contentInfo.id),
										postCommentType: getPostCommentType(),
										surfaceColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
										onSendMessage: (content) {

											final D? contentDetail = contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?;
											int commentListCount = getCommentCount(contentDetail, false) ?? 0;
																				
											commentListCount += (userCommentMap.length + 1);
																		
											userCommentMap.addAll({commentListCount:content as String});
											
											WidgetsBinding.instance.addPostFrameCallback((_){
												animatedSliverListKey.currentState?.insertItem(0);
											});
																
										},
									),
									)
								),


								FutureBuilder(
									future: contentFuture,
									builder: (_, snapshot) {
                      
										final bool isCommentLoading = isContentLoading(getSubContentID() ?? contentInfo.id) && contentInfo.id != -1;
										final D? contentDetail = contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?;

										final currentEpCommentDetails = contentDetail?.contentRepliedComment;

										/// 载入失败
										if(snapshot.data == false && contentDetail?.detailID == 0){
											return const Center(
												child: ScalableText("加载失败"),
											);
										}

										if(!isInitaled){
											if(currentEpCommentDetails?.isNotEmpty == true){

												resultFilterCommentList = [...currentEpCommentDetails!];												

												if(isTopicContent()){
													resultFilterCommentList.removeAt(0);

													debugPrint(
														"isTopicContent: ${resultFilterCommentList.first.epCommentIndex} rawData: ${currentEpCommentDetails.first.epCommentIndex}"
													);
												}

												recordHistorySurf(contentInfo,contentDetail);
												isInitaled = true;
											}
										}

										return isCommentLoading ?
										Skeletonizer.sliver(
											enabled: true,
											child: SliverList(
												delegate: SliverChildBuilderDelegate(
												(_,index){
													if(index == 0){
														return Padding(
															padding: EdgeInsetsGeometry.only(top: 50, bottom: 125),
															child: const SkeletonListTileTemplate(scaleType: ScaleType.medium),
														);
													}
													return const SkeletonListTileTemplate(scaleType: ScaleType.min);
												}
												),
												
											),
										) :

										authorContent(contentInfo,contentDetailData);
								
									}
								),

                              	contentComment!

                            ]
                          )
                        ],
                      ),
                    );
                  },
                  child: ValueListenableBuilder(
                    valueListenable: refreshNotifier,
                    builder: (_,__,___) {
                      return FutureBuilder(
                        future: contentFuture,
                        builder: (_, snapshot) {
                      
                          final bool isCommentLoading = isContentLoading(getSubContentID() ?? contentInfo.id) && contentInfo.id != -1;
                          final D? contentDetail = contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?;

                          /// 载入失败
                          if(snapshot.data == false && contentDetail?.detailID == 0){
                            return const Center(
                              child: SizedBox.shrink()
                            );
                          }
                      
                          if(isCommentLoading) return const SizedBox.shrink();

                          int resultCommentCount = resultFilterCommentList.length;
                      
                          return SliverSafeArea(
                            sliver: ValueListenableBuilder(
                              valueListenable: commentFilterTypeNotifier,
                              builder: (_, commentFilterType, __) {

                                return SliverAnimatedList(
                                  key: animatedSliverListKey,
                                  //rebuild不会影响内部 initialItemCount 只能分离逻辑了
                                  initialItemCount: resultCommentCount,
                                  itemBuilder: (_,contentCommentIndex,animation){
                                
                                    /// 用户添加回复时:
                                    if( contentCommentIndex >= resultCommentCount){
     
                                      
                                      // 但因为 animatedList 的 特质 
                                      // 会出现 相等甚至是超越 initialItemCount 的 index(明明没insert)
                                      if(
                                        contentCommentIndex >= resultCommentCount + userCommentMap.length
                                      ){
                                        return const SizedBox.shrink();
                                      }
                                
                                      return newRepliedContent(
                                        contentCommentIndex,
                                        contentInfo,
                                        animation
                                      );

                                    }
                                                      
                                    /// 常规内容
                                    return repliedContent(
										contentCommentIndex,
                                      	contentInfo,
                                    );
                                      
                                  },
                                
                                );
                              }
                            ),
                          );
                                
                        }
                      );
                    }
                  ),
                )
              ),
            );
          }
        );
      },
    );
  }

  void recordHistorySurf(I contentInfo,D? contentDetail){
    if(contentDetail?.detailID != 0){

    String? subjectTitle;

    switch(getPostCommentType()){

      case PostCommentType.replyTopic:
      case PostCommentType.replyBlog:
    //  case PostCommentType.replyGroupTopic:
	  {

        final accessID = getSubContentID() ?? contentInfo.id ?? 0;

        subjectTitle ??= getPostCommentType() == PostCommentType.replyTopic ? '帖子' : '博客';

        if(accessID == 0) break;

        if(MyHive.historySurfDataBase.keys.contains(accessID)){

          MyHive.historySurfDataBase.put(
            accessID,
            MyHive.historySurfDataBase.get(accessID)!
				..updatedAt = DateTime.now().millisecondsSinceEpoch
				..replies = contentDetail?.contentRepliedComment?.length ?? 0
          );

        }

        else{

          MyHive.historySurfDataBase.put(
            accessID,
              SurfTimelineDetails(
              detailID: getSubContentID() ?? contentInfo.id ?? 0,
            )
              ..updatedAt = DateTime.now().millisecondsSinceEpoch
              ..title = contentDetail?.contentTitle ?? contentInfo.contentTitle
              ..sourceTitle = subjectTitle
              ..sourceID = contentInfo.sourceID
              ..bangumiSurfTimelineType = BangumiSurfTimelineType.fromPostCommentType(getPostCommentType())
              ..replies = contentDetail?.contentRepliedComment?.length ?? 0
              ..commentDetails = (
                CommentDetails()
                  ..userInformation = (
                    isTopicContent() ?
                    contentDetail?.contentRepliedComment?.first.userInformation :
                    contentDetail?.userInformation ?? contentInfo.userInformation
                  )
                )
          );

        }

        


      }

      default:{}
      
    }

  }
  }

  Widget authorContent(I contentInfo, D? contentDetail){

	late EpCommentDetails authorEPCommentData;

      return Column(
        spacing: 12,
        children: [

          Builder(
            builder: (_){

				if(isTopicContent()){

					authorEPCommentData = contentDetail!.contentRepliedComment?[0] ?? EpCommentDetails();
					
					return EpCommentView(
						contentID: contentInfo.id ?? 0,
						postCommentType: getPostCommentType(),
						epCommentData: authorEPCommentData
					);

				}

				authorEPCommentData = EpCommentDetails()
					..comment = contentDetail?.content
					..commentReactions = contentDetail?.contentReactions
					..userInformation = contentDetail?.userInformation ?? contentInfo.userInformation
					..commentID = getSubContentID() ?? contentInfo.id
					..commentTimeStamp = contentDetail?.createdTime ?? contentInfo.createdTime
				;
				
				return EpCommentView(
					contentID: contentInfo.id ?? 0,
					postCommentType: getPostCommentType(),
					epCommentData: authorEPCommentData
				);

              
            }
          ),

          ...List.generate(
            getTrailingPhotosUri()?.length ?? 0,
            (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CachedNetworkImage(
                  imageUrl: getTrailingPhotosUri()![index],
                ),
              );
            }
          ),


          GeneralRepliedLine(
            repliedCount: max(0,resultFilterCommentList.length) + userCommentMap.length,
            commentFilterTypeNotifier: commentFilterTypeNotifier,
            onCommentFilter: (filterCommentType) {

				if(isTopicContent()){
					resultFilterCommentList = filterCommentList(
						filterCommentType,
						[...contentDetail!.contentRepliedComment!].also((it){
							it.removeAt(0);
						})
					);
				}

				else{
					resultFilterCommentList = filterCommentList(
						filterCommentType,
						contentDetail!.contentRepliedComment!
					);
				}

				debugPrint("filter content resultFilterCommentList: $resultFilterCommentList");
              
              	commentFilterTypeNotifier.value = filterCommentType;
            },
          ),

          const Divider(),
        
          //无评论的显示状态
          if(resultFilterCommentList.isEmpty && userCommentMap.isEmpty)
            const SizedBox(
              height: 64,
              child: Center(
                child: ScalableText("暂无评论..."),
              ),
            )
        
        ],
      );
  }

  Widget repliedContent(
    int contentCommentIndex,
    I contentInfo
  ){

    return Column(
      children: [

        /// 常规内容
        Builder(
          builder: (_) {

            final ValueNotifier<int> commentUpdateFlag = ValueNotifier(0);

            return ValueListenableBuilder(
              valueListenable: commentUpdateFlag,
              builder: (_,__,___){
            
                //final currentEpCommentDetails = contentDetail!.contentRepliedComment?[contentCommentIndex] ?? EpCommentDetails();
                final currentEpCommentDetails = resultFilterCommentList[contentCommentIndex];
            
                if(userCommentMap.isNotEmpty && userCommentMap[contentCommentIndex] != null){
                  currentEpCommentDetails.comment = userCommentMap[contentCommentIndex];
                }
            
                return EpCommentView(
                  contentID: contentInfo.id ?? 0,
                  postCommentType: getPostCommentType(),
                  /// 用户更改拥有的内容时
                  onUpdateComment: (content) {
                    if(content == null){
                      removeCommentAction(contentCommentIndex,currentEpCommentDetails);
                    }
                                    
                    else{
                      userCommentMap[contentCommentIndex] = content;
                      commentUpdateFlag.value += 1;
                    }
                  },
                  epCommentData: currentEpCommentDetails,
                  authorID: contentInfo.userInformation?.userID,
                                            
                );
              },
              
            );
          }
        ),
                
        if(contentCommentIndex < max(0,resultFilterCommentList.length) + userCommentMap.length - 1)
          const Divider()
      ],
    );
                             
  }

  Widget newRepliedContent(
    int contentCommentIndex,
    I contentInfo,
    Animation<double> animation
  ){

	bool isFiltered = false;

	final D? contentDetail = getContentModel().contentDetailData[getSubContentID() ?? contentInfo.id] as D?;
	int commentListCount = (getCommentCount(contentDetail, false) ?? 0) - (isTopicContent() ? 1 : 0);

	if(resultFilterCommentList.length != commentListCount) isFiltered = true;

	int newFloor = isFiltered ? 
	userCommentMap.keys.elementAt(contentCommentIndex) : 
	resultFilterCommentList.length + contentCommentIndex - (isTopicContent() ? 0 : 1);

	
	
    
	final currentEpCommentDetails = EpCommentDetails()
        ..userInformation = AccountModel.loginedUserInformations.userInformation
                      
        //刚刚评论的ID理应无法被Action操作
        ..contentID = contentInfo.id
        ..commentID = null
        ..comment = userCommentMap[newFloor]
        ..epCommentIndex = "$newFloor"
        ..commentTimeStamp = DateTime.now().millisecondsSinceEpoch~/1000
      ;

      return fadeSizeTransition(
        animation: animation,
        child: Column(
          children: [

              EpCommentView(
                contentID: contentInfo.id ?? 0,
                postCommentType: getPostCommentType(),
                
                //刚添加的内容理应无法做任何操作
                onUpdateComment: (content) {
                  //if(content == null){
                  //  userCommentMap.remove(contentCommentIndex - resultCommentCount);
                  //  removeCommentAction(contentCommentIndex,currentEpCommentDetails);
                  //}
                      
                  //else{
                  //  //刚添加的回复 无法被编辑
                  //}      
                },
                epCommentData: currentEpCommentDetails
              ),
                        
            if(contentCommentIndex != resultFilterCommentList.length+userCommentMap.length-1)
              const Divider(),
          ],
        )
                
      );
  }

  bool isTopicContent(){
    return [
      PostCommentType.replyTopic,
      PostCommentType.replyGroupTopic,
    ].contains(getPostCommentType());
  }

  void removeCommentAction(
    int contentCommentIndex,
    EpCommentDetails currentEpCommentDetails,
  ){

    final accountModel = context.read<AccountModel>();

    accountModel.toggleComment(
      contentID: currentEpCommentDetails.contentID,
      commentID: currentEpCommentDetails.commentID,
      actionType: UserContentActionType.delete,
      postCommentType: getPostCommentType(),
      fallbackAction: (message) {
        showRequestSnackBar(requestStatus: false,message: message,backgroundColor: judgeCurrentThemeColor(context));
      },
    ).then((resultID){
      if(resultID != 0){

        animatedSliverListKey.currentState?.removeItem(
          contentCommentIndex,
          duration: const Duration(milliseconds: 300),
          (_,animation){			
            return fadeSizeTransition(
              animation: animation,
              child: EpCommentView(
                contentID: getContentInfo().id ?? 0,
                epCommentData: currentEpCommentDetails
              ),
            );
          }
        );

      }
    });

  }

}