import 'package:bangu_lite/models/informations/surf/user_details.dart';

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

  //title
  String? contentTitle;

  int? createdTime;
  int? updatedTime;
  
  int? repliesCount;
  String? lastRepliedNickName;

  //user
  UserInformation? userInformation;

  // 工厂方法，创建空对象 需求交付给子类实现
  factory ContentInfo.empty() {
    throw UnimplementedError('ContentInfo.empty() must be implemented by subclasses');
  }

  Function()? loadInterceptionCallback;

}