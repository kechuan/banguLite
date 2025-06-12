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

  final ValueNotifier<int> refreshNotifier = ValueNotifier(0);


  @override
  Widget build(BuildContext context) {

    //widget.获取
    final contentModel = getContentModel();
    final contentInfo = getContentInfo();
    
    return ChangeNotifierProvider.value(
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
                          final int commentListCount = (getCommentCount(contentDetail, isCommentLoading) ?? 0);
                          
                          // 首先 主楼也 依赖 至少 1个 count 来显示
                          // 因此保底 +1
                          // 然后 Topic系内容 天生回复就少1(主楼内容不算入) Blog则保持正常
                          // 因此 Topic系保持不变
                          int resultCommentCount = 
                            isTopicContent() ?
                            commentListCount :
                            commentListCount+1
                          ;
                      
                          /// 载入失败
                          if(snapshot.data == false && contentDetail?.detailID == 0){
                            return const Center(
                              child: ScalableText("加载失败"),
                            );
                          }
                      
                          /// 载入中
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
                          
                          /// 载入成功 开始记录 与 显示页面
                          recordHistorySurf(contentInfo,contentDetail);
                      
                          return SliverSafeArea(
                            sliver: SliverAnimatedList(
                              key: animatedSliverListKey,
                              //rebuild不会影响内部 initialItemCount 只能分离逻辑了
                              initialItemCount: resultCommentCount,
                              itemBuilder: (_,contentCommentIndex,animation){
                            
                                debugPrint("$contentCommentIndex/$resultCommentCount ${getPostCommentType()}");
                            
                                if(contentCommentIndex == 0){
                                  return authorContent(contentInfo, contentDetail);
                                }
                      
                                /// 用户添加回复时:
                                if( 
                                  isTopicContent() ? 
                                  contentCommentIndex >= commentListCount :
                                  contentCommentIndex > commentListCount
                                ){
                      
                                  
                                  // 但因为 animatedList 的 特质 
                                  // 会出现 相等甚至是超越 initialItemCount 的 index(明明没insert)
                                  if(contentCommentIndex < resultCommentCount){
                                    return const SizedBox.shrink();
                                  }

                                  final int newFloor = isTopicContent() ? 
                                    contentCommentIndex+1 :
                                    contentCommentIndex
                                  ;
                      
                                  final currentEpCommentDetails = EpCommentDetails()
                                    ..userInformation = AccountModel.loginedUserInformations.userInformation

                                    //..userInformation = 
                                    //(
                                    //  AccountModel.loginedUserInformations.userInformation?..userName = "shironegi"
                                    //)
                      
                                    //刚刚评论的ID理应无法被Action操作
                                    ..contentID = null
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
                                                    
                                        if(contentCommentIndex != resultCommentCount+userCommentMap.length-1)
                                          const Divider(),
                                      ],
                                    )
                                            
                                  );
                                }
                      
                                /// 常规内容
                                return repliedContent(
                                  isTopicContent() ? contentCommentIndex : contentCommentIndex-1,
                                  contentInfo,
                                  contentDetail
                                );
                                  
                                  
                              },
                            
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
      case PostCommentType.replyGroupTopic:{

        final accessID = getSubContentID() ?? contentInfo.id ?? 0;

        subjectTitle = getPostCommentType() == PostCommentType.replyTopic ? '帖子' : '博客';

        if(accessID == 0) break;

        if(MyHive.historySurfDataBase.keys.contains(accessID)){

          MyHive.historySurfDataBase.put(
            accessID,
            MyHive.historySurfDataBase.get(accessID)!..updatedAt = DateTime.now().millisecondsSinceEpoch
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

    final int commentListCount = (getCommentCount(contentDetail, false) ?? 0);

    final int resultCommentCount = 
      isTopicContent() ?
      commentListCount-1 :
      commentListCount
    ;

      return Column(
        spacing: 12,
        children: [

        
          //Topic的楼主内容 也会放入到 contentRepliedComment 里面。。
          //而Blog内容则不会

          Builder(
            builder: (_){
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
                  ..comment = contentDetail?.content
                  ..commentReactions = contentDetail?.contentReactions

                  ..userInformation = contentDetail?.userInformation ?? contentInfo.userInformation
                  ..commentID = getSubContentID() ?? contentInfo.id
                  ..commentTimeStamp = contentDetail?.createdTime ?? contentInfo.createdTime
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

          

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              spacing: 12,
              children: [
                const ScalableText("回复",style: TextStyle(fontSize: 24)),
                                            
                ScalableText("${max(0,resultCommentCount) + userCommentMap.length}",style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          const Divider(),
        
          //无评论的显示状态
          if(resultCommentCount == 0 && userCommentMap.isEmpty)
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
    I contentInfo,
    D? contentDetail
  ){

    final int commentListCount = (getCommentCount(contentDetail, false) ?? 0);

    return Column(
      children: [

        /// 常规内容
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
                
        if(contentCommentIndex < max(0,commentListCount) + userCommentMap.length - 1)
          const Divider()
      ],
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