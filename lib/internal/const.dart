// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

enum WeekDay{

  mon("一",1),
  tues("二",2),
  weds("三",3),
  thur("四",4),
  fri("五",5),
  sat("六",6),
  sun("日",7);

  final String dayText;
  final int dayIndex;
  
  const WeekDay(this.dayText,this.dayIndex);
}

enum StorageSize{
  bytes("B"),
  kilobytes("KB"),
  megabytes("MB"),
  gigabytes("GB");

  final String suffix;

  const StorageSize(this.suffix);
}

enum ViewType{
  listView(),
  gridView();

  const ViewType();

}

enum AbiType{
  arm64("安卓64位"),
  armeabi("安卓32位"),
  windows("windows");

  final String abiName;

  const AbiType(this.abiName);
  
}

enum ScaleType{

  min(0.85,"小"),
  less(0.9,"偏小"),
  medium(1.0,"中"),
  more(1.1,"偏大"),
  max(1.15,"大");

  final double fontScale;
  final String sacleName;

  const ScaleType(this.fontScale,this.sacleName);
}

enum BBCodeTag{
	b('加粗'),
	i('斜体'),
	u('下划线'),
	s('删除线'),
	quote('引用'),
	mask('遮罩'),
	code('代码'),
  
	;

	final String tagName;
	

	const BBCodeTag(this.tagName);
}

enum SeasonType{

  winter("冬",1),
  spring("春",4),
  summer("夏",7),
  autumn("秋",10);
  

  final String seasonText;
  final int month;

  const SeasonType(this.seasonText,this.month);
}

enum BangumiThemeColor{
  ice(Color.fromARGB(255, 219, 251, 255)),
  macha(Color.fromARGB(255, 219, 245, 223)),
  sea(Color.fromARGB(255, 140, 205, 244)), //Primary: const Color.fromARGB(255, 140, 205, 244)
  ruby(Color.fromARGB(255, 255, 217, 217)),
  ;

  final Color color;
  const BangumiThemeColor(this.color);

}


//bangumi Type

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
  rank("rank","番剧排名"),
  heat("heat","番剧热度"),
  score("score","番剧评分"),
  joinTime("joinTime","收藏时间"),
  updateTime("updateTime","更新日期"),
  airDate("airDate","放送日期")
  
  ;

  final String searchSortType;
  final String label;

  const SortType(
    this.searchSortType,
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
  deprecated("抛弃")
  ;

  final String starTypeString;
  

  const StarType(this.starTypeString);

}

enum UserRelationsActionType{
    add("发送好友请求"),
    remove("删除好友"),
    block("拉黑该用户"),
    removeBlock("解除拉黑该用户"),
  ;

  final String relationTypeString;
  

  const UserRelationsActionType(this.relationTypeString);
}

const PaddingH6 = EdgeInsetsDirectional.symmetric(horizontal: 6);
const PaddingH12 = EdgeInsetsDirectional.symmetric(horizontal: 12);
const PaddingH16 = EdgeInsetsDirectional.symmetric(horizontal: 16);
const PaddingH24 = EdgeInsetsDirectional.symmetric(horizontal: 24);

const PaddingV6 = EdgeInsetsDirectional.symmetric(vertical: 6);
const PaddingV12 = EdgeInsetsDirectional.symmetric(vertical: 12);
const PaddingV16 = EdgeInsetsDirectional.symmetric(vertical: 16);
const PaddingV24 = EdgeInsetsDirectional.symmetric(vertical: 24);

const PaddingH6V16 = EdgeInsetsDirectional.symmetric(horizontal: 6,vertical: 16);
const PaddingH6V12 = EdgeInsetsDirectional.symmetric(horizontal: 6,vertical: 12);
const PaddingH12V6 = EdgeInsetsDirectional.symmetric(horizontal: 12,vertical: 6);
const PaddingH12V16 = EdgeInsetsDirectional.symmetric(horizontal: 12,vertical: 16);
const PaddingH16V12 = EdgeInsetsDirectional.symmetric(horizontal: 16,vertical: 12);
const PaddingH16V6 = EdgeInsetsDirectional.symmetric(horizontal: 16,vertical: 6);

const Padding6 = EdgeInsetsDirectional.all(6);
const Padding12 = EdgeInsetsDirectional.all(12);
const Padding16 = EdgeInsetsDirectional.all(16);
const Padding24 = EdgeInsetsDirectional.all(24);

