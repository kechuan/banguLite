

import 'dart:io';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/services/bangumi_content_service.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/internal/utils/get.dart';
import 'package:bangu_lite/internal/utils/template.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
import 'package:bangu_lite/models/informations/surf/user_notification_details.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AccountModel extends ChangeNotifier {

  AccountModel();

  static LoginedUserInformations loginedUserInformations = getDefaultLoginedUserInformations();

  Set<UserNotification> currentUserNotifications = {};
  int unreadNotifications = 0;

  //HeadlessInAppWebView? headlessWebView;

  LoginStatus accountLoginStatus = LoginStatus.logout;

  bool isLogined() => loginedUserInformations.accessToken != null;

  void restoreData() {
    accountLoginStatus = LoginStatus.logout;
    loginedUserInformations = getDefaultLoginedUserInformations();
    updateLoginInformation(getDefaultLoginedUserInformations());
    currentUserNotifications.clear();
    unreadNotifications = 0;

  }

  /// 在 [BangumiCalendarPage] 的 initState 进行初始化
  /// 因为 在 main 上面的 初始化时 无法获取到 materialAPP的 context 从而无法激活 [showRequestSnackBar]
  void initModel(BuildContext context) async {
    loadUserDetail();

    Duration overlapDuration = const Duration();
    await loginedUserInformations.expiredTime?.let((it) async {

      overlapDuration = DateTime.fromMillisecondsSinceEpoch(it * 1000).difference(DateTime.now());

      //效果还剩3天时自动刷新令牌
      if (overlapDuration < const Duration(days: 3) && overlapDuration > const Duration(minutes: 1)) {
        await updateAccessToken(loginedUserInformations.refreshToken);
      }

      else if (overlapDuration < const Duration(days: 0)) {
        logout();
        if (context.mounted) {
          showRequestSnackBar(backgroundColor: getCurrentThemeColor(context), message: "登录已过期", requestStatus: false);
        }

        return;
      }

    });

    verifySessionValidity(
      loginedUserInformations.accessToken,
      fallbackAction: (message) {
        showRequestSnackBar(backgroundColor: getCurrentThemeColor(context), message: message, requestStatus: false);
      },
    ).then((status) {

        if (status) {
          debugPrint("[Session Expired countDown] :${overlapDuration.inDays} Days ${(((overlapDuration.inHours / 24) % 1) * 24).toStringAsFixed(1)} Hours");
          getNotifications();

        }

        notifyListeners();
      });
  }

  void logout() {
    restoreData();

    notifyListeners();
  }

  void loginWebAuth() {
    accountLoginStatus = LoginStatus.logining;
    launchUrlString(
      BangumiWebUrls.webAuthPage(),
      mode: LaunchMode.externalApplication,
    );
    notifyListeners();  
  }

  void loadUserDetail() {
    loginedUserInformations = MyHive.loginUserDataBase.get('loginUserInformations') ?? getDefaultLoginedUserInformations();
  }

  void updateLoginInformation(LoginedUserInformations loginedUserInformations) {
    MyHive.loginUserDataBase.put('loginUserInformations', loginedUserInformations);
  }

  Future<bool> verifySessionValidity(
    String? accessToken,
    {Function(String)? fallbackAction}
  ) async {

    if (accessToken == null) {
      debugPrint("账号未登录");
      return false;
    }

    return generalRequest<bool>(
      BangumiAPIUrls.me,
      options: Options(
        headers: BangumiQuerys.bearerTokenAccessQuery(accessToken)
      ),
      onSuccess: (response) {
        debugPrint("accessToken: Valid, ${DateTime.now().millisecondsSinceEpoch ~/ 1000} / ${loginedUserInformations.expiredTime}");
        loginedUserInformations.userInformation = loadUserInformations(response.data);
        accountLoginStatus = LoginStatus.logined;
        return true;
      },
      onError: (errorMessage) {
        fallbackAction?.call(errorMessage);
        return false;
      },
    );

  }

  Future<bool> getAccessToken(
    String code,
    {Function(String)? fallbackAction}
  ) async {

    return generalRequest<bool>(
      BangumiWebUrls.oAuthToken,
      data: BangumiQuerys.getAccessTokenQuery(code),
      userContentActionType: UserContentActionType.post,
      onSuccess: (response) async {
        final isValid = await verifySessionValidity(
          response.data["access_token"],
          fallbackAction: (message) {
            fallbackAction?.call('[verifySessionValidity] $message');
          },
        );

        if (isValid) {
          loginedUserInformations
            ..accessToken = response.data["access_token"]
            ..expiredTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + (response.data["expires_in"] as int)
            ..refreshToken = response.data["refresh_token"]
          ;

          updateLoginInformation(loginedUserInformations);
          accountLoginStatus = LoginStatus.logined;
          getNotifications();
        } else {
          logout();
        }

        notifyListeners();
        return isValid;
      },
      onError: (errorMessage) {
        fallbackAction?.call('[AccessToken] $errorMessage');
        accountLoginStatus = LoginStatus.failed;
        notifyListeners();
        return false;
      },
    );

  }

  Future<void> updateAccessToken(String? refreshToken) async {
    if (refreshToken == null) return;

    try{
      await HttpApiClient.client.post(
        BangumiWebUrls.oAuthToken,
        data: BangumiQuerys.refreshTokenQuery(refreshToken),
      ).then((response) {
          if (response.statusCode == HttpStatus.ok) {
            debugPrint(
              "[LoginSession] session update succ, ${DateTime.fromMillisecondsSinceEpoch((loginedUserInformations.expiredTime ?? 0) * 1000)} => "
              "${DateTime.now().add(Duration(seconds: response.data["expires_in"]))}"
            );

            loginedUserInformations
              ..accessToken = response.data["access_token"]
              ..expiredTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + (response.data["expires_in"] as int)
              ..refreshToken = response.data["refresh_token"]
            ;
            updateLoginInformation(loginedUserInformations);

          }

          else {
            debugPrint("update fail. token may already expired");
            launchUrlString(BangumiWebUrls.webAuthPage());
          }
        });
    }

    on DioException catch(e){
      debugPrint("[UpdateToken] ${e.response?.statusCode} error:${e.message}");
    }
  }

  // 账户相关写操作委托给无状态的 BangumiContentService
  Future<bool> userRelationAction(
    String? username, {
    UserRelationsActionType relationType = UserRelationsActionType.add,
    Function(String)? fallbackAction,
  }) =>
      BangumiContentService.userRelationAction(
        username,
        relationType: relationType,
        fallbackAction: fallbackAction,
      );

  Future<int> postContent({
    dynamic subjectID,
    String? title,
    String? content,
    PostCommentType? postContentType,
    UserContentActionType actionType = UserContentActionType.post,
    Map<String, dynamic>? subjectCommentData,
    Function(String message)? fallbackAction,
  }) =>
      BangumiContentService.postContent(
        subjectID: subjectID,
        title: title,
        content: content,
        postContentType: postContentType,
        actionType: actionType,
        subjectCommentData: subjectCommentData,
        fallbackAction: fallbackAction,
      );

  Future<int> toggleComment({
    int? contentID,
    int? commentID,
    String? commentContent,
    PostCommentType? postCommentType,
    UserContentActionType actionType = UserContentActionType.post,
    Function(String message)? fallbackAction,
  }) =>
      BangumiContentService.toggleComment(
        contentID: contentID,
        commentID: commentID,
        commentContent: commentContent,
        postCommentType: postCommentType,
        actionType: actionType,
        fallbackAction: fallbackAction,
      );

  Future<bool> toggleCommentLike(
    int? commentID,
    int stickerLikeIndex,
    PostCommentType? postCommentType, {
    UserContentActionType actionType = UserContentActionType.post,
    Function(String message)? fallbackAction,
  }) =>
      BangumiContentService.toggleCommentLike(
        commentID,
        stickerLikeIndex,
        postCommentType,
        actionType: actionType,
        fallbackAction: fallbackAction,
      );

  Future<bool> getNotifications({
    bool? unread,
    int? limit,
    Function(String)? fallbackAction
  }) async {

    if (loginedUserInformations.accessToken == null) {
      fallbackAction?.call("401 - 账号未登录");
      return false;
    }

    Map<String, dynamic> notificationsQuery = BangumiQuerys.notificationsQuery(limit: limit);

    if (unread == true) notificationsQuery["unread"] = true;

    try {
      final response = await HttpApiClient.client.get(
        BangumiAPIUrls.notify,
        queryParameters: notificationsQuery,
        options: BangumiAPIUrls.bangumiAccessOption(),
      );

      if (response.statusCode == HttpStatus.ok) {

        if (unread == true) {

          final notificationsList = loadUserNotifications(response.data["data"]);

          currentUserNotifications.addAll(notificationsList);
          unreadNotifications += notificationsList.length;
        }

        else {

          unreadNotifications = 0;
          currentUserNotifications = loadUserNotifications(response.data["data"]).toSet();

          for (final currentNotification in currentUserNotifications){
            if (currentNotification.isUnRead == true) {
              unreadNotifications += 1;
            }
          }

        }

        notifyListeners();
        return true;
      }

      fallbackAction?.call("${response.statusCode} ${response.data is Map ? response.data["message"] : response.statusMessage}");
      return false;
    } on DioException catch (e) {
      fallbackAction?.call("${e.response?.statusCode} ${extractDioException(e)}");
      return false;
    }
  }

  Future<bool> clearNotifications({
    List<int>? notificationIDList,
    Function(String)? fallbackAction
  }) async {

    if (loginedUserInformations.accessToken == null) {
      debugPrint("账号未登录");
      return false;
    }

    try {
      final response = await HttpApiClient.client.post(
        BangumiAPIUrls.clearNotify,
        options: BangumiAPIUrls.bangumiAccessOption(),
        data: BangumiQuerys.clearNotificationsQuery(notificationIDList: notificationIDList)
      );

      if (response.statusCode == HttpStatus.ok) {

        if (notificationIDList == null) {
          unreadNotifications = 0;
        }

        else {
          currentUserNotifications = currentUserNotifications.map((currentNotification) {
            if (notificationIDList.contains(currentNotification.notificationID)) {
              if (currentNotification.isUnRead == true && unreadNotifications > 0) {
                unreadNotifications -= 1;
              }
              currentNotification.isUnRead = false;
            }
            return currentNotification;
          }).toSet();
        }

        notifyListeners();
        return true;
      }

      fallbackAction?.call("${response.data is Map ? response.data["message"] : response.statusMessage}");
      return false;
    } on DioException catch (e) {
      fallbackAction?.call("${e.response?.statusCode} ${extractDioException(e)}");
      return false;
    }
  }

  Future<bool> reportContent(
    int contentID,
    int type,
    int value, {
    required String comment,
    Function(String message)? fallbackAction,
  }) =>
      BangumiContentService.reportContent(
        contentID,
        type,
        value,
        comment: comment,
        fallbackAction: fallbackAction,
      );

}

