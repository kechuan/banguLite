// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';


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

enum SortType{
  rank("rank"),
  heat("heat"),
  score("score");

  final String sortType;

  const SortType(this.sortType);
}

enum ScaleType{

  min(0.85),
  less(0.9),
  medium(1.0),
  more(1.1),
  max(1.15);

  final double fontScale;

  const ScaleType(this.fontScale);
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
  worst("不忍直视",1.5), // 1.5-
  worse("很差",1.5), // 1.5~3
  poor("差",3), //3 ~ 3.5
  bad("较差",3.5), //3.5~4.5
  medium("不过不失",4.5), //4.5~5.5
  pass("还行",5.5), //5.5~6.5
  great("推荐",6.5), //6.5~7.5
  excellent("力荐",7.5), //7.5 ~ 9
  perfect("神作",9) //9+
  ;

  final String rankText;
  final double score;

  const ScoreRank(this.rankText,this.score);

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



const PaddingH6 = EdgeInsetsDirectional.symmetric(horizontal: 6);
const PaddingH12 = EdgeInsetsDirectional.symmetric(horizontal: 12);

const PaddingV6 = EdgeInsetsDirectional.symmetric(vertical: 6);
const PaddingV12 = EdgeInsetsDirectional.symmetric(vertical: 12);

const PaddingH6V12 = EdgeInsetsDirectional.symmetric(horizontal: 6,vertical: 12);
const PaddingH12V6 = EdgeInsetsDirectional.symmetric(horizontal: 12,vertical: 6);

const Padding6 = EdgeInsetsDirectional.all(6);
const Padding12 = EdgeInsetsDirectional.all(12);
const Padding16 = EdgeInsetsDirectional.all(16);

