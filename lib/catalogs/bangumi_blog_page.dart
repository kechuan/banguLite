import 'package:bangu_lite/catalogs/bangumi_general_content_page.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/models/blog_details.dart';
import 'package:bangu_lite/internal/request_client.dart';

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';


@FFAutoImport()
import 'package:bangu_lite/models/providers/review_model.dart';
@FFAutoImport()
import 'package:bangu_lite/models/review_details.dart';

@FFRoute(name: '/Blog')
class BangumiBlogPage extends StatefulWidget {
  const BangumiBlogPage({
    super.key,
    required this.reviewModel,
    required this.selectedBlogIndex,
    this.themeColor,
  });

  
  final ReviewModel reviewModel;
  final int selectedBlogIndex;

  final Color? themeColor;

  @override
  State<BangumiBlogPage> createState() => _BangumiBlogPageState();
}


class _BangumiBlogPageState extends BangumiContentPageState
<
	BangumiBlogPage,
	ReviewModel,
	ReviewInfo,
	BlogDetails
>{

  @override
  ReviewModel getContentModel() => widget.reviewModel;

  @override
  ReviewInfo getContentInfo() => widget.reviewModel.contentListData[widget.selectedBlogIndex];

  @override 
  int? getSubContentID() => widget.reviewModel.contentListData[widget.selectedBlogIndex].blogID;

  @override
  String? getContentBannerUri() => widget.reviewModel.contentDetailData[widget.selectedBlogIndex]?.bannerUri;

  @override
  BlogDetails createEmptyDetailData() => BlogDetails.empty();

  @override
  Color? getcurrentSubjectThemeColor() => widget.themeColor;



  @override
  bool isContentLoading(int? blogID){
	return 
		getContentModel().contentDetailData[blogID] == null || //没别的意思 只是消除 nullable
		getContentModel().contentDetailData[blogID]?.blogID == null ||
		getContentModel().contentDetailData[blogID]?.blogReplies == null
	;
  }

  @override
  int? getCommentCount(BlogDetails? blogDetails, bool isLoading){

	if(isLoading) return null;
	  return blogDetails!.blogReplies!.isEmpty ? 0 : blogDetails.blogReplies!.length;
  }
	
  @override
  PostCommentType? getPostCommentType() => PostCommentType.replyBlog;
  
  @override
  //String getWebUrl(int? blogID) => BangumiWebUrls.userBlog(widget.selectedBlogID ?? blogID ?? 0);
  String getWebUrl(int? blogID)=> BangumiWebUrls.userBlog(blogID ?? 0);

  @override
  Future<void> loadContent(int blogID) => getContentModel().loadBlog(blogID);

}
