import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
import 'package:dio/dio.dart';

class ReviewInfo extends ContentInfo {

  ReviewInfo({
    super.id,
    super.contentTitle
  });

  int? get reviewID => id;
  set reviewID(int? value) => id = value;

  String? get reviewTitle => contentTitle;
  set reviewTitle(String? value) => contentTitle = value;
  
  //独有字段
  String? summary;
  int? blogID;


  factory ReviewInfo.empty() => ReviewInfo()..reviewID = 0;

}

List<ReviewInfo> loadReviewsDetails(Response bangumiReviewsResponse){
  final List<ReviewInfo> subejctReviewsList = [];

  List<dynamic> bangumiRelationsDataList = bangumiReviewsResponse.data["data"];

  for(Map subejctReviewsMap in bangumiRelationsDataList){
    ReviewInfo currentReviewDetail = ReviewInfo();

		currentReviewDetail
      
      ..reviewID = subejctReviewsMap["id"]
      ..userInformation = loadUserInformations(subejctReviewsMap["user"])

      ..blogID = subejctReviewsMap["entry"]["id"]
      ..reviewTitle = subejctReviewsMap["entry"]["title"]
      ..summary = subejctReviewsMap["entry"]["summary"]
      ..repliesCount = subejctReviewsMap["entry"]["replies"]
      ..createdTime = subejctReviewsMap["entry"]["updatedAt"]

    ;

		subejctReviewsList.add(currentReviewDetail);
	} 

	 return subejctReviewsList;
}