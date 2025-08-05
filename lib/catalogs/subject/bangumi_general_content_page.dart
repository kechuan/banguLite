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
import 'package:bangu_lite/widgets/fragments/error_load_prompt.dart';
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


  //因为 reviewID 不与 blogID 相匹配 需要额外适配
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

  int? getReferPostContentID();

  //子内容加载(评论)
  Future? contentFuture;

  final scrollController = ScrollController();
  GlobalKey<SliverAnimatedListState> animatedSliverListKey = GlobalKey();
  final authorContentKey = GlobalKey();

  final refreshNotifier = ValueNotifier(0);

  late final commentFilterTypeNotifier = ValueNotifier(
	getReferPostContentID() != null ? 
	BangumiCommentRelatedType.id :
	BangumiCommentRelatedType.normal
  );

  //[Local Record]
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

        //contentFuture ??= loadContent(getSubContentID() ?? contentInfo.id ?? 0);
		    contentFuture ??= loadContent(getSubContentID() ?? contentInfo.id ?? 0);


        return EasyRefresh.builder(
          scrollController: scrollController,
          //重新获取When...
          header: const MaterialHeader(),
          onRefresh: (){
            contentFuture = loadContent(getSubContentID() ?? contentInfo.id ?? 0,isRefresh: true);
            refreshNotifier.value += 1;
          },
          childBuilder: (_,physic){
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
                        physics: physic,
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
                                                    
                                      userCommentMap.addAll({content.$1 ?? 0:content.$2 as String});
                                      
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
                                      
                                    final bool isCommentLoading = isContentLoading(getSubContentID() ?? contentInfo.id) && contentInfo.id != unExistID;
                                    final D? contentDetail = contentModel.contentDetailData[getSubContentID() ?? contentInfo.id] as D?;

                                    final currentEpCommentDetails = contentDetail?.contentRepliedComment;

                                    /// 载入失败
                                    if(snapshot.hasError && contentDetail?.detailID == 0){

                                      return SizedBox(
                                        height: MediaQuery.sizeOf(context).height,
                                        width: MediaQuery.sizeOf(context).width,
                                        child: ErrorLoadPrompt(
                                          message: snapshot.error,
                                          onRetryAction: ()=>loadContent(getSubContentID() ?? contentInfo.id ?? 0,isRefresh: true),
                                        ),
                                        
                                      );
                                    }

                                    if(!isInitaled){
                                      if(currentEpCommentDetails?.isNotEmpty == true){
                                        resultFilterCommentList = [...currentEpCommentDetails!];												

                                        if(isTopicContent()){
                                          resultFilterCommentList.removeAt(0);

                                          debugPrint(
                                            "rawData: ${currentEpCommentDetails.first.epCommentIndex}"
                                          );
                                        }

                                        recordHistorySurf(contentInfo,contentDetail);
                                        isInitaled = true;


                                        if(commentFilterTypeNotifier.value == BangumiCommentRelatedType.id){

                                          debugPrint("trigged referContentID: ${getReferPostContentID()}");

                                          resultFilterCommentList = filterCommentList(
                                            commentFilterTypeNotifier.value,
                                            resultFilterCommentList,
                                            referID: getReferPostContentID()
                                          );

                                          WidgetsBinding.instance.addPostFrameCallback((_){
                                            debugPrint("measure height:${authorContentKey.currentContext?.size?.height},result:${(authorContentKey.currentContext?.size?.height ?? 300) - kToolbarHeight - scrollController.offset}");
                                            scrollController.animateTo(
                                              max(0,(authorContentKey.currentContext?.size?.height ?? 300) - kToolbarHeight - MediaQuery.sizeOf(context).height/3),
                                              duration: const Duration(milliseconds: 500),
                                              curve: Curves.easeOut,
                                            );

                                          });

                                        }

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
                      
                          final bool isCommentLoading = isContentLoading(getSubContentID() ?? contentInfo.id) && contentInfo.id != unExistID;
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
                                    initialItemCount: (contentDetail!.contentRepliedComment!.length - (isTopicContent() ? 1 : 0)),
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
      key: authorContentKey,
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
              isUserContent: true,
              onCommentFilter: (filterCommentType) {
          
                //RESET Aniamted SliverList State
                //if(commentFilterTypeNotifier.value == BangumiCommentRelatedType.id){
                //	//同时也会撤销掉所有的 insertItem/removeItem 毕竟直接重构了
                //	animatedSliverListKey = GlobalKey();
                //}

                if(isTopicContent()){
                  resultFilterCommentList = filterCommentList(
                    filterCommentType,
                    [...contentDetail!.contentRepliedComment!].also((it){
                      it.removeAt(0);
                    }),
                    referID: contentDetail.contentRepliedComment?.first.userInformation?.userID
                  );

                }

                else{
                  resultFilterCommentList = filterCommentList(
                    filterCommentType,
                    contentDetail!.contentRepliedComment!,
                    referID: contentDetail.userInformation?.userID
                  );
                }

                debugPrint("filter content resultFilterCommentList: ${resultFilterCommentList.length}");

          
                
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

	final ValueNotifier<int> commentUpdateFlag = ValueNotifier(0);

    return Column(
      children: [

        /// 常规内容
        ValueListenableBuilder(
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

	// Blog 第一个评论为 第一层, 而 Topic 则以 主楼 为 第一层
	int newFloor = isFiltered ? 
	commentListCount + contentCommentIndex + 1:
	contentCommentIndex + (isTopicContent() ? 1 : 0) + 1
	;

	int newCommentID = isFiltered ?
	userCommentMap.keys.elementAt(newFloor - (commentListCount + contentCommentIndex + 1)) :
	userCommentMap.keys.elementAt(newFloor - (contentCommentIndex + (isTopicContent() ? 1 : 0) + 1))
	;

	final currentEpCommentDetails = EpCommentDetails()
        ..userInformation = AccountModel.loginedUserInformations.userInformation
        ..contentID = contentInfo.id
        ..commentID = newCommentID
        ..comment = userCommentMap[newCommentID]
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
                
                onUpdateComment: (content) {
                  if(content == null){
                    userCommentMap.remove(currentEpCommentDetails.commentID);
                    removeCommentAction(contentCommentIndex,currentEpCommentDetails);
                  }
                      
                  else{
					userCommentMap[currentEpCommentDetails.commentID ?? 0] = content;
                  }      
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