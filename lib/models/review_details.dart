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

  for(Map subejctReviewsMap in bangumiRelationsDataList){
    ReviewInfo currentReviewDetail = ReviewInfo();

		currentReviewDetail
      
      ..reviewID = subejctReviewsMap["id"]
      ..userInformation = loadUserDetails(subejctReviewsMap["user"])

      ..blogID = subejctReviewsMap["entry"]["id"]
      ..title = subejctReviewsMap["entry"]["title"]
      ..summary = subejctReviewsMap["entry"]["summary"]
      ..repliedCount = subejctReviewsMap["entry"]["replies"]
      ..reviewTimeStamp = subejctReviewsMap["entry"]["updatedAt"]

    ;

		subejctReviewsList.add(currentReviewDetail);
	} 

	 return subejctReviewsList;
}