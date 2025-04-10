
import 'package:flutter/material.dart';

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

enum StarType{
  want("想看"),
  watched("看过"),
  watching("在看"),
  delay("搁置"),
  deprecated("抛弃"),

  none("未收藏")
  ;

  final String starTypeName;
  

  const StarType(this.starTypeName);

}


