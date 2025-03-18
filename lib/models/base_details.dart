import 'package:bangu_lite/models/ep_details.dart';

abstract class BaseDetails {

  BaseDetails({this.detailID});

  final int? detailID; // 通用ID字段
  
  // 工厂方法，创建空对象
  factory BaseDetails.empty() {
    throw UnimplementedError('BaseInfo.empty() must be implemented by subclasses');
  }
}

/// 作用目标Content: [Topic]/[Blog] 这种单人开题 ...肯定拥有的属性
class ContentDetails extends BaseDetails {
  ContentDetails({
    super.detailID,
    this.contentTitle,
    this.content,
    this.createdTime,
    this.state,
    this.contentReactions,
    this.contentRepliedComment,
  });

  String? contentTitle;
  String? content;
  int? createdTime;
  int? state;
  Map<int,Set<String>>? contentReactions;
  List<EpCommentDetails>? contentRepliedComment;

  factory ContentDetails.empty() => ContentDetails(detailID: 0);

}

