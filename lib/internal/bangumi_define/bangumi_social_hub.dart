import 'package:flutter/material.dart';

enum BangumiPrivateHubType{

  user("个人中心",Icons.account_circle_outlined),
  email("消息提醒",Icons.email_outlined),
  ;

  final String typeName;
  final IconData iconData;

  const BangumiPrivateHubType(this.typeName,this.iconData);
}

enum BangumiSocialHubType{
  //超展开隔离 实则允许切换

  group("小组",Icons.forum_outlined),
  timeline("时间线",Icons.history),
  
  ;

  final String typeName;
  final IconData iconData;

  const BangumiSocialHubType(this.typeName,this.iconData);
}

enum BangumiTimelineType{
  all("全部",Icons.history),
  timeline("时间线",Icons.history),
  group("小组",Icons.forum_outlined),
  subject("条目",Icons.crop_free),
  //条目 有两组内容 Topic / Blog
  // 但API目前只有 trending 与 latest Topic 并没有 Blog...

  //全部就意味着。。所有的API都要请求 然后还要自己编排createdAt排序
  //实际上等于填充了 timelinesData 的所有类别
  
  ;

  final String typeName;
  final IconData iconData;

  const BangumiTimelineType(this.typeName,this.iconData);
}

enum BangumiSurfGroupType {

  all("全部"),
  joined("我加入的"),
  created("我创立的"),
  replied("我回复过"),
  ;

  final String typeName;
  

  const BangumiSurfGroupType(this.typeName);

}