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

bool judgeInSeasonBangumi(String? bangumiAirDate){

  if(bangumiAirDate == null) return false;

  List<String> dateSegments = bangumiAirDate.split("-");

  int bangumiYear = int.parse(dateSegments[0]);
  int bangumiMonth = int.parse(dateSegments[1]);

  if((bangumiYear - DateTime.now().year).abs() <= 1){
    if(
        (DateTime.now().month - bangumiMonth).abs() <= 2 || 
        (DateTime.now().month - bangumiMonth).abs() >= 10
    ) return true;
  }

  return false;

}

int convertAiredEps(String? bangumiAirDate){
	if(bangumiAirDate == null) return 0;

	List<String> dateSegments = bangumiAirDate.split("-");

	int bangumiYear = int.parse(dateSegments[0]);
	int bangumiMonth = int.parse(dateSegments[1]);
	int bangumiDay = int.parse(dateSegments[2]);

	int residualDateTime = (DateTime.now().millisecondsSinceEpoch - DateTime(bangumiYear,bangumiMonth,bangumiDay).millisecondsSinceEpoch);

	//放送开始附带一集 因此+1
	int airedEps =  residualDateTime ~/ const Duration(days: 7).inMilliseconds;

	return airedEps;
}
