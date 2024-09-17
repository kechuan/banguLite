enum WeekDay{

  sun("日"),
  mon("一"),
  tues("二"),
  weds("三"),
  thur("四"),
  fri("五"),
  sat("六");

  final String dayText;
  
  const WeekDay(this.dayText);
}


enum SortType{
  date("日期"),
  rank("排名"),
  grid("窗格");

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


String convertDigitNumString(int originalnumber, {int? numberBits}){

  String fillingContent = '0';

  if(numberBits!=null){
    for(int addTimes = numberBits; addTimes>0; addTimes--){
      fillingContent+='0';
    }

    if(originalnumber < 10*numberBits){
      return '$fillingContent$originalnumber';
    }

  }

  else{
    if(originalnumber < 10){
      return '$fillingContent$originalnumber';
    }
  }

  return originalnumber.toString();
}