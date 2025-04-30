import 'package:bangu_lite/catalogs/subject/bangumi_general_content_page.dart';
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
    required this.reviewInfo,
    
    this.themeColor,
  });

  
  final ReviewModel reviewModel;
  final ReviewInfo reviewInfo;
  

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
  ReviewInfo getContentInfo() => widget.reviewInfo;

  @override 
  int? getSubContentID() => getContentInfo().blogID;

  //日志所关联的图片
  @override
  List<String>? getTrailingPhotosUri() => widget.reviewModel.contentDetailData[getSubContentID()]?.trailingPhotosUri;

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
  String getWebUrl(int? blogID)=> BangumiWebUrls.userBlog(blogID ?? 0);

  @override
  Future<void> loadContent(int blogID) => getContentModel().loadBlog(blogID);

}
