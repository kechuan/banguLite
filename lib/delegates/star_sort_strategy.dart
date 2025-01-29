// 定义排序策略抽象类
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/models/star_details.dart';

abstract class SortStrategy {
  int getSort(StarBangumiDetails details);
  String generateHeaderText(int counter);
  SortType currentSort = SortType.airDate;
}

// 播出时间排序策略
class AirDateSortStrategy implements SortStrategy {
  @override
  int getSort(StarBangumiDetails details) => 
      convertDateTime(details.airDate).millisecondsSinceEpoch;

  @override
  String generateHeaderText(int airms) {

	final DateTime convertTime = DateTime.fromMillisecondsSinceEpoch(airms);

    final season = judgeSeasonRange(convertTime.month);
    return '${convertTime.year}年 ${season.seasonText}';
  }

  @override
  SortType currentSort = SortType.airDate;
}

// 更新时间排序策略
class UpdateTimeSortStrategy implements SortStrategy {
  @override
  int getSort(StarBangumiDetails details){

    int resultWeekDate = 0;

	DateTime finishedTime = convertDateTime(details.finishedDate);

	//已完结
	if(DateTime.now().compareTo(finishedTime) > 0) return resultWeekDate;

    WeekDay.values.any((currentDay){

      if(currentDay.dayText == details.airWeekday?.substring(2,3)){
		resultWeekDate = currentDay.dayIndex; //覆盖才有用 太奇怪了
        return true;
      }

      return false;
     
    });

    return resultWeekDate;

  }

  @override
  String generateHeaderText(int weekday) {
    
    String resultText = "";

    WeekDay.values.any((currentDay){

      if(currentDay.dayIndex == weekday){
        resultText = currentDay.dayText;
        return true;
      }

      return false;
     
    });

    return resultText.isEmpty? '已完结' : '星期$resultText';
  }

 @override
  SortType currentSort = SortType.updateTime;
}

// 收藏时间排序策略
class JoinTimeSortStrategy implements SortStrategy {
	@override
	int getSort(StarBangumiDetails details) => 
		convertDateTime(details.joinDate).millisecondsSinceEpoch;

	@override
	String generateHeaderText(int joinms) {

		final DateTime convertTime = DateTime.fromMillisecondsSinceEpoch(joinms);

		final season = judgeSeasonRange(convertTime.month);
		return '${convertTime.year}年 ${season.seasonText}';
	}

  @override
  SortType currentSort = SortType.joinTime;
}

//评分信息排序 
class ScoreSortStrategy implements SortStrategy {
  @override
  int getSort(StarBangumiDetails details){
    return (details.score!*10).toInt(); //*10化整
  }

  @override
  String generateHeaderText(int intScore) {
	double resultScore = intScore/10;
	String resultRankText = convertScoreRank(resultScore);

	ScoreRank.values.any((currentRank){
		if(currentRank.rankText == resultRankText){
			resultScore = currentRank.score;
			return true;
		}
		
		return false;
	});

	

    return "$resultRankText $resultScore +";
  }

  @override
  SortType currentSort = SortType.score;
}

//排名信息排序 
class RankSortStrategy implements SortStrategy {
  @override
  int getSort(StarBangumiDetails details) => details.rank!;

  @override
  String generateHeaderText(int rank){
	if(rank <= 500) return "Rank 500 -";
	return "Rank ${rank~/500*500} +";
  }

  @override
  SortType currentSort = SortType.rank;
}
