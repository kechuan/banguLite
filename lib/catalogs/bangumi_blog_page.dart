import 'package:bangu_lite/catalogs/bangumi_general_content_page.dart';
import 'package:bangu_lite/internal/bus_register_method.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/models/blog_details.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/request_client.dart';

import 'package:bangu_lite/widgets/views/ep_comments_view.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/skeleton_tile_template.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
>

{
  

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
  String getWebUrl(int? blogID) => BangumiWebUrls.blog(blogID ?? 0);

  @override
  Future<void> loadContent(int blogID) => getContentModel().loadBlog();

}
