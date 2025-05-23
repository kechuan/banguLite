// ignore_for_file: constant_identifier_names



const detectIDList = [
  'id',
  'subjectID',
];

const detectNameList = [
  'name',
  'nameCN',
  'title',
  'nickname'
];

//因为Dart 的语言特性 跨行字符串是可被拼接的 
//因此注意 千万不要漏加逗号
const detectPropList = [
  'epsUpdate',
  'sort',
  'comment',
  'rate',
  //吐槽
  'tsukkomi', 
   //个性签名
  'sign',
  'reactions',
  
];

const List<dynamic> timelineEnums = [
  TimelineCatDaily.values,
  TimelineCatWiki.values,
  TimelineCatSubjectSingle.values,
  TimelineCatProgress.values,
  TimelineCatStatus.values,
  //Blog/Index 没有子级目录 对应 6/7 的空置
  [],
  [],
  TimelineCatMono.values,
  TimelineCatDoujin.values,
];

enum TimelineCat {

  Daily(1,"日常行为"),
  Wiki(2,"维基操作"),
  Subject(3,"收藏条目"),
  Progress(4,"收视进度"),
  Status(5,"个人状态"),
  Blog(6,"个人日志"),
  Index(7,"个人目录"),
  Mono(8,"人物"),
  Doujin(9,"天窗");

  final int value;
  final String catName;

  int getValue(TimelineCat timelineCatType) => timelineCatType.value;
  

  const TimelineCat(this.value,this.catName);
}

enum TimelineCatDaily {

  MysteriousAction(0, "神秘的行动"),
  Register(1, "注册Bangumi"),
  AddFriend(2, "添加好友"),
  JoinGroup(3, "加入小组"),
  CreateGroup(4, "创建小组"),
  JoinParadise(5, "加入乐园");

  final int value;
  final String actionName;
  const TimelineCatDaily(this.value, this.actionName);
}

enum TimelineCatWiki {

  AddBook(1, "添加了新书"),
  AddAnime(2, "添加了新动画"),
  AddMusic(3, "添加了新唱片"),
  AddGame(4, "添加了新游戏"),
  AddBookSeries(5, "添加了新图书系列"),
  AddMovie(6, "添加了新影视");

  final int value;
  final String actionName;
  const TimelineCatWiki(this.value, this.actionName);
}

enum TimelineCatSubjectSingle {
  
  WantToRead(1, "想读"),
  WantToWatch(2, "想看"),
  WantToListen(3, "想听"),
  WantToPlay(4, "想玩"),
  Read(5, "读过"),
  Watched(6, "看过"),
  Listened(7, "听过"),
  Played(8, "玩过"),
  Reading(9, "在读"),
  Watching(10, "在看"),
  Listening(11, "在听"),
  Playing(12, "在玩"),
  OnHold(13, "搁置了"),
  Dropped(14, "抛弃了");

  final int value;
  final String actionName;
  const TimelineCatSubjectSingle(this.value, this.actionName);

  
}

enum TimelineCatProgress {

  Completed(0, "完成"),
  WantToWatch(1, "想看"),
  Watched(2, "看过"),
  Dropped(3, "抛弃");

  final int value;
  final String actionName;
  const TimelineCatProgress(this.value, this.actionName);
}

enum TimelineCatStatus {

  UpdateSignature(0, "更新签名"),
  Comment(1, "时间线吐槽"),
  ChangeNickname(2, "修改昵称");

  final int value;
  final String actionName;
  const TimelineCatStatus(this.value, this.actionName);
}

enum TimelineCatMono {

  Created(0, "创建收藏"),
  Collected(1, "增加收藏");

  final int value;
  final String actionName;
  const TimelineCatMono(this.value, this.actionName);
}

enum TimelineCatDoujin {

  AddWork(0, "添加作品"),
  CollectWork(1, "收藏作品"),
  CreateClub(2, "创建社团"),
  FollowClub(3, "关注社团"),
  FollowEvent(4, "关注活动"),
  JoinEvent(5, "参加活动");

  final int value;
  final String actionName;
  const TimelineCatDoujin(this.value, this.actionName);
}

