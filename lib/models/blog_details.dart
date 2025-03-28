import 'package:bangu_lite/models/base_details.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/models/user_details.dart';

// 严格意义来说 整个 Blog数据源 唯一有用的数据 只有。。content
// 因为实际上大部分数据 都依靠 review 提供
// 剩下的数据源还要依靠 blog/comments
class BlogDetails extends ContentDetails{

  BlogDetails({
    super.detailID,
    super.contentRepliedComment,
    super.content
  });

  int? get blogID => detailID;
  String? get blogContent => content;
  
  UserInformation? userInfo;

  List<EpCommentDetails>? get blogReplies => contentRepliedComment;
  set blogReplies(List<EpCommentDetails>? value) => contentRepliedComment = value;


  factory BlogDetails.empty() => BlogDetails(detailID: 0);
}

BlogDetails loadBlogDetails(Map<String,dynamic> blogData){

  final currentBlog = BlogDetails(
    detailID: blogData["id"],
    content: blogData["content"]
  );

  return currentBlog;
}