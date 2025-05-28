

import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/internal/utils/extract.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/template.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
import 'package:bangu_lite/models/informations/surf/user_notificaion_details.dart';
import 'package:bangu_lite/widgets/fragments/request_snack_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher_string.dart';



class AccountModel extends ChangeNotifier {

    AccountModel();

    static LoginedUserInformations loginedUserInformations = getDefaultLoginedUserInformations();

    Set<UserNotificaion> currentUserNotificaions = {};
    int unreadNotifications = 0;

    HeadlessInAppWebView? headlessWebView;

    bool? isLogining;

    bool isLogined() => loginedUserInformations.accessToken != null;

    void restoreData(){
      isLogining = null;
      loginedUserInformations = getDefaultLoginedUserInformations();
      updateLoginInformation(getDefaultLoginedUserInformations());
      currentUserNotificaions.clear();
      unreadNotifications = 0;
    }

    /// 在 [BangumiCalendarPage] 的 initState 进行初始化
    /// 因为 在 main 上面的 初始化时 无法获取到 materialAPP的 context 从而无法激活 [showRequestSnackBar]
    void initModel(BuildContext context) {
        loadUserDetail();

        verifySessionValidity(
            loginedUserInformations.accessToken,
            fallbackAction: (message) {
                showRequestSnackBar(message: message, requestStatus: false);
            },
        ).then((status) {

                    isLogining = true;
                    notifyListeners();

                    if (status) {

                        debugPrint("expired at:${loginedUserInformations.expiredTime}");
                        //debugPrint("accessToken:${loginedUserInformations.accessToken}");
                        isLogining = null;

                        getNotifications();

                        loginedUserInformations.expiredTime?.let((it) {
                          //效果还剩3天时自动刷新令牌
                          final differenceTime = DateTime.fromMillisecondsSinceEpoch(it * 1000).difference(DateTime.now());
                          if (differenceTime < const Duration(days: 3)) {
                              updateAccessToken(loginedUserInformations.refreshToken);
                              //debugPrint("${DateTime.fromMillisecondsSinceEpoch(it*1000).difference(DateTime.now()).inDays}");
                          }

                        });
                    }

                    else {
                        loginedUserInformations = getDefaultLoginedUserInformations();
                        isLogining = null;
                    }

                    notifyListeners();
                });
    }

    void logout() {
      restoreData();
      
      notifyListeners();
    }

    void login() {
        isLogining = true;
        launchUrlString(BangumiWebUrls.webAuthPage());
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

        else {

          return await generalRequest(
            BangumiAPIUrls.me,
            generalCompleteLoadAction:(response, completer) {
              debugPrint("accessToken: Valid, ${DateTime.now().millisecondsSinceEpoch ~/ 1000} / ${loginedUserInformations.expiredTime}");
              loginedUserInformations.userInformation = loadUserInformations(response.data);
              updateLoginInformation(loginedUserInformations);
              completer.complete(true);
            },
            generalFallbackAction: (String errorMessage,Completer<dynamic> completer){
              fallbackAction?.call(errorMessage);
              completer.complete(false);
            }
          );

        }

        
    }

    Future<bool> getAccessToken(
      String code,
      {Function(String)? fallbackAction}
    ) async {

        return await generalRequest(
          BangumiWebUrls.oAuthToken,
          data: BangumiQuerys.getAccessTokenQuery(code),
          userContentActionType: UserContentActionType.post,
          generalCompleteLoadAction: (Response response,Completer<dynamic> completer){
            verifySessionValidity(
              response.data["access_token"],
              fallbackAction: (message) { fallbackAction?.call('[verifySessionValidity] $message'); }
            ).then((isValid) {

              if (isValid) {

                loginedUserInformations
                  ..accessToken = response.data["access_token"]
                  ..expiredTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + (response.data["expires_in"] as int)
                  ..refreshToken = response.data["refresh_token"]
                ;

                //更新信息
                BangumiAPIUrls.bangumiAccessOption = Options(
                  headers: AccountModel.loginedUserInformations.accessToken != null ?
                  BangumiQuerys.bearerTokenAccessQuery(AccountModel.loginedUserInformations.accessToken) :
                  null
                );

                updateLoginInformation(loginedUserInformations);
                getNotifications();
              }

              else {
                restoreData();
              }

              completer.complete(isValid);
              isLogining = false;
              notifyListeners();

            });
          },
          generalFallbackAction: (String errorMessage,Completer<dynamic> completer){
            fallbackAction?.call('[AccessToken] $errorMessage');
            isLogining = false;
            completer.complete(false);
            notifyListeners();
            
          }
        );

    }

   

