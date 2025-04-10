// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

const stickerDataLike = [0,79,54,140,62,122,104,80,141,88,85,90];

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

enum AppThemeColor{
  ice(Color.fromARGB(255, 219, 251, 255)),
  macha(Color.fromARGB(255, 219, 245, 223)),
  sea(Color.fromARGB(255, 140, 205, 244)), //Primary: const Color.fromARGB(255, 140, 205, 244)
  ruby(Color.fromARGB(255, 255, 217, 217)),
  ;

  final Color color;
  const AppThemeColor(this.color);

}

//bangumi Type

enum UserContentActionType{
  post("发表"),
  delete("删除"),
  edit("编辑"),
  ;

  final String actionTypeString;

  const UserContentActionType(this.actionTypeString);
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

