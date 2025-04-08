import 'dart:math';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';

import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/base_details.dart';
import 'package:bangu_lite/models/base_info.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_content_appbar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:bangu_lite/widgets/views/ep_comments_view.dart';
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

  Future<void> loadContent(int contentID);

  //blog 与 其他的 commentLoading 与 CommentCount 判定标注不一样 需要针对重写
  bool isContentLoading(int? contentID){
    return getContentModel().contentDetailData[contentID] == null || 
           getContentModel().contentDetailData[contentID]?.detailID == 0;
  }

  //同上理由 因为 reviewID 不与 blogID 相匹配
  int? getSubContentID() => null;

  PostCommentType? getPostCommentType();
  Color? getcurrentSubjectThemeColor() => null;

  //blog日志里面的内容
  Widget? getFooterWidget() => null;

  int? getCommentCount(D? contentDetail, bool isLoading);

  Future? contentFuture;
  final ScrollController scrollController = ScrollController();

  final GlobalKey<SliverAnimatedListState> animatedSliverListKey = GlobalKey();


  final List<String> userCommentList = [];
  // index:comment record or just add?
  //final Map<int,String> userCommentMap = {};

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
          childBuilder: (_, physics) {

            return Theme(
              data: Theme.of(context).copyWith(
                scaffoldBackgroundColor: getcurrentSubjectThemeColor(),
              ),
              child: Scaffold(
                body: Selector<M, D>(
                  selector: (_, model) => (contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?) ?? createEmptyDetailData(),
                  shouldRebuild: (previous, next) => previous.detailID != next.detailID,
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
                                child: BangumiContentAppbar(
                                  contentID: getSubContentID() ?? contentInfo.id,
                                  titleText: contentInfo.contentTitle,
                                  webUrl: getWebUrl(getSubContentID() ?? contentInfo.id),
                                  postCommentType: getPostCommentType(),
                                  surfaceColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                                  onSendMessage: (content) {
                                    debugPrint("it will insert comment at here: $content");
                                    fadeToaster(context: context, message: "回帖成功");
                                    userCommentList.add(content);
									

                                    WidgetsBinding.instance.addPostFrameCallback((_){
                                      animatedSliverListKey.currentState?.insertItem(0);
                                    });

                                    
                                  },
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
                  
                      final bool isCommentLoading = isContentLoading(getSubContentID() ?? contentInfo.id);
                      final D? contentDetail = contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?;
                      final int commentListCount = (getCommentCount(contentDetail, isCommentLoading) ?? 0);

                      //int resultCommentCount = isCommentLoading ? 3 : (commentListCount+1);
                      int resultCommentCount = (commentListCount+1);

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

                      if(getPostCommentType() == PostCommentType.replyTopic){
                        resultCommentCount-=1;
                      }

                      return SliverPadding(
                        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
                        sliver: SliverAnimatedList(
                          key: animatedSliverListKey,
                          //rebuild不会影响内部 initialItemCount 只能分离逻辑了
                          initialItemCount: resultCommentCount,
                          itemBuilder: (animatedContext,contentCommentIndex,animation){
                        
                            debugPrint("$contentCommentIndex/$resultCommentCount");
                        
                            if(contentCommentIndex == 0){
                              return ListView(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                children: [
                        
                                  if(getPostCommentType() == PostCommentType.replyTopic)
                                    EpCommentView(
                                      postCommentType: PostCommentType.replyTopic,
                                      epCommentData: contentDetail!.contentRepliedComment![contentCommentIndex]
                                    ),
                                  
                                  if(getPostCommentType() != PostCommentType.replyTopic)
                                    EpCommentView(
                                      postCommentType: getPostCommentType(),
                                      epCommentData: EpCommentDetails()
                                        ..userInformation = contentInfo.userInformation
                                        ..commentID = getSubContentID() ?? contentInfo.id
                                        ..comment = contentDetail?.content
                                        ..commentTimeStamp = contentInfo.createdTime
                                        ..commentReactions = contentDetail?.contentReactions
                                    ),
                        
                                  getFooterWidget() ?? const SizedBox.shrink(),
                                
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      spacing: 12,
                                      children: [
                                        const ScalableText("回复",style: TextStyle(fontSize: 24)),
                                
                                        ScalableText("${max(0,commentListCount-1) + userCommentList.length}",style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                
                                  //无评论的显示状态
                                  if(commentListCount == 1 && userCommentList.isEmpty)
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
                                //..userInformation = context.read<AccountModel>().loginedUserInformations.userInformation
                                ..userInformation = 
                                  (									
                                    context.read<AccountModel>()
                                      .loginedUserInformations.userInformation
                                        ?..userName = "818458"
                                  )
                                ..commentID = getSubContentID() ?? contentInfo.id
                                ..comment = userCommentList[contentCommentIndex - resultCommentCount]
                                ..epCommentIndex = "${contentCommentIndex+1}"
                                ..commentTimeStamp = DateTime.now().millisecondsSinceEpoch~/1000
                              ;
                        
                              return FadeTransition(
                                opacity: animation,
                                child: Column(
                                  children: [
                                    if(contentCommentIndex - resultCommentCount == 0)
                                      const Divider(),
                                
                                      EpCommentView(
                                        postCommentType: getPostCommentType(),
                                        onDeleteComment: () {
                                  
                                          userCommentList.removeAt(contentCommentIndex - resultCommentCount);

                                          //因为永远都不可能会移除首项 所以动画项目永远会是+1
                                          int removeAnimatedIndex = contentCommentIndex - resultCommentCount + 1;

                                          if(getPostCommentType() == PostCommentType.replyBlog){
                                            removeAnimatedIndex += 1;
                                          }

                                          SliverAnimatedList.of(animatedContext).removeItem(
                                            removeAnimatedIndex,
                                            duration: const Duration(milliseconds: 300),
                                            (_,animation){

                                              return FadeTransition(
                                                opacity: animation,
                                                child: SizeTransition(
                                                  sizeFactor: animation,
                                                  axis: Axis.vertical,
                                                  child: EpCommentView(
                                                    epCommentData: currentEpCommentDetails
                                                  ),
                                                ),
                                              );
                                        
                                            });
                                  
                                        },
                                        epCommentData: currentEpCommentDetails
                                      ),
                                                                
                                      const Divider()
                                  ],
                                ),
                              );
                        
                            } 
                        

                            return FadeTransition(
                              opacity: animation,
                              child: Column(
                                children: [
                        
                                    EpCommentView(
                                      postCommentType: getPostCommentType(),
                                      onDeleteComment: () {
                                        animatedSliverListKey.currentState!.removeItem(contentCommentIndex, (_,animation) => FadeTransition(
                                          opacity: animation,
                                          child: const SizedBox.shrink(),
                                        ));
                                        
                                      },
                                      epCommentData: contentDetail!.contentRepliedComment![contentCommentIndex]
                                    ),
                        
                                  if(contentCommentIndex < commentListCount - 1)
                                    const Divider()
                                ],
                              ),
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