import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/judge_condition.dart';

import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/widgets/fragments/animated/animated_transition.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_content_appbar.dart';
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
  T extends StatefulWidget,
  M extends BaseModel,
  I extends ContentInfo,
  D extends ContentDetails
> extends LifecycleRouteState<T> with RouteLifecycleMixin {

  //widget.*信息获取
  M getContentModel();
  I getContentInfo();
  D createEmptyDetailData();

  String getWebUrl(int? contentID);

  Future<void> loadContent(int contentID,{bool isRefresh = false});

  //blog 与 其他的 commentLoading 与 CommentCount 判定标注不一样 需要针对重写
  bool isContentLoading(int? contentID){
    return getContentModel().contentDetailData[contentID] == null || 
           getContentModel().contentDetailData[contentID]?.detailID == 0;
  }

  //同上理由 因为 reviewID 不与 blogID 相匹配
  int? getSubContentID() => null;

  PostCommentType? getPostCommentType();
  Color? getcurrentSubjectThemeColor();

  //blog日志里面的内容

  List<String>? getTrailingPhotosUri() => null;
  

  int? getCommentCount(D? contentDetail, bool isLoading);

  Future? contentFuture;
  final ScrollController scrollController = ScrollController();

  final GlobalKey<SliverAnimatedListState> animatedSliverListKey = GlobalKey();

  // For record Local comment Change.
  final Map<int,String> userCommentMap = {};


  @override
  Widget build(BuildContext context) {

    //widget.获取
    final contentModel = getContentModel();
    final contentInfo = getContentInfo();
    
    return ChangeNotifierProvider.value(
      value: contentModel,
      builder: (context, child) {

        //debugPrint('sub / id :${getSubContentID()} / ${contentInfo.id}');
        debugPrint('sub / id :${getSubContentID()} / ${contentInfo.id}');

        contentFuture ??= loadContent(getSubContentID() ?? contentInfo.id ?? 0);
        
        return EasyRefresh.builder(
          scrollController: scrollController,
          //重新获取When...
          header: const MaterialHeader(),
          onRefresh: (){
            contentFuture = loadContent(getSubContentID() ?? contentInfo.id ?? 0,isRefresh: true);
          },
          childBuilder: (_, physics) {
            return Theme(
              data: Theme.of(context).copyWith(
                scaffoldBackgroundColor: judgeDarknessMode(context) ? null : getcurrentSubjectThemeColor(),
              ),
              child: Scaffold(
                body: Selector<M, D>(
                  selector: (_, model) => (contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?) ?? createEmptyDetailData(),
                  //shouldRebuild: (previous, next) => previous.detailID != next.detailID,
                  shouldRebuild: (previous, next) => true,
                  builder: (_, contentDetailData, contentComment) {

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
                                      final int commentListCount = getCommentCount(contentDetail, false) ?? 0;
                                                                
                                      int resultCommentCount = 
                                        getPostCommentType() == PostCommentType.replyTopic ?
                                        commentListCount :
                                        commentListCount+1
                                      ;
                                                                
                                      resultCommentCount += userCommentMap.length;
                                                                
                                      userCommentMap.addAll({resultCommentCount:content as String});
                                      
                                      WidgetsBinding.instance.addPostFrameCallback((_){
                                        animatedSliverListKey.currentState?.insertItem(0);
                                      });
                                                             
                                    },
                                  ),
                                )
                              ),
                                    
                              contentComment!
                            ]
                          )
                        ],
                      ),
                    );
                  },
                  child: FutureBuilder(
                    future: contentFuture,
                    builder: (_, snapshot) {

                      if(snapshot.data == false){
                        return const Center(
                          child: ScalableText("加载失败"),
                        );
                      }
		
                      final bool isCommentLoading = isContentLoading(getSubContentID() ?? contentInfo.id) && contentInfo.id != -1;
                      final D? contentDetail = contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?;
                      final int commentListCount = (getCommentCount(contentDetail, isCommentLoading) ?? 0);

                      int resultCommentCount = getPostCommentType() == PostCommentType.replyTopic ?
                      commentListCount :
                      commentListCount+1
                      ;


                      if(contentDetail?.detailID != 0){

                        String? subjectTitle;

                        switch(getPostCommentType()){

                          
                          case PostCommentType.replyTopic:
                          case PostCommentType.replyBlog:{


                            subjectTitle =  getPostCommentType() == PostCommentType.replyTopic ? '帖子' : '博客';

                            

                            MyHive.historySurfDataBase.put(
                              getSubContentID() ?? contentInfo.id ?? 0,
                                SurfTimelineDetails(
                                detailID: getSubContentID() ?? contentInfo.id ?? 0,
                              )
                                ..updatedAt = DateTime.now().millisecondsSinceEpoch
                                ..title = contentDetail?.contentTitle ?? contentInfo.contentTitle
                                ..sourceTitle = subjectTitle
                                ..sourceID = contentInfo.sourceID
                                ..bangumiTimelineType = BangumiTimelineType.fromPostCommentType(getPostCommentType())
                                ..replies = commentListCount
                                ..commentDetails = (
                                  CommentDetails()
                                    ..userInformation = contentDetail?.userInformation ?? contentInfo.userInformation
                                  )
                            );


                          }

                     


                          default:{}
                          
                        }




                      }

                      

                      if(isCommentLoading){
                        return Skeletonizer.sliver(
                          enabled: true,
                          child: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_,index){
                                if(index == 0){
                                  return const SkeletonListTileTemplate(scaleType: ScaleType.medium);
                                }
                                return const SkeletonListTileTemplate(scaleType: ScaleType.min);
                              }
                            ),
                            
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
                        sliver: SliverAnimatedList(
                          key: animatedSliverListKey,
                          //rebuild不会影响内部 initialItemCount 只能分离逻辑了
                          initialItemCount: resultCommentCount,
                          itemBuilder: (animatedContext,contentCommentIndex,animation){
                        
                            //debugPrint("$contentCommentIndex/$resultCommentCount");
                        
                            if(contentCommentIndex == 0){

                              return Column(
                                spacing: 12,
                                children: [

                                  //Topic的楼主内容 也会放入到 contentRepliedComment 里面。。

                                  Builder(builder: (_){

                                    if(
                                      getPostCommentType() == PostCommentType.replyTopic ||
                                      getPostCommentType() == PostCommentType.replyGroupTopic
                                    ){
                                      return EpCommentView(
                                        contentID: contentInfo.id ?? 0,
                                        postCommentType: getPostCommentType(),
                                        epCommentData: contentDetail!.contentRepliedComment?[0] ?? EpCommentDetails()
                                      );
                                    }
                                    
                                    return EpCommentView(
                                      contentID: contentInfo.id ?? 0,
                                      postCommentType: getPostCommentType(),
                                      epCommentData: EpCommentDetails()
                                        ..userInformation = contentDetail?.userInformation ?? contentInfo.userInformation
                                        ..commentID = getSubContentID() ?? contentInfo.id
                                        ..comment = contentDetail?.content
                                        ..commentTimeStamp = contentDetail?.createdTime ?? contentInfo.createdTime
                                        ..commentReactions = contentDetail?.contentReactions
                                    );
                                    
                        
                                  }),


                                  ...List.generate(
                                    getTrailingPhotosUri()?.length ?? 0,
                                    (index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: CachedNetworkImage(
                                          imageUrl: getTrailingPhotosUri()![index],
                                          //photoViewStatus: true,
                                        ),
                                      );
                                    }
                                  ),
                                
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      spacing: 12,
                                      children: [
                                        const ScalableText("回复",style: TextStyle(fontSize: 24)),
                                                                    
                                        ScalableText("${max(0,commentListCount-1) + userCommentMap.length}",style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                
                                  //无评论的显示状态
                                  if(commentListCount == 0 && userCommentMap.isEmpty)
                                    const SizedBox(
                                      height: 64,
                                      child: Center(
                                        child: ScalableText("暂无评论..."),
                                      ),
                                    )
                                
                                ],
                              );
                            }
                        
                            if(contentCommentIndex >= commentListCount){

                              // 一般而言 出现这种情况 只会是 调用了insert
                              // 但实际上是 有时候会出现 相等甚至是超越 initialItemCount 的 index(明明没insert)
                              // 非常的奇怪 可能是因为 animatedList 的 特质
                              if(contentCommentIndex < resultCommentCount){
                                return const SizedBox.shrink();
                              }

                              final currentEpCommentDetails =  EpCommentDetails()
                                ..userInformation = AccountModel.loginedUserInformations.userInformation

                                //..userInformation = 
                                //(
                                //  AccountModel.loginedUserInformations.userInformation?..userName = "shironegi"
                                //)

								                //刚刚评论的ID理应无法被Action操作
                                ..commentID = null
                                ..comment = userCommentMap[contentCommentIndex]
                                ..epCommentIndex = "${contentCommentIndex+1}"
                                ..commentTimeStamp = DateTime.now().millisecondsSinceEpoch~/1000
                              ;
                        
                              return fadeSizeTransition(
                                animation: animation,
                                child: Column(
                                  children: [
                                  if(contentCommentIndex - resultCommentCount == 0)
                                    const Divider(),
                                
                                    EpCommentView(
                                      contentID: contentInfo.id ?? 0,
                                      postCommentType: getPostCommentType(),
                                      
                                      onUpdateComment: (content) {

                                        if(content == null){
                                          userCommentMap.remove(contentCommentIndex - resultCommentCount);
                                                    
                                          SliverAnimatedList.of(animatedContext).removeItem(
                                            contentCommentIndex,
                                            duration: const Duration(milliseconds: 300),
                                            (_,animation){			
                                              return fadeSizeTransition(
                                                animation: animation,
                                                child: EpCommentView(
                                                  contentID: contentInfo.id ?? 0,
                                                  epCommentData: currentEpCommentDetails
                                                ),
                                              );
                                            }
                                          );
                                        }

                                        else{
                                          //新增项目暂不处理
                                        }
                                                      
                                      },
                                      epCommentData: currentEpCommentDetails
                                    ),
                                                
                                    const Divider()
                                  ],
                                )
                                        
                              );
                            }

                            return Column(
                            	children: [

                                Builder(
                                  builder: (_) {

                                    final ValueNotifier<int> commentUpdateFlag = ValueNotifier(0);	

                                    return ValueListenableBuilder(
                                      valueListenable: commentUpdateFlag,
                                      builder: (_,__,child){

                                        final currentEpCommentDetails = contentDetail!.contentRepliedComment?[contentCommentIndex] ?? EpCommentDetails();

                                        if(userCommentMap[contentCommentIndex] != null){
                                          currentEpCommentDetails.comment = userCommentMap[contentCommentIndex];
                                        }


                                        return EpCommentView(
                                          contentID: contentInfo.id ?? 0,
                                          postCommentType: getPostCommentType(),
                                          onUpdateComment: (content) {
                                          
                                            if(content == null){
                                              SliverAnimatedList.of(animatedContext).removeItem(
                                                contentCommentIndex,
                                                duration: const Duration(milliseconds: 300),
                                                (_,animation)=> fadeSizeTransition(
                                                  animation: animation,
                                                  child: EpCommentView(
                                                    contentID: contentInfo.id ?? 0,
                                                    epCommentData: currentEpCommentDetails
                                                  ),
                                                )
                                                
                                              );
                                            }
                        
                                            else{
                                              userCommentMap[contentCommentIndex] = content;
                                              commentUpdateFlag.value += 1;
                                            }
                                          
                                          },
                                          epCommentData: currentEpCommentDetails,
                                          authorID: 
                                           (getPostCommentType() == PostCommentType.replyTopic || getPostCommentType() == PostCommentType.replyGroupTopic) ? 
                                           (contentDetail.contentRepliedComment?[0].userInformation?.userID) : 
                                           contentDetail.userInformation?.userID ?? contentInfo.userInformation?.userID
                                           ,
                                                                    
                                        );
                                      },
                                      
                                    );
                                  }
                                ),
                                        
                                if(contentCommentIndex < commentListCount - 1)
                                  const Divider()
                              ],
                            );
                              
                              
                        },
                        
                          ),
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
}