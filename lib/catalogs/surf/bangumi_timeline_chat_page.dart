



import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/animated/animated_transition.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_content_appbar.dart';


//import 'package:bangu_lite/widgets/fragments/bangumi_timeline_tile.dart';
import 'package:bangu_lite/widgets/fragments/ep_comment_tile.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFAutoImport()
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';

/// 又要有 每个地方都能抵达的通用性(只能通过Url传送) 又要传送封装数据...
/// 。。还是算了 维持现状吧

@FFRoute(name: '/TimelineChat')
class BangumiTimelineChatPage extends StatefulWidget {
  const BangumiTimelineChatPage({
    super.key,
    required this.timelineID,
    required this.comment,

  });

  final int timelineID;
  final String comment;
  

  @override
  State<BangumiTimelineChatPage> createState() => _BangumiTimelineChatPageState();
}

class _BangumiTimelineChatPageState extends State<BangumiTimelineChatPage> {

  Future? timelineChatFuture;

  final GlobalKey<AnimatedListState> animatedListKey = GlobalKey();
  final Map<int,String> userCommentMap = {};

  @override
  Widget build(BuildContext context) {

    if(widget.timelineID == 0) return const SizedBox.shrink();

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
          webUrl: BangumiAPIUrls.timelineReply(widget.timelineID),
          postCommentType: PostCommentType.replyTimeline,
          onSendMessage: (message) {
            userCommentMap.addAll({userCommentMap.length:message as String});
            animatedListKey.currentState?.insertItem(0);
          },
        ),
      ),

      body: SafeArea(
        child: EasyRefresh(
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
              Padding(
                padding: PaddingH16,
                child: ScalableText(
                  widget.comment,
                  selectable: true,
                ),
              ),
        
              const Divider(),
        
              FutureBuilder(
                future: timelineChatFuture,
                builder: (_,snapshot) {
              
                  switch(snapshot.connectionState){
              
                    case ConnectionState.done:{
        
                      List<EpCommentDetails> timelineChatData = loadEpCommentDetails(snapshot.data.data);
        
                      return Expanded(
                        child: AnimatedList.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          key: animatedListKey,
                          initialItemCount: timelineChatData.length,
                          separatorBuilder: (_, index, animation) => const Divider(),
                          removedSeparatorBuilder: (_, index, animation) => const Divider(),
                          itemBuilder: (_, contentCommentIndex, animation) {
        
                            if(contentCommentIndex >= timelineChatData.length){
        
                              final currentEpCommentDetails =  EpCommentDetails()
                                ..userInformation = AccountModel.loginedUserInformations.userInformation
                                ..commentID = null
                                ..comment = userCommentMap[contentCommentIndex - timelineChatData.length]
                                ..epCommentIndex = "${contentCommentIndex+1}"
                                ..commentTimeStamp = DateTime.now().millisecondsSinceEpoch~/1000
                              ;
                        
                              return fadeSizeTransition(
                                animation: animation,
                                child: EpCommentTile(epCommentData: currentEpCommentDetails)
                              );
                            }
        
                            return EpCommentTile(
                              epCommentData: timelineChatData[contentCommentIndex],
                            );
                          },
                        ),
                      );

                    }
              
                    default:{
                      return const Center(child: CircularProgressIndicator());
                    }
                      
                  }
              
                  
                }
              ),
            ],
          )
        ),
      ),
    );
  }
}