    Future<void> updateAccessToken(String? refreshToken) async {
        if (refreshToken == null) return;

        try{
            await HttpApiClient.client.post(
                BangumiWebUrls.oAuthToken,
                data: BangumiQuerys.refreshTokenQuery(refreshToken),
            ).then((response) {
                        if (response.statusCode == 200) {
                            debugPrint(
                                "update succ, ${DateTime.fromMillisecondsSinceEpoch((loginedUserInformations.expiredTime ?? 0) * 1000)} =>"
                                "${DateTime.now().add(Duration(seconds: response.data["expires_in"]))} \n"
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

    //账户相关操作.. 实在是有点太多了 要不。。聚合一下?
    Future<bool> userRelationAction(
        String? username,
        {
          UserRelationsActionType relationType = UserRelationsActionType.add,
          Function(String)? fallbackAction,
        }
    ) async {

        Completer<bool> userActionCompleter = Completer();

        if (username == null) return false;

        try{
            switch (relationType){
                case UserRelationsActionType.add:{
                    await HttpApiClient.client.put(
                        BangumiAPIUrls.addFriend(username),
                        options: BangumiAPIUrls.bangumiAccessOption,
                    );
                } 
                case UserRelationsActionType.remove:{
                    await HttpApiClient.client.delete(
                        BangumiAPIUrls.removeFriend(username),
                        options: BangumiAPIUrls.bangumiAccessOption,
                    );
                } 
                case UserRelationsActionType.block:{
                    await HttpApiClient.client.put(
                        BangumiAPIUrls.addBlockList(username),
                        options: BangumiAPIUrls.bangumiAccessOption,
                    );
                } 
                case UserRelationsActionType.removeBlock:{
                    await HttpApiClient.client.delete(
                        BangumiAPIUrls.removeBlockList(username),
                        options: BangumiAPIUrls.bangumiAccessOption,
                    );
                } 
            }

            userActionCompleter.complete(true);
        }

        on DioException catch(e){
            debugPrint("[UserRelation] ${e.response?.statusCode} error:${e.response?.data["message"]}");
            fallbackAction?.call('${e.response?.statusCode} ${e.response?.data["message"]}');
            userActionCompleter.complete(false);
        }

        return userActionCompleter.future;

    }

    Future<bool> getTrunsTileToken({
        Function(String)? fallbackAction
    }) {
        Completer<bool> getTrunsTileTokenCompleter = Completer();

        int errorReloadCount = 0;

        Timer? timeoutTimer;
        Timer? disposeTimer;

        headlessWebView = HeadlessInAppWebView(

            initialUrlRequest: URLRequest(url: WebUri(BangumiWebUrls.trunstileAuth())),
            initialSettings: InAppWebViewSettings(
                isInspectable: kDebugMode,
                userAgent: HttpApiClient.broswerHeader["User-Agent"],
            ),

            onWebViewCreated: (controller) async {
                debugPrint("webview created");
            },

            shouldOverrideUrlLoading: (controller, navigationAction) async {

                //似乎对Android 生效 对window难以拦截? window似乎并不会触发这个拦截
                debugPrint("shouldOverrideUrlLoading url:${navigationAction.request.url}");

                if (navigationAction.request.url.toString().startsWith(APPInformationRepository.bangumiTurnstileCallbackUri.toString())) {
                    navigationAction.request.url?.queryParameters["token"] != null ? 
                        AccountModel.loginedUserInformations.turnsTileToken = navigationAction.request.url?.queryParameters["token"] : 
                        null;

                    return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;

            },

            onLoadStart: (controller, url) async {

                if (url.toString().contains(APPInformationRepository.bangumiTurnstileCallbackUri.toString())) {
                    if (url?.queryParameters["token"] != null) {
                        loginedUserInformations.turnsTileToken = url?.queryParameters["token"];
                        getTrunsTileTokenCompleter.complete(true);
                        timeoutTimer?.cancel();
                        disposeTimer?.cancel();
                        headlessWebView?.dispose();
                    }

                }

                timeoutTimer ??= Timer(const Duration(seconds: 15), () {

                        //15s 仅限2次机会
                        if (errorReloadCount == 1) {
                            disposeTimer ??= Timer(const Duration(seconds: 5), () {
                                    debugPrint("webview dispose");
                                    controller.dispose();
                                    getTrunsTileTokenCompleter.complete(false);
                                    fallbackAction?.call("无法自动通过验证 发帖失败");
                                });
                        }

                        else {
                            errorReloadCount += 1;
                            debugPrint("trigged $errorReloadCount time(s) reload");
                            controller.reload();
                            timeoutTimer = null;
                        }

                    }
                );

                debugPrint("load start content:${url.toString()}");

            },

            onReceivedError: (controller, request, error) {
                if (request.url.toString().contains(APPInformationRepository.bangumiTurnstileCallbackUri.toString())) {
                    extractFallbackToken(controller).then((result) {
                            if (result != null) {
                                AccountModel.loginedUserInformations.turnsTileToken = result;
                            }
                        });
                }

            },

        );

        headlessWebView?.run();

        return getTrunsTileTokenCompleter.future;
    }

    Future<int> postContent({
      dynamic subjectID,
      String? title,
      String? content,
      PostCommentType? postContentType,
      UserContentActionType actionType = UserContentActionType.post,
      Map<String, dynamic>? subjectCommentQuery,
      Function(String message)? fallbackAction
    }) async {

        Completer<int> contentCompleter = Completer();

        String requestUrl = "";

        late Future<Response<dynamic>> Function() contentFuture;

        if (loginedUserInformations.accessToken == null) {
            debugPrint("账号未登录");
            contentCompleter.complete(0);
        }

        switch (postContentType){

            case PostCommentType.subjectComment: requestUrl = BangumiAPIUrls.actionSubjectComment(subjectID);
            case PostCommentType.postTopic: requestUrl = BangumiAPIUrls.postTopic(subjectID);
            case PostCommentType.postBlog:{
                //缺失中
            }

            case PostCommentType.postTimeline: {

                if (actionType == UserContentActionType.post) {
                    requestUrl = BangumiAPIUrls.postTimeline();
                }

                else {
                    requestUrl = '${BangumiAPIUrls.postTimeline()}/$subjectID';
                }

            }

            case PostCommentType.postGroupTopic:{
                requestUrl = BangumiAPIUrls.postGroupTopic(subjectID!);
            }

            default:{}

        }

        if (postContentType == null || requestUrl.isEmpty) {
            debugPrint(
                "空数据错误:"
                "postContentType:$postContentType / subjectID:$subjectID / requestUrl:$requestUrl"
            );
            fallbackAction?.call("发送失败");
            contentCompleter.complete(0);
        }

        switch (actionType){

            case UserContentActionType.post:{

                if (loginedUserInformations.turnsTileToken == null) return 0;

                contentFuture = () => HttpApiClient.client.post(
                    requestUrl,
                    data: BangumiQuerys.postQuery(
                        title: title,
                        content: content,
                        turnstileToken: loginedUserInformations.turnsTileToken,
                    ),
                    options: BangumiAPIUrls.bangumiAccessOption,
                );
            }

            //subjectComment 的 query 特殊
            case UserContentActionType.edit:{
                contentFuture = () => HttpApiClient.client.put(
                    requestUrl,
                    data: subjectCommentQuery ?? BangumiQuerys.editQuery(
                            title: title,
                            content: content,
                        ),
                    options: BangumiAPIUrls.bangumiAccessOption,
                );
            }

            case UserContentActionType.delete:{
                contentFuture = () => HttpApiClient.client.delete(
                    requestUrl,
                    options: BangumiAPIUrls.bangumiAccessOption,
                );
            }

        }

        try{
            await contentFuture().then((response) {
                    if (response.statusCode == 200) {
                        //目前只有 subjectComment 返回的 data 是空的 {}
                        //应该说是PUT行为是不返回的
                        //debugPrint("postID:${response.data["id"]}");
                        contentCompleter.complete(response.data["id"] ?? 200);
                    }

                    else {
                        contentCompleter.complete(0);
                        fallbackAction?.call('${response.statusCode} ${response.data["message"]}');
                    }

                });
        }

        on DioException catch (e){
            debugPrint("[PostContent] DioException:${e.response?.data}");
            fallbackAction?.call('${e.response?.statusCode} ${e.response?.data["message"]}');
            contentCompleter.complete(0);
        }

        return contentCompleter.future;

    }

    Future<int> toggleComment({
      int? contentID,
      int? commentID,
      String? commentContent,
      PostCommentType? postCommentType,
      UserContentActionType actionType = UserContentActionType.post,
      Function(String message)? fallbackAction
    }) async {

        Completer<int> commentCompleter = Completer();
        String requestUrl = "";

        late Future<Response<dynamic>> Function() commentFuture;

        if (loginedUserInformations.accessToken == null) {
            debugPrint("账号未登录");
            commentCompleter.complete(0);
        }

        switch (postCommentType){

            case PostCommentType.replyEpComment:{
            requestUrl = actionType == UserContentActionType.post ?
            BangumiAPIUrls.postEpComment(contentID!) :
            BangumiAPIUrls.actionEpComment(commentID!);

            }

            case PostCommentType.replyTopic:{

                requestUrl = actionType == UserContentActionType.post ?
                BangumiAPIUrls.postTopicComment(contentID!) :
                BangumiAPIUrls.actionTopicComment(commentID!);

            }

            case PostCommentType.replyGroupTopic:{

                requestUrl = actionType == UserContentActionType.post ?
                    BangumiAPIUrls.postGroupTopicComment(contentID!) :
                    BangumiAPIUrls.actionTopicComment(commentID!);

            }

            case PostCommentType.replyBlog:{
                requestUrl = actionType == UserContentActionType.post ?
                BangumiAPIUrls.postBlogComment(contentID!) :
                BangumiAPIUrls.actionBlogComment(commentID!);

            }

            case PostCommentType.replyTimeline:
            case PostCommentType.postTimeline:
            {
                requestUrl = BangumiAPIUrls.timelineReply(contentID!);
            }

            default:{}

        }

        if (postCommentType == null || requestUrl.isEmpty) {
            debugPrint(
              "comment空数据错误:"
              "postCommentType:$postCommentType/commentID:$commentID"
            );
            return 0;
        }

      switch (actionType){
          case UserContentActionType.post:{

              if (loginedUserInformations.turnsTileToken == null) return 0;

              commentFuture = () => HttpApiClient.client.post(
                  requestUrl,
                  data: BangumiQuerys.replyQuery(
                  content: commentContent,
                  replyTo: commentID ?? 0,
                  turnstileToken: loginedUserInformations.turnsTileToken,
                  ),
                  options: BangumiAPIUrls.bangumiAccessOption,
              );
          }

          case UserContentActionType.edit:{
              commentFuture = () => HttpApiClient.client.put(
              requestUrl,
              data: BangumiQuerys.editQuery(content: commentContent),
              options: BangumiAPIUrls.bangumiAccessOption,
              );
          }

          case UserContentActionType.delete:{
              commentFuture = () => HttpApiClient.client.delete(
                  requestUrl,
                  options: BangumiAPIUrls.bangumiAccessOption,
              );
          }

      }
      
      try{
        await commentFuture().then((response) {
          if (response.statusCode == 200) {
            debugPrint("response id:${response.data["id"]}");
            commentCompleter.complete(response.data["id"] ?? 1);
          }
        });
      }

      on DioException catch (e){
        debugPrint(
          "[ToggleComment] '${e.response?.statusCode} ${e.response?.data["message"]}'\n"
          "requestUrl: $requestUrl \n"
          "Query: ${BangumiQuerys.replyQuery(
            content: commentContent,
            replyTo: commentID ?? 0,
            turnstileToken: loginedUserInformations.turnsTileToken,
          )}"

        );
        fallbackAction?.call('${e.response?.statusCode} ${e.response?.data["message"]}');
        commentCompleter.complete(0);
      }

      finally{
        loginedUserInformations.turnsTileToken = null;
      }

      return commentCompleter.future;

    }

    //目前缺乏反馈
    Future<bool> toggleCommentLike(
      int? commentID,
      int stickerLikeIndex,
      PostCommentType? postCommentType,
      {
          UserContentActionType actionType = UserContentActionType.post,
          Function(String message)? fallbackAction
      }
    ) async {

        Completer<bool> likeCompleter = Completer();

        String requestUrl = "";

        late Future<Response<dynamic>> Function() actionLikeFuture;

        if (loginedUserInformations.accessToken == null) {
            debugPrint("账号未登录");
            likeCompleter.complete(false);
        }

        switch (postCommentType){

            // lacking...
            case PostCommentType.subjectComment: requestUrl = BangumiAPIUrls.toggleSubjectCommentLike(commentID!);
            case PostCommentType.replyEpComment: requestUrl = BangumiAPIUrls.toggleEPCommentLike(commentID!);
            case PostCommentType.replyTopic: requestUrl = BangumiAPIUrls.toggleTopicLike(commentID!);
            case PostCommentType.replyGroupTopic: requestUrl = BangumiAPIUrls.toggleGroupTopicLike(commentID!);

            //case PostCommentType.replyBlog:{
            //	requestUrl = BangumiAPIUrls.toggleGroupLike(commentID!);
            //}	

            default:{
            }

        }

        if (postCommentType == null || commentID == null || requestUrl.isEmpty) {
            debugPrint("commentLike空数据错误");
            return false;
        }

        switch (actionType){
            case UserContentActionType.post:{

                actionLikeFuture = () => HttpApiClient.client.put(
                    requestUrl,
                    options: BangumiAPIUrls.bangumiAccessOption,
                    data: {"value": stickerLikeIndex}
                );

            }

            case UserContentActionType.delete:{
                actionLikeFuture = () => HttpApiClient.client.delete(
                    requestUrl,
                    options: BangumiAPIUrls.bangumiAccessOption,
                );

            }

            default: {
            }
        }

        await actionLikeFuture().then((response) {
                if (response.statusCode == 200) {
                    debugPrint("$actionType succ: $commentID => $stickerLikeIndex");
                    likeCompleter.complete(true);
                }

                else {
                    likeCompleter.complete(false);
                    fallbackAction?.call("${response.statusCode} ${response.data["message"]}");
                }

            }
        );

        return likeCompleter.future;
    }

    Future<bool> getNotifications({
        bool? unread,
        int? limit,
        Function(String)? fallbackAction
    }) async {

        Completer<bool> notficationCompleter = Completer();

        if (loginedUserInformations.accessToken == null) {
            fallbackAction?.call("401 - 账号未登录");
            notficationCompleter.complete(false);
        }

        Map<String, dynamic> notificationsQuery = BangumiQuerys.notificationsQuery(limit: limit);

        if (unread == true) notificationsQuery["unread"] = true;

        await HttpApiClient.client.get(
            BangumiAPIUrls.notify,
            queryParameters: notificationsQuery,
            options: BangumiAPIUrls.bangumiAccessOption,
        ).then((response) {
                    if (response.statusCode == 200) {

                        if (unread == true) {

                            final notificationsList = loadUserNotificaions(response.data["data"]);

                            currentUserNotificaions.addAll(notificationsList);
                            unreadNotifications += notificationsList.length;
                        }

                        else {

                            unreadNotifications = 0;
                            currentUserNotificaions = loadUserNotificaions(response.data["data"]).toSet();

                            for (final currentNotification in currentUserNotificaions){
                                if (currentNotification.isUnRead == true) {
                                    unreadNotifications += 1;
                                }
                            }

                        }

                        notficationCompleter.complete(true);
                        notifyListeners();

                    }

                    else {
                        notficationCompleter.complete(false);

                        fallbackAction?.call("${response.statusCode} ${response.data["message"]}");
                    }

                });

        return notficationCompleter.future;
    }

    Future<bool> clearNotifications({
        List<int>? notificationIDList,
        Function(String)? fallbackAction
    }) async {

        Completer<bool> clearNotficationCompleter = Completer();

        if (loginedUserInformations.accessToken == null) {
            debugPrint("账号未登录");
            clearNotficationCompleter.complete(false);
        }

        await HttpApiClient.client.post(
            BangumiAPIUrls.clearNotify,
            options: BangumiAPIUrls.bangumiAccessOption,
            data: BangumiQuerys.clearNotificationsQuery(notificationIDList: notificationIDList)
        )
            .then((response) {
                    if (response.statusCode == 200) {

                        if (notificationIDList == null) {
                            unreadNotifications = 0;

                        }

                        else {
                            currentUserNotificaions = currentUserNotificaions.map((currentNotificaion) {
                                    if (notificationIDList.contains(currentNotificaion.notificationID)) {
                                        currentNotificaion.isUnRead = false;
                                        unreadNotifications -= 1;
                                    }
                                    return currentNotificaion;
                                }).toSet();
                        }

                        clearNotficationCompleter.complete(true);

                        notifyListeners();

                    }

                    else {
                        clearNotficationCompleter.complete(false);
                        fallbackAction?.call("${response.data["message"]}");
                    }

                });

        return clearNotficationCompleter.future;
    }

    @override
    void notifyListeners() {
        super.notifyListeners();
    }

}

