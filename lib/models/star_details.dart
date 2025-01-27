import 'package:hive_ce/hive.dart';

class StarBangumiDetails extends HiveObject{
  String? name;
  String? coverUrl;
  int? eps;
  int? bangumiID;
  int? rank;
  double? score;
  String? airWeekday;
  String? joinDate;
  String? airDate;
  String? finishedDate;

}

Map<String,dynamic> starConfigtoMap(StarBangumiDetails starDetails){
  return {
    "name": starDetails.name,
    "coverUrl": starDetails.coverUrl,
    "eps": starDetails.eps,
    "bangumiID":starDetails.bangumiID,
    "score": starDetails.score,
    "airDate": starDetails.airDate,
    "airWeekday": starDetails.airWeekday,
    "joinTime": starDetails.joinDate,
    "rank":starDetails.rank
  };
}