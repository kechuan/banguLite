import 'package:bangu_lite/models/base_info.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:dio/dio.dart';

class ReviewInfo extends BaseInfo {

  ReviewInfo();
  
  int? reviewID;
  //user字段
  UserDetails? userInformation;

  //entry字段
  int? blogID;
  String? title;
  String? summary;
  int? repliedCount;
  int? reviewTimeStamp;

  factory ReviewInfo.empty() => ReviewInfo()..reviewID = 0;

}

List<ReviewInfo> loadReviewsDetails(Response bangumiReviewsResponse){
  final List<ReviewInfo> subejctReviewsList = [];

  List<dynamic> bangumiRelationsDataList = bangumiReviewsResponse.data["data"];

  for(Map subejctRelationsMap in bangumiRelationsDataList){
    ReviewInfo currentReviewDetail = ReviewInfo();

		currentReviewDetail
      
      ..reviewID = subejctRelationsMap["id"]
      ..userInformation = loadUserDetails(subejctRelationsMap["user"])

      ..blogID = subejctRelationsMap["entry"]["id"]
      ..title = subejctRelationsMap["entry"]["title"]
      ..summary = subejctRelationsMap["entry"]["summary"]
      ..repliedCount = subejctRelationsMap["entry"]["repies"]
      ..reviewTimeStamp = subejctRelationsMap["entry"]["updatedAt"]

    ;

		subejctReviewsList.add(currentReviewDetail);
	} 

	 return subejctReviewsList;
}