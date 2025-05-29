import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/judge_condition.dart';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/user_model.dart';
import 'package:bangu_lite/widgets/fragments/animated/animated_transition.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_content_appbar.dart';

import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@FFAutoImport()
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';


@FFRoute(name: '/TimelineChat')
class BangumiTimelineChatPage extends StatefulWidget {
  const BangumiTimelineChatPage({
    super.key,
    required this.timelineID,
    this.comment,
    this.onDeleteAction,
    this.userName,
    this.createdAt,
    

  });

  final int timelineID;
  final String? comment;
  final String? userName;
  final int? createdAt;
  final Function(int)? onDeleteAction;
  

  @override
  State<BangumiTimelineChatPage> createState() => _BangumiTimelineChatPageState();
}

class _BangumiTimelineChatPageState extends State<BangumiTimelineChatPage> {

  Future? timelineFuture;
  Future? timelineChatFuture;

  final GlobalKey<AnimatedListState> animatedListKey = GlobalKey();
  final Map<int,String> userCommentMap = {};

  @override
  Widget build(BuildContext context) {

    if(widget.timelineID == 0) return const SizedBox.shrink();

    timelineFuture ??= HttpApiClient.client.get(
      BangumiAPIUrls.timeline(),
      queryParameters: {
        "mode" : 'all',
        "limit" : 1,
        "until" : (widget.timelineID+1)
      },
      options: BangumiAPIUrls.bangumiAccessOption

    );

    timelineChatFuture ??= HttpApiClient.client.get(
      BangumiAPIUrls.timelineReply(widget.timelineID)
    );


    return Scaffold(

      appBar: AppBar(
        leading: const SizedBox.shrink(),
        leadingWidth: 0,
        title: BangumiContentAppbar(
          contentID: widget.timelineID,
          titleText: '时间线ID: ${widget.timelineID} 的评论',
          
          webUrl: BangumiWebUrls.timelineReplies("user",widget.timelineID),
          
          postCommentType: PostCommentType.replyTimeline,
          onSendMessage: (message) {
            userCommentMap.addAll({userCommentMap.length:message as String});
            animatedListKey.currentState?.insertItem(0);
          },
        ),
      ),

      body: SafeArea(
        child: EasyRefresh(
          child: SingleChildScrollView(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(physics: const NeverScrollableScrollPhysics()),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
                  Builder(
                    
                    builder: (_) {

                      
              
                      final currentEpCommentDetails = EpCommentDetails(
                        commentID: widget.timelineID
                      )
                        ..epCommentIndex = '1'
                        ..comment = widget.comment
                        ..userInformation = UserModel.userData[widget.userName]?.userInfomation
                        ..commentTimeStamp = widget.createdAt
                      ;
              
                      return EpCommentTile(
                        contentID: widget.timelineID,
                        epCommentData: currentEpCommentDetails,
                        postCommentType:PostCommentType.postTimeline,
                        onUpdateComment: (content) {
                      
                          final accountModel = context.read<AccountModel>();
                      
                          invokePopout() => Navigator.pop(context);
                      
                      
                          if(content == null){
                      
                            accountModel.postContent(
                              subjectID: widget.timelineID,
                              postContentType: PostCommentType.postTimeline,
                              actionType: UserContentActionType.delete,
                              fallbackAction: (message){
                                showRequestSnackBar(
                                  message: message,
                                  requestStatus: false,
                                  backgroundColor: judgeCurrentThemeColor(context)
                                );
                              },
                            ).then((resultID){
                              if(resultID != 0){
                                debugPrint("timelineID: $resultID 删除成功");
                                widget.onDeleteAction?.call(resultID);
                                invokePopout();
                              }
                              
                            });
                            
                            
                          }
                      
                        },
                      );
                  
                      
                    }
                  ),
              
                  const Divider(),
              
                  FutureBuilder(
                    future: timelineChatFuture,
                    builder: (_,snapshot) {
                  
                      switch(snapshot.connectionState){
                  
                        case ConnectionState.done:{
                      
                          List<EpCommentDetails> timelineChatData = loadEpCommentDetails(snapshot.data.data);
                      
                          return AnimatedList.separated(
                            shrinkWrap: true, 
                            physics: const NeverScrollableScrollPhysics(),
                            key: animatedListKey,
                            initialItemCount: timelineChatData.isEmpty ? 1 : timelineChatData.length,
                            separatorBuilder: (_, index, animation) => const Divider(),
                            removedSeparatorBuilder: (_, index, animation) => const Divider(),
                            itemBuilder: (_, contentCommentIndex, animation) {
                            
                              if(timelineChatData.isEmpty && userCommentMap.isEmpty){
                                return const Center(
                                  child: Text('该时间线吐槽暂无回复...'),
                                );
                              }
                                              
                              if(contentCommentIndex >= timelineChatData.length){
                                final currentEpCommentDetails =  EpCommentDetails()
                                  ..userInformation = AccountModel.loginedUserInformations.userInformation
                                  ..commentID = null
                                  ..comment = userCommentMap[contentCommentIndex - timelineChatData.length]
                                  ..epCommentIndex = "${contentCommentIndex+2}"
                                  ..commentTimeStamp = DateTime.now().millisecondsSinceEpoch~/1000
                                ;
                          
                                return fadeSizeTransition(
                                  animation: animation,
                                  child: EpCommentTile(
                                    postCommentType: PostCommentType.replyTimeline,
                                    contentID: widget.timelineID,
                                    epCommentData: currentEpCommentDetails
                                  )
                                );
                              }
                                              
                              return EpCommentTile(
                                contentID: widget.timelineID,
                                postCommentType: PostCommentType.replyTimeline,
                                epCommentData: timelineChatData[contentCommentIndex]
                                  ..epCommentIndex = "${contentCommentIndex+2}"
                                ,
                                
                                
                              );
                            },
                          );
                              
                        }
                  
                        default:{
                          return const Center(child: CircularProgressIndicator());
                        }
                          
                      }
                  
                      
                    }
                  ),
                
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}