enum PostCommentType{
  //subject,Ep不可能由用户发起 只拥有 reply 权限
  subjectComment("番剧吐槽"),
  replyEpComment("单集吐槽"),
  
  postTopic("发布帖子"),
  replyTopic("回复帖子"),

  postBlog("发布博客"),
  replyBlog("回复博客"),

  postGroupTopic("发布小组帖子"),
  replyGroupTopic("回复小组帖子"),

  //特殊
  timeline("时间线"),
  replyTimeline("回复时间线"),
  ;

  final String commentTypeString;
  

  const PostCommentType(this.commentTypeString);


}

enum CommentActionType{
  //登录可操作
  reply("回复"),
  sticker("贴条"),
  report("检举"),
  //自身评论可操作
  delete("删除"),
  edit("编辑"),
  ;

  final String actionTypeString;
  

  const CommentActionType(this.actionTypeString);
}

enum UserContentActionType{
  post("发表"),
  delete("删除"),
  edit("编辑"),
  ;

  final String actionTypeString;

  const UserContentActionType(this.actionTypeString);
}

enum UserRelationsActionType{
    add("发送好友请求"),
    remove("删除好友"),
    block("拉黑该用户"),
    removeBlock("解除拉黑该用户"),
  ;

  final String relationTypeString;
  

  const UserRelationsActionType(this.relationTypeString);
}
