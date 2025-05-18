import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/extension.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_user_avatar.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';
import 'package:provider/provider.dart';


@FFRoute(name: '/notificationsPage')

class BangumiNotificationsPage extends StatefulWidget {
  const BangumiNotificationsPage({super.key});

  @override
  State<BangumiNotificationsPage> createState() => _BangumiNotificationsPageState();
}

class _BangumiNotificationsPageState extends State<BangumiNotificationsPage> {

  final PageController notificationPageController = PageController();

  final ValueNotifier<int> updateNotifier = ValueNotifier(0);
  final ValueNotifier<int> clearNotifier = ValueNotifier(0);

  
  Future? notificationFuture;

  @override
  Widget build(BuildContext context) {

    final accountModel = context.read<AccountModel>();

    return Scaffold(
      appBar: AppBar(
        title: const ScalableText('信息通知'),
        actions:[
          IconButton(
            icon: const Icon(Icons.notifications_off),
            onPressed: () {

                showTransitionAlertDialog(
                  context,
                  title: "一键已读",
                  content: "即将把所有通知标为已阅",
                  confirmAction: () {
                    
                    accountModel.currentUserNotificaions.also((it){
                      for (var element in it) {
                        element.isUnRead = false;
                      }
                    });

                    accountModel.clearNotifications(
                      fallbackAction: (message){
                        fadeToaster(context: context, message: message);
                      }
                    ).then((result){
                      if(result){
                        updateNotifier.value+=1;
                      }
                    });
                  },
                );

            },
          ),
        ]
      ),
      
      body: EasyRefresh(
        header: const MaterialHeader(),
        footer: const MaterialFooter(),
        
        onRefresh: () {
          notificationFuture = accountModel.getNotifications(
            limit: 40,
            fallbackAction: (message) {
              fadeToaster(context: context, message: message);
            },
          );

          updateNotifier.value+=1;

        },
        child: ValueListenableBuilder(
          valueListenable: updateNotifier,
          builder: (_,__,___) {
            return FutureBuilder(
              future: notificationFuture,
              builder: (_,snapshot) {
            
                switch (snapshot.connectionState) {

                  case ConnectionState.waiting:{
                    return const Center(child: CircularProgressIndicator());
                  }

                  default: {}
                }
            
                return ListView.separated(
                  itemCount: accountModel.currentUserNotificaions.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_,index){
            
                    final currentNotification = accountModel.currentUserNotificaions[index];
            
                    String referenceContent = "";
                    String referenceLink = "";
            
                    switch (currentNotification.notificationType) {
                      case NotificationType.groupTopicReply:
                      case NotificationType.groupPostReply:{
                        referenceLink = BangumiWebUrls.groupTopic(currentNotification.sourceID ?? 0);
                      }
            
            
                      case NotificationType.indexCommentPost:
                      case NotificationType.indexCommentReply:{
                        referenceLink = BangumiWebUrls.indexComment(currentNotification.sourceID ?? 0);
                      }
            
                      case NotificationType.characterTopicReply:
                      case NotificationType.characterPostReply:{
                        referenceLink = BangumiWebUrls.character(currentNotification.sourceID ?? 0);
                      }
            
                      case NotificationType.subjectTopicReply:
                      case NotificationType.subjectPostReply:{
                        referenceLink = BangumiWebUrls.subjectTopic(currentNotification.sourceID ?? 0);
                      }
            
                      case NotificationType.subjectEPPost:
                      case NotificationType.subjectEPPostReply:{
                        referenceLink = BangumiWebUrls.ep(currentNotification.sourceID ?? 0);
                      }
            
                      case NotificationType.timelineReply:{
                        
                        referenceLink = 
                          '${BangumiAPIUrls.timelineReply(currentNotification.sourceID ?? 0)}'
                          '?timelineID=${currentNotification.sourceID ?? 0}'
                        ;

                      }
            
            
                      default:{}
                    }
            
                    if(referenceLink.isNotEmpty){
                      referenceContent = '[url=$referenceLink]${currentNotification.contentTitle}[/url]';
                    }
                    
                    return ValueListenableBuilder(
                      valueListenable: clearNotifier,
                      builder: (_,__,listTile) {
                        return Opacity(
                          opacity: (currentNotification.isUnRead == true) ? 1 : 0.65,
                          child: listTile!
                        );
                      },
                      child: ListTile(
                        onTap: (){
                          if(![
                            NotificationType.acceptFriend,
                            NotificationType.requestFriend,
                            NotificationType.unknown
                          ].contains(currentNotification.notificationType)
                          ){
                            bus.emit('AppRoute',referenceLink);
                            
                            accountModel.clearNotifications(notificationIDList: [currentNotification.notificationID ?? 0]).then((result){
                              if(result){
                                clearNotifier.value += 1;
                              }
                            });
                            
                          }
                        },
                        title: Row(
                          spacing: 12,
                          children: [
                                              
                            BangumiUserAvatar(
                              size: 50,
                              userInformation: currentNotification.userInformation,
                            ),
                                              
                            Expanded(
                              child: BBCodeText(
                                data: 
                                  '[url=${BangumiWebUrls.user('${currentNotification.userInformation?.userName}')}]${currentNotification.userInformation?.getName()}[/url] '
                                  '${currentNotification.notificationType?.notificationTypeName} '
                                  '$referenceContent ' //回复的内容(可选)
                                  '${
                                    [
                                      //NotificationType.unknown,
                                      NotificationType.requestFriend,
                                      NotificationType.acceptFriend
                                    ].contains(currentNotification.notificationType)
                                    ? ''
                                    : '中回复了你'
                                  }',
                                stylesheet: BBStylesheet(
                                  tags: allEffectTag,
                                  defaultText: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 16,
                                    fontFamilyFallback: convertSystemFontFamily(),
                                  )
                                ),
                                
                              ),
                            ),
                                            
                            if(
                              currentNotification.notificationType == NotificationType.requestFriend &&
                              currentNotification.isUnRead == true
                            )
                              Row(
                                children: [
                                            
                                  IconButton(
                                    onPressed: (){
                                            
                                      accountModel.userRelationAction(currentNotification.userInformation?.userName).then((result){
                                        accountModel.clearNotifications(
                                          notificationIDList: [currentNotification.id ?? 0],
                                          fallbackAction: (message){
                                            fadeToaster(context: context,message: message);
                                          }
                                        ).then((result){
                                          clearNotifier.value +=1;
                                        });
                                      });
                                            
                                      
                                    }, 
                                    icon: const Icon(Icons.done)
                                  ),
                                            
                                  IconButton(
                                    onPressed: (){
                                            
                                      accountModel.clearNotifications(
                                        notificationIDList: [currentNotification.id ?? 0],
                                        fallbackAction: (message){
                                          fadeToaster(context: context,message: message);
                                        }
                                      ).then((result){
                                        clearNotifier.value +=1;
                                      });
                                            
                                    }, 
                                    icon: const Icon(Icons.close)
                                  ),
                                ],
                              ),
                        
                            ScalableText(covertPastDifferentTime(currentNotification.createdTime))
                                            
                          ],
                        ),
                      ),
                    );
                  
                  }
                );
              }
            );
          }
        ),
      ),

    );
  }
}