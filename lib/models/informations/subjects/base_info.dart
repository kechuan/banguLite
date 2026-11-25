import 'package:bangu_lite/models/informations/surf/user_details.dart';

abstract class BaseInfo {
  BaseInfo({this.id});

  // 通用ID字段 因为需求被修改 因此不作final
  int? id; 


}

// Content: Topic/Blog 这种单人开题 ...肯定拥有的属性
class ContentInfo extends BaseInfo {
  ContentInfo({
    super.id,
    this.contentTitle
  });

  //Blog/Topic 应需求
  int? sourceID;

  //title
  String? contentTitle;

  int? createdTime;
  int? updatedTime;

  int? repliesCount;
  String? lastRepliedNickName;

  //user
  UserInformation? userInformation;

  /// 拦截注入
  Function()? loadInterceptionCallback;

  factory ContentInfo.empty() => ContentInfo(id: 0);

  @override
  bool operator==(Object other) {
    if (identical(this, other)) return true;
    return other is ContentInfo && other.hashCode == hashCode;

  }

  @override
  int get hashCode => id.hashCode;



}
