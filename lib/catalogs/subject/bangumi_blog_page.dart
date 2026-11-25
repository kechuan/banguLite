import 'package:bangu_lite/catalogs/subject/bangumi_general_content_page.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/models/informations/subjects/blog_details.dart';
@FFAutoImport()
import 'package:bangu_lite/models/informations/subjects/review_details.dart';
@FFAutoImport()
import 'package:bangu_lite/models/providers/review_model.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';

@FFRoute(name: '/Blog')
class BangumiBlogPage extends StatelessWidget {
  const BangumiBlogPage({
    super.key,
    required this.reviewModel,
    required this.reviewInfo,

    this.themeColor,
    this.referPostContentID,
    this.sourceTitle,
  });

  final ReviewModel reviewModel;
  final ReviewInfo reviewInfo;

  final Color? themeColor;
  final int? referPostContentID;
  final String? sourceTitle;

  int? get targetBlogID => reviewInfo.blogID ?? reviewInfo.id;

  @override
  Widget build(BuildContext context) {

    return BangumiGeneralContentView<ReviewModel, ReviewInfo, BlogDetails>(
      contentModel: reviewModel,
      contentInfo: reviewInfo,
      subContentID: targetBlogID,
      createEmptyDetailData: BlogDetails.empty,
      getWebUrl: (blogID) => BangumiWebUrls.userBlog(blogID ?? 0),
      postCommentType: PostCommentType.replyBlog,

      themeColor: themeColor,
      sourceTitle: sourceTitle,
      referPostContentID: referPostContentID,

      isContentLoading: (model, blogID) =>
        model.contentDetailData[blogID]?.blogID == null ||
        model.contentDetailData[blogID]?.blogReplies == null,

      getCommentCount: (blogDetails, isLoading) {
        if (isLoading) return null;

        return blogDetails?.blogReplies?.length ?? 0;
      },

      getTrailingPhotosUri: (model) =>
        model.contentDetailData[targetBlogID]?.trailingPhotosUri,

      loadContent: (blogID, {bool isRefresh = false}) {
        return reviewModel.loadBlog(
          blogID,
          isRefresh: isRefresh,
          fallbackAction: (message) => showRequestSnackBar(
            message: message,
            requestStatus: false,
            backgroundColor: getCurrentThemeColor(context),
          ),
        );
      },
    );

  }
}
