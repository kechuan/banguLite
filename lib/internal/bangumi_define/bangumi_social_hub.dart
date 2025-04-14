import 'package:flutter/material.dart';

enum BangumiPrivateHubType{

  user("个人中心",Icons.account_circle_outlined),
  email("消息提醒",Icons.email_outlined),
  friends("我的好友",Icons.supervisor_account_outlined),
  ;

  final String typeName;
  final IconData iconData;

  const BangumiPrivateHubType(this.typeName,this.iconData);
}

enum BangumiSocialHubType{
  //超展开隔离 实则允许切换

  subject("条目",Icons.crop_free),
  group("小组",Icons.forum_outlined),
  timeline("时间线",Icons.history),
  
  ;

  final String typeName;
  final IconData iconData;

  const BangumiSocialHubType(this.typeName,this.iconData);
}