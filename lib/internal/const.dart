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

enum SortType{
  rank("rank"),
  heat("heat"),
  score("score");

  final String sortType;

  const SortType(this.sortType);
}

enum Season{

  spring("春",4),
  summer("夏",7),
  autumn("秋",10),
  winter("冬",1);

  final String seasonText;
  final int month;

  const Season(this.seasonText,this.month);
}

enum ScoreRank{
  none("未评分",0),
  worst("不忍直视",1.5), // 1.5-
  worse("很差",3), // 1.5~3
  poor("差",3.5), //3 ~ 3.5
  bad("较差",4.5), //3.5~4.5
  medium("不过不失",5.5), //4.5~5.5
  pass("还行",6), //5.5~6
  great("推荐",7.5), //6~7.5
  excellent("力荐",9), //7.5 ~ 9
  perfect("神作",10) //9+
  ;

  final String rankText;
  final double score;

  const ScoreRank(this.rankText,this.score);

}

enum BangumiThemeColor{
  sea(Color.fromARGB(255, 217, 231, 255)), //Primary: const Color.fromARGB(255, 140, 205, 244)
  macha(Color.fromARGB(255, 219, 245, 223)),
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

