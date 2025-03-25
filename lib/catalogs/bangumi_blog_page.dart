import 'package:bangu_lite/catalogs/bangumi_general_content_page.dart';
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
	required this.reviewInfo
  });

  
  final ReviewModel reviewModel;
  final ReviewInfo reviewInfo;

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
  ReviewInfo getContentInfo() => widget.reviewInfo;

  @override
  ReviewModel getContentModel() => widget.reviewModel;

  @override 
  int? getSubContentID() => getContentModel().selectedBlogID;

  @override
  BlogDetails createEmptyDetailData() => BlogDetails.empty();

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
  String getWebUrl(int? blogID) => BangumiWebUrls.userBlog(blogID ?? 0);

  @override
  Future<void> loadContent(int blogID) => getContentModel().loadBlog();

}
