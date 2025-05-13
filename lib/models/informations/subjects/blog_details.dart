import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';

// 严格意义来说 整个 Blog数据源 唯一有用的数据 只有。。content
// 因为实际上大部分数据 都依靠 review 提供
// 剩下的数据源还要依靠 blog/comments

// 哈哈 因为跳转带来的信息缺失关系 这下 BlogDetails 也有用了
class BlogDetails extends ContentDetails{

  BlogDetails({
    super.detailID,
    super.contentRepliedComment,
    super.content
  });

  int? get blogID => detailID;
  String? get blogContent => content;

  
  //UserInformation? userInformation;

  //尾部图片
  List<String> trailingPhotosUri = [];

  List<EpCommentDetails>? get blogReplies => contentRepliedComment;
  set blogReplies(List<EpCommentDetails>? value) => contentRepliedComment = value;


  factory BlogDetails.empty() => BlogDetails(detailID: 0);


}

BlogDetails loadBlogDetails(Map<String,dynamic> blogData){

  final currentBlog = BlogDetails(
    detailID: blogData["id"],
    content: blogData["content"],
  )
    ..contentTitle = blogData["title"]
    ..userInformation = loadUserInformations(blogData["user"])
    ..createdTime = blogData["createdAt"]
  ;

  return currentBlog;
}

List<String> loadBlogPhotoDetails(Map<String,dynamic> blogPhotoData){

  final List<String> photoUrlsList = [];

  for(dynamic currentPhoto in blogPhotoData["data"]){
    photoUrlsList.add(BangumiAPIUrls.imgurl(currentPhoto["target"]));
  }

  return photoUrlsList;
}