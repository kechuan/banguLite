import 'dart:async';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/blog_details.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/models/informations/subjects/review_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

/// 对于番剧来说 是Review
/// 而对于 用户个人来说 则是Blog
class ReviewModel extends BaseModel<ReviewInfo, BlogDetails>{

  ReviewModel({
    required super.subjectID
  }){
    if(subjectID == "blog") return;
    loadSubjectReviews();
  }

  Future<void> loadSubjectReviews({int? offset = 0}) async {
    await loadSubjectSubContentList(
      queryParameters: BangumiQuerys.reviewsQuery
        ..["offset"] = offset ?? 0
    );
  }

  Future<void> loadBlog(
    int selectedBlogID,
    {
      bool isRefresh = false,
      Function(String)? fallbackAction
    }
  ) async {

    if(selectedBlogID == 0 || selectedBlogID == -1) return;

    Completer blogFullContentCompleter = Completer();

    await Future.wait(
      [
        loadContentDetail(selectedBlogID,isRefresh: isRefresh,fallbackAction: fallbackAction),
        loadBlogComment(selectedBlogID),
        loadBlogPhotos(selectedBlogID),
      ]
    ).then((responseList){
      final commentResponse = responseList[1] as Response;
      final photoResponse = responseList[2] as Response;

      if (commentResponse.data != null && photoResponse.data != null) {
        debugPrint("blog: $selectedBlogID load blogComment done");
        contentDetailData[selectedBlogID]?.blogReplies = loadEpCommentDetails(commentResponse.data);
        contentDetailData[selectedBlogID]?.trailingPhotosUri = loadBlogPhotoDetails(photoResponse.data);
        
        blogFullContentCompleter.complete();
        notifyListeners();
      }
      
    });

    return blogFullContentCompleter.future;

  }

  Future<Response> loadBlogComment(int blogID) async {
    if(blogID == 0) return Response(requestOptions: RequestOptions());

    return await HttpApiClient.client.get(
      BangumiAPIUrls.blogComment(blogID),
      options: BangumiAPIUrls.bangumiAccessOption()
    );
  }

  Future<Response> loadBlogPhotos(int blogID) async {
    if(blogID == 0) return Response(requestOptions: RequestOptions());

    return await HttpApiClient.client.get(
      BangumiAPIUrls.blogPhotos(blogID),
      options: BangumiAPIUrls.bangumiAccessOption()
    );
  }


  @override
  List<ReviewInfo> createEmptyInfoList() => [ReviewInfo.empty()];
  @override
  BlogDetails createEmptyDetails() => BlogDetails.empty();
  @override
  String getContentListUrl(dynamic subjectID) => BangumiAPIUrls.reviews(subjectID);
  @override
  //String getContentDetailUrl(int contentID) => BangumiAPIUrls.userBlog(selectedBlogID);
  String getContentDetailUrl(int contentID) => BangumiAPIUrls.userBlog(contentID);
  @override
  List<ReviewInfo> convertResponseToList(Response subContentListResponseData) => loadReviewsDetails(subContentListResponseData);
  @override
  BlogDetails convertResponseToDetail(Map<String,dynamic> contentResponseData) => loadBlogDetails(contentResponseData);


}