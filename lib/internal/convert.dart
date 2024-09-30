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

String? convertAmpsSymbol(String? originalString){
  if(originalString?.contains("&amp;") ?? false){
   return originalString?.replaceAll("&amp;", "&");
  }

  return originalString;
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

int convertTotalCommentPage(int totalComments, int pageRange){
return  totalComments % pageRange == 0 ?
        totalComments~/pageRange :
        totalComments~/pageRange + 1;
}