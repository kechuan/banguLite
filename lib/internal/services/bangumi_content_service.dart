import 'dart:io';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/template.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 无状态内容写操作服务：承接好友/黑名单、发帖、回复、点赞、举报等 HTTP 写接口，
/// 避免这些与登录态状态管理无关的逻辑继续堆叠在 [AccountModel] 中。
class BangumiContentService {
  const BangumiContentService._();

  static Future<bool> userRelationAction(
    String? username, {
    UserRelationsActionType relationType = UserRelationsActionType.add,
    Function(String)? fallbackAction,
  }) async {
    if (username == null) return false;

    try {
      switch (relationType) {
        case UserRelationsActionType.add:
          await HttpApiClient.client.put(
            BangumiAPIUrls.addFriend(username),
            options: BangumiAPIUrls.bangumiAccessOption(),
          );

        case UserRelationsActionType.remove:
          await HttpApiClient.client.delete(
            BangumiAPIUrls.removeFriend(username),
            options: BangumiAPIUrls.bangumiAccessOption(),
          );

        case UserRelationsActionType.block:
          await HttpApiClient.client.put(
            BangumiAPIUrls.addBlockList(username),
            options: BangumiAPIUrls.bangumiAccessOption(),
          );

        case UserRelationsActionType.removeBlock:
          await HttpApiClient.client.delete(
            BangumiAPIUrls.removeBlockList(username),
            options: BangumiAPIUrls.bangumiAccessOption(),
          );
      }

      return true;
    }

    on DioException catch (e) {
      final message = extractDioException(e);
      debugPrint("[UserRelation] ${e.response?.statusCode} error:$message");
      fallbackAction?.call('${e.response?.statusCode} $message');

      return false;
    }
  }

  static Future<int> postContent({
    dynamic subjectID,
    String? title,
    String? content,
    PostCommentType? postContentType,
    UserContentActionType actionType = UserContentActionType.post,
    Map<String, dynamic>? subjectCommentData,
    Function(String message)? fallbackAction,
  }) async {
    final userInfo = AccountModel.loginedUserInformations;

    if (userInfo.accessToken == null) {
      debugPrint("账号未登录");
      return 0;
    }

    final String requestUrl = getPostContentUrl(
      subjectID: subjectID,
      postContentType: postContentType,
      actionType: actionType,
    );

    if (postContentType == null || requestUrl.isEmpty) {
      debugPrint(
        "空数据错误: postContentType:$postContentType / subjectID:$subjectID / requestUrl:$requestUrl",
      );
      fallbackAction?.call("发送失败");

      return 0;
    }

    if (actionType == UserContentActionType.post && userInfo.turnstileToken == null) {
      return 0;
    }

    try {
      final Response<dynamic> response = switch (actionType) {
        UserContentActionType.post => await HttpApiClient.client.post(
          requestUrl,
          data: BangumiDatas.postContentData(
            title: title,
            content: content,
            turnstileToken: userInfo.turnstileToken,
          ),
          options: BangumiAPIUrls.bangumiAccessOption(),
        ),

        UserContentActionType.edit => await HttpApiClient.client.put(
          requestUrl,
          data: subjectCommentData ??
            BangumiDatas.editContentData(
              title: title,
              content: content,
            ),
          options: BangumiAPIUrls.bangumiAccessOption(),
        ),

        UserContentActionType.delete => await HttpApiClient.client.delete(
          requestUrl,
          options: BangumiAPIUrls.bangumiAccessOption(),
        ),
      };

      if (response.statusCode == HttpStatus.ok) {
        return (response.data is Map ? response.data["id"] : null) ?? 1;
      }

      return 0;
    }

    on DioException catch (e) {
      debugPrint("[PostContent] DioException:${e.response?.data}");
      fallbackAction?.call('${e.response?.statusCode} ${extractDioException(e)}');

      return 0;
    }

    finally {
      if (actionType == UserContentActionType.post) {
        userInfo.turnstileToken = null;
      }
    }
  }

  static Future<int> toggleComment({
    int? contentID,
    int? commentID,
    String? commentContent,
    PostCommentType? postCommentType,
    UserContentActionType actionType = UserContentActionType.post,
    Function(String message)? fallbackAction,
  }) async {
    final userInfo = AccountModel.loginedUserInformations;

    if (userInfo.accessToken == null) {
      debugPrint("账号未登录");
      return 0;
    }

    final String requestUrl = getCommentUrl(
      contentID: contentID,
      commentID: commentID,
      postCommentType: postCommentType,
      actionType: actionType,
    );

    if (postCommentType == null || requestUrl.isEmpty) {
      debugPrint(
        "comment空数据错误: postCommentType:$postCommentType/commentID:$commentID",
      );

      return 0;
    }

    if (actionType == UserContentActionType.post && userInfo.turnstileToken == null) {
      return 0;
    }

    try {
      final Response<dynamic> response = switch (actionType) {
        UserContentActionType.post => await HttpApiClient.client.post(
          requestUrl,
          data: BangumiDatas.replyContentData(
            content: commentContent,
            replyTo: commentID ?? 0,
            turnstileToken: userInfo.turnstileToken,
          ),
          options: BangumiAPIUrls.bangumiAccessOption(),
        ),

        UserContentActionType.edit => await HttpApiClient.client.put(
          requestUrl,
          data: BangumiDatas.editContentData(content: commentContent),
          options: BangumiAPIUrls.bangumiAccessOption(),
        ),

        UserContentActionType.delete => await HttpApiClient.client.delete(
          requestUrl,
          options: BangumiAPIUrls.bangumiAccessOption(),
        ),
      };

      if (response.statusCode == HttpStatus.ok) {
        debugPrint("response id:${response.data is Map ? response.data["id"] : response.data}");
        return (response.data is Map ? response.data["id"] : null) ?? 1;
      }

      return 0;
    }

    on DioException catch (e) {
      final message = extractDioException(e);

      debugPrint(
        "[ToggleComment] '${e.response?.statusCode} $message'\n"
        "requestUrl: $requestUrl \n"
        "Query: ${BangumiDatas.replyContentData(
          content: commentContent,
          replyTo: commentID ?? 0,
          turnstileToken: userInfo.turnstileToken,
        )}",
      );
      fallbackAction?.call('${e.response?.statusCode} $message');

