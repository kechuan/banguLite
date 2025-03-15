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
  
  //title
  String? contentTitle;

  int? createdTime;
  int? repliesCount;
  String? lastRepliedNickName;
  int? lastRepliedTime;

  //user
  UserDetails? userInformation;


  // 工厂方法，创建空对象
  factory ContentInfo.empty() {
    throw UnimplementedError('BaseInfo.empty() must be implemented by subclasses');
  }

}