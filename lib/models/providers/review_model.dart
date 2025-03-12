import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/blog_details.dart';
import 'package:bangu_lite/models/providers/base_model.dart';
import 'package:bangu_lite/models/review_details.dart';
import 'package:dio/dio.dart';

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
    await Future.wait(
      [
        loadContentDetail(blogID),
        loadBlogComment(blogID)
      ]
    );
  }

  Future<void> loadBlogComment(int blogID) async {
      
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