import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/widgets/fragments/bangumi_timeline_tile.dart';
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

  final ValueNotifier updateNotifier = ValueNotifier(0);

  Future? notificationFuture;

  @override
  Widget build(BuildContext context) {

    final accountModel = context.read<AccountModel>();

    notificationFuture ??= accountModel.getNotifications(
      fallbackAction: (message) {
        fadeToaster(context: context, message: message);
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('信息通知'),),
      body: EasyRefresh(
        header: const MaterialHeader(),
        footer: const MaterialFooter(),
        refreshOnStart: true,
        
        onRefresh: () {
          notificationFuture = accountModel.getNotifications(
            limit: 40,
            fallbackAction: (message) {
              fadeToaster(context: context, message: message);
            },
          );
        },
        child: FutureBuilder(
          future: notificationFuture,
          builder: (_,snapshot) {

            switch (snapshot.connectionState) {
              case ConnectionState.done:{
                debugPrint('notification rebuild');
              }
                
              default: return const Center(child: CircularProgressIndicator());
            }

            return ListView.separated(
              itemCount: accountModel.currentUserNotificaions.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_,index){

                final currentNotification = accountModel.currentUserNotificaions[index];

                return Opacity(
                  opacity: currentNotification.isUnRead == true ? 0.0 : 0.6,
                  child: ListTile(
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
                              '${
                                [
                                  NotificationType.unknown,
                                  NotificationType.requestFriend,
                                  NotificationType.acceptFriend
                                ].contains(currentNotification.notificationType)
                                ? ''
                                : '中回复了你'
                              }',
                            stylesheet: BBStylesheet(
                              tags: allEffectTag,
                              selectableText: true,
                              defaultText: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 16,
                                fontFamilyFallback: convertSystemFontFamily(),
                              )
                            ),
                            
                          ),
                        ),
                
                
                        if(currentNotification.notificationType == NotificationType.requestFriend)
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
                                    );
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
                                  );
                                }, 
                                icon: const Icon(Icons.close)
                              ),
                            ],
                          )
                    
                      ],
                    ),
                  ),
                );
              }
            );
          }
        ),
      ),

    );
  }
}