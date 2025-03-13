import 'dart:async';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/blog_details.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/models/review_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

/// 对于番剧来说 是Review
/// 而对于 用户个人来说 则是Blog
class ReviewModel extends BaseModel<ReviewInfo, BlogDetails>{

  ReviewModel({
    required super.subjectID
  }){
    loadSubjectReviews();
  }

  Future<void> loadSubjectReviews({int? offset = 0}) async {
    await loadSubjectSubContentList(
      queryParameters: BangumiQuerys.reviewsQuery
        ..["offset"] = offset ?? 0
    );
  }

  Future<void> loadBlog(int blogID) async {

	Completer blogFullContentCompleter = Completer();

	//Future<Response> commentFuture = loadBlogComment(blogID);

	await Future.wait(
		[
			loadContentDetail(blogID),
			loadBlogComment(blogID)
		]
	).then((responseList){
		final commentResponse =  responseList[1] as Response;

		if (commentResponse.data != null) {
			contentDetailData[blogID]?.blogReplies = loadEpCommentDetails(commentResponse.data);
			debugPrint("blog: $blogID load blogComment done");
			blogFullContentCompleter.complete();
			notifyListeners();
		}
		
	});



	////因为 一个 loadContentDetail 是void 另一个只能是 loadBlogComment
	////因此甚至无法直接使用Future.wait..
	//await loadContentDetail(blogID).then((_) async {
	//	debugPrint("blog: $blogID load blog done, $blogID:${contentDetailData[blogID]}");
	//	await loadBlogComment(blogID).then((response){
	//		if (response.data != null) {
	//			contentDetailData[blogID]?.blogReplies = loadEpCommentDetails(response.data);
	//			debugPrint("blog: $blogID load blogComment done");
	//			notifyListeners();
	//		}
	//	});
	//});


	return blogFullContentCompleter.future;

	

  }

  Future<Response> loadBlogComment(int blogID) async {
	if(blogID == 0) return Response(requestOptions: RequestOptions());

	return await HttpApiClient.client.get(
		BangumiAPIUrls.blogComment(blogID),
	);
  }

  @override
  List<ReviewInfo> createEmptyInfoList() => [ReviewInfo.empty()];
  @override
  BlogDetails createEmptyDetails() => BlogDetails.empty();
  @override
  String getContentListUrl(int subjectID) => BangumiAPIUrls.reviews(subjectID);
  @override
  String getContentDetailUrl(int contentID) => BangumiAPIUrls.blog(contentID);
  @override
  List<ReviewInfo> convertResponseToList(Response subContentListResponseData) => loadReviewsDetails(subContentListResponseData);
  @override
  BlogDetails convertResponseToDetail(Map<String,dynamic> contentResponseData) => loadBlogDetails(contentResponseData);


}