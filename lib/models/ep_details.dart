import 'package:dio/dio.dart';

//class EpInformation {
//  int? id;
//  String? name;
//  String? desc;
//  int? epIndex;
//  int? commentCounts;

//}

class EpCommentDetails{
    int? userId;
    int? epCommentIndex;

    String? nickName; //
    String? avatarUri;
    String? sign;
    String? comment;
    List<EpCommentDetails>? repliedComment;
    //String? repliedComment;

    int? commentTimeStamp;
    int? rate;

}


EpCommentDetails loadEpsData(Response bangumiEpDetailResponse){

  //Map<String,dynamic> bangumiEpData = bangumiEpDetailResponse.data;

	final EpCommentDetails bangumiEpDetails = EpCommentDetails();

  //bangumiEpDetails.coverUri = bangumiEpData["images"]["large"];
  //bangumiEpDetails.summary = bangumiEpData["summary"];
  //bangumiEpDetails.name = bangumiEpData["name_cn"].isNotEmpty ? bangumiEpData["name_cn"] : bangumiEpData["name"];
  //bangumiEpDetails.id = bangumiEpData["id"];

  ////  debugPrint("rating:${bangumiEpData["rating"]["total"]}");

  //bangumiEpDetails.ratingList = {
  //  "total": bangumiEpData["rating"]["total"] ?? 0,
  //  "score": bangumiEpData["rating"]["score"] ?? 0,
  //  "rank": bangumiEpData["rating"]["rank"] ?? 0, //返回的是一个数值0
  //};

  return bangumiEpDetails;


}