      return 0;
    }

    finally {
      userInfo.turnstileToken = null;
    }
  }

  static Future<bool> toggleCommentLike(
    int? commentID,
    int stickerLikeIndex,
    PostCommentType? postCommentType, {
    UserContentActionType actionType = UserContentActionType.post,
    Function(String message)? fallbackAction,
  }) async {
    if (postCommentType == null || commentID == null) {
      debugPrint("commentLike空数据错误");
      return false;
    }

    if (AccountModel.loginedUserInformations.accessToken == null) {
      debugPrint("账号未登录");
      return false;
    }

    final String requestUrl = switch (postCommentType) {
      PostCommentType.subjectComment => BangumiAPIUrls.toggleSubjectCommentLike(commentID),
      PostCommentType.replyEpComment => BangumiAPIUrls.toggleEPCommentLike(commentID),
      PostCommentType.replyTopic => BangumiAPIUrls.toggleTopicLike(commentID),
      PostCommentType.replyGroupTopic => BangumiAPIUrls.toggleGroupTopicLike(commentID),
      PostCommentType.postTimeline => BangumiAPIUrls.toggleTimelineLike(commentID),
      _ => "",
    };

    if (requestUrl.isEmpty) {
      debugPrint("commentLike不支持的类型: $postCommentType");
      return false;
    }

    try {
      final Response<dynamic> response;

      switch (actionType) {
        case UserContentActionType.post:
          response = await HttpApiClient.client.put(
            requestUrl,
            options: BangumiAPIUrls.bangumiAccessOption(),
            data: {"value": stickerLikeIndex},
          );

        case UserContentActionType.delete:
          response = await HttpApiClient.client.delete(
            requestUrl,
            options: BangumiAPIUrls.bangumiAccessOption(),
          );

        case UserContentActionType.edit:
          return false;
      }

      if (response.statusCode == HttpStatus.ok) {
        debugPrint("$actionType succ: commentID:$commentID / sticker:$stickerLikeIndex");
        return true;
      }

      fallbackAction?.call(
        "${response.statusCode} ${response.data is Map ? response.data["message"] : response.statusMessage}",
      );

      return false;
    }

    on DioException catch (e) {
      fallbackAction?.call("${e.response?.statusCode} ${extractDioException(e)}");
      return false;
    }
  }

  static Future<bool> reportContent(
    int contentID,
    int type,
    int value, {
    required String comment,
    Function(String message)? fallbackAction,
  }) async {
    try {
      final response = await HttpApiClient.client.post(
        BangumiAPIUrls.report(),
        data: BangumiDatas.reportData(
          reportID: contentID,
          reportType: type,
          reportValue: value,
          comment: comment,
        ),
        options: BangumiAPIUrls.bangumiAccessOption(),
      );

      if (response.statusCode == HttpStatus.ok) {
        return true;
      }

      fallbackAction?.call(
        "${response.statusCode} ${response.data is Map ? response.data["message"] : response.statusMessage}",
      );

      return false;
    }

    on DioException catch (e) {
      fallbackAction?.call("${e.response?.statusCode} ${extractDioException(e)}");
      return false;
    }
  }

  static String getPostContentUrl({
    required dynamic subjectID,
    required PostCommentType? postContentType,
    required UserContentActionType actionType,
  }) {
    switch (postContentType) {
      case PostCommentType.subjectComment:
        return BangumiAPIUrls.actionSubjectComment(
          subjectID is int ? subjectID : int.parse(subjectID.toString()),
        );

      case PostCommentType.postTopic:
        return BangumiAPIUrls.postTopic(subjectID);

      case PostCommentType.postTimeline:
        return actionType == UserContentActionType.post
          ? BangumiAPIUrls.postTimeline()
          : '${BangumiAPIUrls.postTimeline()}/$subjectID';

      case PostCommentType.postGroupTopic:
        return BangumiAPIUrls.postGroupTopic(subjectID!);

      case PostCommentType.postBlog:
      default:
        return "";
    }
  }

  static String getCommentUrl({
    required int? contentID,
    required int? commentID,
    required PostCommentType? postCommentType,
    required UserContentActionType actionType,
  }) {
    final isPost = actionType == UserContentActionType.post;

    switch (postCommentType) {
      case PostCommentType.replyEpComment:
        return isPost
          ? BangumiAPIUrls.postEpComment(contentID!)
          : BangumiAPIUrls.actionEpComment(commentID!);

      case PostCommentType.replyTopic:
        return isPost
          ? BangumiAPIUrls.postTopicComment(contentID!)
          : BangumiAPIUrls.actionTopicComment(commentID!);

      case PostCommentType.replyGroupTopic:
        return isPost
          ? BangumiAPIUrls.postGroupTopicComment(contentID!)
          : BangumiAPIUrls.actionGroupTopicComment(commentID!);

      case PostCommentType.replyBlog:
        return isPost
          ? BangumiAPIUrls.postBlogComment(contentID!)
          : BangumiAPIUrls.actionBlogComment(commentID!);

      case PostCommentType.replyTimeline:
      case PostCommentType.postTimeline:
        return BangumiAPIUrls.timelineReply(contentID!);

      default:
        return "";
    }
  }
}
