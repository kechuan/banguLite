class StarBangumiDetails{
  int? bangumiID;
  String? name;
  String? coverUrl;
  int? eps;
  
  String? airWeekday;
  String? joinDate;
  String? airDate;
  String? finishedDate;

  int? rank;
  double? score;

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

