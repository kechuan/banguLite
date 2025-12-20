
import 'package:flutter/material.dart';

/// 大部分来自于 API 的 types/common.ts 声明

enum SubjectType {
  book(1,Icons.book_outlined,"书籍"), // 书籍
  anime(2,Icons.live_tv_rounded,"动画"), // 动画
  music(3,Icons.music_note,"音乐"), // 音乐
  game(4,Icons.games_outlined,"游戏"), // 游戏
  real(6,Icons.movie,"三次元"), // 电视剧/电影
  all(7,Icons.select_all,"全部") //全部
  ;

  final int subjectType;
  final IconData iconData;
  final String subjectName;

  const SubjectType(this.subjectType,this.iconData,this.subjectName);
}

extension SubjectTypeExtension on SubjectType {
  static List<int> get subjectTypes {
    return SubjectType.values.map((e) => e.subjectType).toList();
  }
}

enum SortType{
  rank("番剧排名"),
  heat("番剧热度"),
  score("番剧评分"),
  joinTime("收藏时间"),
  updateTime("更新日期"),
  airDate("放送日期")
  
  ;

  
  final String label;

  const SortType(
    this.label,
  );
}

enum CommentState {
  normal("正常"),
  /// #1楼层专属 触发关闭帖子的话 不仅无法评论 还会直接导致游客状态无法进入该帖子
  adminCloseTopic("管理员关闭"), 
  
  adminReopen("管理员重开"),
  adminPin("管理员置顶"),
  adminMerge("管理员合并"),
  adminSilentTopic("管理员下沉"),
  userDelete("自行删除"),
  adminDelete("管理员删除"),
  adminOffTopic("管理员折叠");

  final String reason;

  const CommentState(this.reason);

  bool isNotAvaliable(){
    return [
      CommentState.adminCloseTopic,
      CommentState.userDelete,
      CommentState.adminDelete
    ].contains(this);
  }
}

enum ScoreRank{
  none("未评分",0),
  worst("不忍直视",1), // >1 因为最低的评分就是1
  worse("很差",2), // 1~2
  poor("差",2.5), //2~3
  bad("较差",3.5), //3.5~4.5
  just("不过不失",4.5), //4.5~5.5
  pass("还行",5.5), //5.5~6.5
  great("推荐",6.5), //6.5~7.5
  excellent("力荐",7.5), //7.5 ~ 9
  perfect("神作",9) //9~10
  ;

  final String rankText;
  final double score;

  const ScoreRank(this.rankText,this.score);

}

//目前。。删除收藏的方式好像是。。从时间线直接删除??
//没有 也不是. 在rn版的app里实际上也是通过 前端的操作删除的
//官方的API 尚未提供
enum StarType{
  want(1,"想看"),
  watched(2,"看过"),
  watching(3,"在看"),
  delay(4,"搁置"),
  deprecated(5,"抛弃"),

  none(0,"未收藏")
  ;

  final String starTypeName;
  final int starTypeIndex;
  

  const StarType(this.starTypeIndex,this.starTypeName);

}

enum NotificationType{

  //推测:可能 对于发帖人来说 无论是 回复 亦或者是 楼中楼回复 都被归类于
  // TopicReply 而非 PostReply

  unknown(0,"未知",false),

  //Pass
  groupTopicReply(1,"在你发布的小组话题",false),
  groupPostReply(2,"在小组话题",false),
  groupTopicCall(23,"在小组话题",true),

  //pass subjectTopicPost
  subjectTopicReply(3,"在你发布的条目评论",false),
  subjectTopicPostReply(4,"在条目评论",false),
  subjectTopicCall(24,"在番剧话题",true),

  //这个5号。。真的能被触发吗..
  characterTopicReply(5,"在你的人物收藏",false),
  characterPostReply(6,"在人物收藏",false),
  characterTopicCall(25,"在人物收藏",true),

  //Blog 触发
  blogReply(7,"在你的条目话题",false),
  blogPostReply(8,"在条目话题",false),
  blogPostCall(29,"在日志中",true),
  
  subjectEPPost(9,"在章节的评论",false),
  subjectEPPostReply(10,"在章节回复的评论",false),
  subjectEPPostCall(30,"在章节的评论",true),

  indexCommentPost(11,"在收藏目录",false),
  indexCommentReply(12,"在收藏目录回复的评论",false),

  timelineReply(22,"在时间线",false),
  indexTimelineCall(28,"在其他地方",true),

  requestFriend(14,"发来了好友请求",false),
  acceptFriend(15,"通过了好友请求",false),

  ;

  final int notificationTypeIndex;
  final String notificationTypeName;
  final bool isCall;

  const NotificationType(
    this.notificationTypeIndex,
    this.notificationTypeName,
    this.isCall
  );

}

enum ReportSubjectType{

  none("无法举报",0),
  
  user("用户",6),

  groupTopic("小组话题",7),
  groupReply("小组回复",8),

  subjectTopic("条目话题",9),
  /// 从网站的举报url得知 9对应楼主的举报入口 而10对应的回复的举报入口 并非直接条目回复
  subjectTopicReply("条目话题回复",10),

  episodeReply("章节回复",11),
  characterReply("角色回复",12),
  personReply("人物回复",13),

  blog("日志",14),
  blogReply("日志回复",15),

  timeline("时间线",16),
  timelineReply("时间线回复",17),

  //原本的名字是 index 但是这个名字和 默认定义冲突
  catalog("目录",18),
  catalogReply("目录回复",19);
  


  final String typeName;
  final int typeIndex;

  const ReportSubjectType(this.typeName,this.typeIndex);

}

enum ReportReasonType{

  abuse("辱骂、人身攻击",1),
  spam("刷屏、无关内容",2),
  political("政治相关",3),
  illegal("违法信息",4),
  privacy("泄露隐私",5),
  cheatScore("涉嫌刷分",6),
  flame("引战",7),
  advertisement("广告",8),
  spoiler("剧透",9),
  other("其他",99);

  final String reasonName;
  final int reasonIndex;

  const ReportReasonType(this.reasonName,this.reasonIndex);

}

/// 数据源自于 /lib/topic/status.js
//enum TopicStatus{
//  normal("正常"),
//  logined("仅登录可见"),
//  banned("仅管理员可见"),
//  ;

//  const TopicStatus(String label);
//}