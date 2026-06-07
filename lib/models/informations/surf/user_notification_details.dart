import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';

class UserNotification extends ContentInfo {

  UserNotification({
    super.id
  });

  int? get notificationID => id;

  NotificationType? notificationType;

  //好友请求 relatedID 为 0,否则即为消息回复提醒
  int? relatedID;
  bool? isUnRead;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserNotification && other.hashCode == hashCode;
  }

  //理论上 notificationID 应该是 immutable 的重要参数
  //数据库不会给已产出的ID再额外做出更改
  @override
  int get hashCode => notificationID.hashCode;
  

}

List<UserNotification> loadUserNotifications(List<dynamic> bangumiNotificationsData){
  final List<UserNotification> notificationsData = [];

  for(Map currentNotificationMap in bangumiNotificationsData){
		UserNotification currentNotification = UserNotification(
      id: currentNotificationMap["id"],
    );
    	
		currentNotification
      ..notificationType = NotificationType.values.firstWhere(
        (currentNotificationType)=>currentNotificationType.notificationTypeIndex == currentNotificationMap["type"],
        orElse: ()=>NotificationType.unknown
      )
      ..contentTitle = currentNotificationMap["title"]
      ..sourceID = currentNotificationMap["mainID"]
      ..relatedID = currentNotificationMap["relatedID"]
      ..createdTime = currentNotificationMap["createdAt"]
      ..userInformation = loadUserInformations(currentNotificationMap['sender'])
      ..isUnRead = currentNotificationMap["unread"]
    ;

    notificationsData.add(currentNotification);
	} 

  return notificationsData;
}