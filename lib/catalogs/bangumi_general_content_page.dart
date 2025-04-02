import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';

import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/base_details.dart';
import 'package:bangu_lite/models/base_info.dart';
import 'package:bangu_lite/models/comment_details.dart';
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
                                    //还是不跳了 重新计算会卡死自己。除非我愿意做分页 
                                    //但是做分页的话 实际上也不能解决评论位置的出现问题。。那就这样了吧 顶多发一个toaster提示是了

                                    //至于显示位置:
                                    //1.学bangumi那样 单独做一个自己回复的 view 出来展示
                                    //2.直接展示在列表顶部 重新访问就保持原来的位置上
                                    //那实际上还是 1 的做法高明

                                    debugPrint("it will insert comment at here: $content");
                                    fadeToaster(context: context, message: "回帖成功");
                                    userCommentList.add(content);
                                    animatedSliverListKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
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
                          itemBuilder: (_,contentCommentIndex,animation){
                        
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
                        
                              if(userCommentList.length <= contentCommentIndex - resultCommentCount){
                                return const SizedBox.shrink();
                              }
                        
                              return RepaintBoundary(
                                child: FadeTransition(
                                  opacity: animation,
                                  child: Column(
                                    children: [
                                      EpCommentView(
                                        postCommentType: PostCommentType.values[getPostCommentType()!.index + 1],
                                        epCommentData: EpCommentDetails()
                                          ..userInformation = contentInfo.userInformation
                                          ..commentID = getSubContentID() ?? contentInfo.id
                                          ..comment = userCommentList[contentCommentIndex - resultCommentCount]
                                          ..commentTimeStamp = contentInfo.createdTime
                                          ..commentReactions = contentDetail?.contentReactions
                                      ),
                                
                                      const Divider()
                                    ],
                                  ),
                                ),
                              );
                        
                        
                              
                            } 
                        
                        
                            
                        
                            
                        
                            return FadeTransition(
                              opacity: animation,
                              child: Column(
                                children: [
                        
                                  if(getPostCommentType() == PostCommentType.replyTopic)
                                    EpCommentView(
                                      postCommentType: PostCommentType.commentTopicReply,
                                      epCommentData: contentDetail!.contentRepliedComment![contentCommentIndex]
                                    ),
                        
                                  if(getPostCommentType() != PostCommentType.replyTopic)
                                    EpCommentView(
                                      postCommentType: PostCommentType.values[getPostCommentType()!.index + 1],
                                      epCommentData: contentDetail!.contentRepliedComment![contentCommentIndex-1]
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