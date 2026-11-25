import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/models/informations/subjects/bangumi_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/informations/surf/surf_timeline_details.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';

/// 集中管理浏览历史写入 Hive 的逻辑，避免 UI 页面直接操作存储细节。
class HistoryRecorder {
  const HistoryRecorder._();

  static void recordSubjectVisit({
    required int subjectID,
    required BangumiDetails details,
  }) {
    if (subjectID == 0) return;

    MyHive.historySurfDataBase.put(
      subjectID,
      SurfTimelineDetails(detailID: subjectID)
        ..updatedAt = DateTime.now().millisecondsSinceEpoch
        ..title = details.name ?? ""
        ..bangumiSurfTimelineType = BangumiSurfTimelineType.subject
        ..commentDetails = (CommentDetails()
          ..userInformation = (UserInformation()..avatarUrl = details.coverUrl)),
    );
  }

  static void recordContentVisit({
    required ContentInfo contentInfo,
    required ContentDetails? contentDetail,
    required PostCommentType? postCommentType,
    int? subContentID,
    String? sourceTitle,
    Object? modelSubjectID,
  }) {
    if (contentDetail == null || contentDetail.detailID == 0) return;

    final int accessID = subContentID ?? contentInfo.id ?? 0;

    if (accessID == 0) return;

    String? displaySourceTitle = sourceTitle;

    if (postCommentType == PostCommentType.replyBlog) {
      if (sourceTitle != null) {
        displaySourceTitle = sourceTitle.contains('[日志]') ? sourceTitle : '[日志] $sourceTitle';
      }

      else {
        displaySourceTitle = '[日志]';
      }
    }

    switch (postCommentType) {
      case PostCommentType.replyTopic:
      case PostCommentType.replyBlog:
        saveContentHistory(
          accessID: accessID,
          contentInfo: contentInfo,
          contentDetail: contentDetail,
          postCommentType: postCommentType,
          sourceTitle: displaySourceTitle,
        );

      case PostCommentType.replyGroupTopic:
        saveContentHistory(
          accessID: accessID,
          contentInfo: contentInfo,
          contentDetail: contentDetail,
          postCommentType: postCommentType,
          sourceTitle: displaySourceTitle,
          sourceID: modelSubjectID,
        );

      default:
        break;
    }
  }

  static void saveContentHistory({
    required int accessID,
    required ContentInfo contentInfo,
    required ContentDetails contentDetail,
    required PostCommentType? postCommentType,
    String? sourceTitle,
    Object? sourceID,
  }) {
    final existing = MyHive.historySurfDataBase.get(accessID);

    if (existing != null) {
      MyHive.historySurfDataBase.put(
        accessID,
        existing
          ..updatedAt = DateTime.now().millisecondsSinceEpoch
          ..replies = contentDetail.contentRepliedComment?.length ?? 0,
      );

      return;
    }

    MyHive.historySurfDataBase.put(
      accessID,
      SurfTimelineDetails(detailID: accessID)
        ..updatedAt = DateTime.now().millisecondsSinceEpoch
        ..title = contentDetail.contentTitle ?? contentInfo.contentTitle
        ..sourceTitle = sourceTitle
        ..sourceID = sourceID ?? contentInfo.sourceID
        ..bangumiSurfTimelineType = BangumiSurfTimelineType.fromPostCommentType(postCommentType)
        ..replies = contentDetail.contentRepliedComment?.length ?? 0
        ..commentDetails = (CommentDetails()
          ..userInformation = contentDetail.userInformation ?? contentInfo.userInformation),
    );
  }
}
