
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

String convertDigitNumString(int originalNumber, {int numberBits = 2}){

  String fillingContent = '';

  if(originalNumber >= 10*(numberBits-1)){
    return '$originalNumber';
  }

  else{
    for(numberBits; numberBits>1; numberBits--){
      fillingContent+='0';
    }

    return '$fillingContent$originalNumber';
  }

}

String convertBangumiCommentSticker(String originalComment){
  RegExp stickerMatch = RegExp(r'(\()+bgm+(\d{2,3})(\))');
  
  String mappedComment = originalComment.replaceAllMapped(
    stickerMatch, 
    (match){

      String resultText = "";
      String replaceTag = "sticker";

      List<String?> resultList = [];
      

      for(String? currentPattern in match.groups([1,2,3])){
        switch(currentPattern){
          case '(': resultList.add("[$replaceTag]"); break;
          case ')': resultList.add("[/$replaceTag]"); break;
          default: resultList.add("assets/bangumiSticker/bgm${match.group(2)}.gif");
        }
      }


      resultText = resultList.join();

      

      return resultText;

      
    }
  );

  //debugPrint("convert :$mappedComment");

  return mappedComment;

									
}

int convertSegement(int totalEps, int segementRange) => convertTotalCommentPage(totalEps,segementRange);
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
	int airedEps =  (residualDateTime ~/ const Duration(days: 7).inMilliseconds) + 1;

	return airedEps;
}
