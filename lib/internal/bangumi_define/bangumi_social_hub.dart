import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:flutter/material.dart';

enum BangumiCommentAuthorType{
  author('楼主'),
  levelAuthor('层主'),
  self('自己')
  ;

  final String typeName;

  const BangumiCommentAuthorType(this.typeName);
}

enum BangumiPrivateHubType{

  trend("个人动态",Icons.trending_up_outlined),
  //user("个人中心",Icons.account_circle_outlined),
  email("消息提醒",Icons.email_outlined),
  ;

  final String typeName;
  final IconData iconData;

  const BangumiPrivateHubType(this.typeName,this.iconData);
}

enum BangumiSocialHubType{
  //超展开隔离 实则允许切换

  group("小组",Icons.forum_outlined),
  timeline("时间线",Icons.clear_all_sharp),
  history("历史记录",Icons.history),
  
  ;

  final String typeName;
  final IconData iconData;

  const BangumiSocialHubType(this.typeName,this.iconData);
}

enum BangumiSurfTimelineType{
  all("全部",Icons.history),
  subject("条目",Icons.crop_free),
  group("小组",Icons.forum_outlined),
  timeline("时间线",Icons.history),
  // 条目 有两组内容 Topic / Blog
  // 但API目前只有 trending 与 latest Topic 并没有 Blog...


  ;

  final String typeName;
  final IconData iconData;

  const BangumiSurfTimelineType(this.typeName,this.iconData);

  static BangumiSurfTimelineType? fromPostCommentType(PostCommentType? postCommentType){

    if(postCommentType == null) return null;

    if(postCommentType.index.isInRange(PostCommentType.subjectComment.index, PostCommentType.replyTopic.index)){
      return BangumiSurfTimelineType.subject;
    }

    if(postCommentType.index.isInRange(PostCommentType.postGroupTopic.index, PostCommentType.replyGroupTopic.index)){
      return BangumiSurfTimelineType.group;
    }

    if(postCommentType.index.isInRange(PostCommentType.postTimeline.index, PostCommentType.replyTimeline.index)){
      return BangumiSurfTimelineType.timeline;
    }

    return null;

  }
}

enum BangumiTimelineSortType{
  all("全部"),
  friends("仅好友")
  ;

  final String typeName;
  const BangumiTimelineSortType(this.typeName);

}



enum BangumiSurfGroupType {

  all("全部","热门"),
  joined("我加入的","我加入的"),
  created("我创立的","我创立的"),
  replied("我回复过",""),
  ;

  final String typeName;
  final String groupsType;
  

  const BangumiSurfGroupType(this.typeName,this.groupsType);

}