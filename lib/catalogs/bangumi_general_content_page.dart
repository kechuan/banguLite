import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/base_details.dart';
import 'package:bangu_lite/models/base_info.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:bangu_lite/widgets/views/ep_comments_view.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  int? getCommentCount(D? contentDetail, bool isLoading);

  Future? contentFuture;
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {

    //widget.获取
    final contentModel = getContentModel();
    final contentInfo = getContentInfo();
    
    return ChangeNotifierProvider.value(
      value: contentModel,
      builder: (context, child) {

        contentFuture ??= loadContent(getSubContentID() ?? contentInfo.id ?? 0);
        
        return EasyRefresh.builder(
          scrollController: scrollController,
          childBuilder: (_, physics) {
            return Scaffold(
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
                              child: AppBar(
                                title: ScalableText("${contentInfo.contentTitle}"),
                                backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
                                actions: [
                                  IconButton(
                                    onPressed: () async {
                                      if (await canLaunchUrlString(getWebUrl(getSubContentID() ?? contentInfo.id))) {
                                        await launchUrlString(getWebUrl(getSubContentID() ?? contentInfo.id));
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
                    final int? commentCount = getCommentCount(contentDetail, isCommentLoading);

                    return SliverPadding(
                      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + 20),
                      sliver: Skeletonizer.sliver(
                        enabled: isCommentLoading,
                        child: SliverList.separated(
                        itemCount: (isCommentLoading ? 3 : (commentCount ?? 0))+1,
                        itemBuilder: (_,contentCommentIndex){
                        //Loading...
                          if(isCommentLoading){
                            return const SkeletonListTileTemplate(scaleType: ScaleType.min);
                          }

                          if(contentCommentIndex == 0){
                            return ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              children: [

                                EpCommentView(
                                  epCommentData: EpCommentDetails()
                                    ..userInformation = contentInfo.userInformation
                                    ..comment = contentDetail?.content
                                    ..commentTimeStamp = contentInfo.createdTime
                                    ..commentReactions = contentDetail?.contentReactions
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

                                //无评论的显示状态
                                if(commentCount == null || commentCount == 0)
                                const SizedBox(
                                  height: 64,
                                  child: Center(
                                    child: ScalableText("暂无评论..."),
                                  ),
                                )

                              ],
                            );
                          }

                          return EpCommentView(epCommentData: contentDetail!.contentRepliedComment![contentCommentIndex-1]);

                        },
                        separatorBuilder: (_,__) => const Divider(height: 1)
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