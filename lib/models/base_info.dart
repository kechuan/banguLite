import 'package:bangu_lite/models/user_details.dart';

abstract class BaseInfo {
  BaseInfo({this.id});

  // 通用ID字段 因为需求被修改 因此不作final
  int? id; 

}

// Content: Topic/Blog 这种单人开题 ...肯定拥有的属性
abstract class ContentInfo extends BaseInfo {
  ContentInfo({
    super.id,
	  this.contentTitle
  });

  //Blog/Topic 应需求
  int? sourceID;
  //String? sourceTitle;

  //title
  String? contentTitle;

  int? createdTime;
  int? updatedTime;
  
  int? repliesCount;
  String? lastRepliedNickName;
  int? lastRepliedTime;

  //user
  UserInformation? userInformation;


  // 工厂方法，创建空对象
  factory ContentInfo.empty() {
    throw UnimplementedError('BaseInfo.empty() must be implemented by subclasses');
  }

}