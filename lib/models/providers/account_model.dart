

import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/bangumi_define/response_status_code.dart';
import 'package:bangu_lite/internal/extension.dart';
import 'package:bangu_lite/internal/extract.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
import 'package:bangu_lite/models/informations/surf/user_notificaion_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher_string.dart';



class AccountModel extends ChangeNotifier {

    AccountModel(){
      initModel();
    }

    static LoginedUserInformations loginedUserInformations = getDefaultLoginedUserInformations();

    List<UserNotificaion> currentUserNotificaions = [];
	int unreadNotifications = 0;
    
    HeadlessInAppWebView? headlessWebView;

    void initModel() {
        loadUserDetail();

        verifySessionValidity(
            loginedUserInformations.accessToken,
        ).then((status) {
            if (status) {
				debugPrint("expired at:${loginedUserInformations.expiredTime}");

				getNotifications();

				loginedUserInformations.expiredTime?.let((it) {
					//效果还剩3天时自动刷新令牌
					final differenceTime = DateTime.fromMillisecondsSinceEpoch(it! * 1000).difference(DateTime.now());
					if (differenceTime < const Duration(days: 3)) {
					updateAccessToken(loginedUserInformations.refreshToken);
						//debugPrint("${DateTime.fromMillisecondsSinceEpoch(it*1000).difference(DateTime.now()).inDays}");
					}

				});
            }

            notifyListeners();
          }





        );
    }

    bool? isLogining;

    bool isLogined() => loginedUserInformations.accessToken != null;

    void logout() {
        isLogining = null;
        loginedUserInformations = getDefaultLoginedUserInformations();
		currentUserNotificaions.clear();
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
        notifyListeners();
    }

    Future<bool> verifySessionValidity(
        String? accessToken,
        {Function(int?)? fallbackAction}
    ) async {

        Completer<bool> verifyCompleter = Completer();

        if (accessToken == null) {
            debugPrint("账号未登录");

            if (fallbackAction != null) {
                fallbackAction(BangumiResponseStatusCode.unauthorized);
            }

            verifyCompleter.complete(false);
        }

        else {
            try{
                await HttpApiClient.client.get(
                    BangumiAPIUrls.me,
                    options: BangumiAPIUrls.bangumiAccessOption,

                ).then((response) {
                            if (response.statusCode == 200) {
                                debugPrint("accessToken: Valid, ${DateTime.now().millisecondsSinceEpoch ~/ 1000} / ${loginedUserInformations.expiredTime}");
                                loginedUserInformations.userInformation = loadUserInformations(response.data);
                                verifyCompleter.complete(true);
                            }
                        }
                    );
            }

            on DioException catch(e){
                debugPrint(" ${e.response?.statusCode} verifySessionValidity:${e.message}");

                fallbackAction?.call(e.response?.statusCode);
                loginedUserInformations = getDefaultLoginedUserInformations();

                verifyCompleter.complete(false);

            }

        }

        return verifyCompleter.future;
    }

    Future<bool> getAccessToken(String code) async{
        Completer<bool> getAccessTokenCompleter = Completer();
        try{
            await HttpApiClient.client.post(
                BangumiWebUrls.oAuthToken,
                data: BangumiQuerys.getAccessTokenQuery(code),
            ).then((response) async {
				if (response.statusCode == 200) {
					debugPrint("accessToken: Valid, ${DateTime.now().millisecondsSinceEpoch ~/ 1000} / ${loginedUserInformations.expiredTime}");

					await verifySessionValidity(
						response.data["access_token"],
						fallbackAction: (statusCode) {
							if (statusCode == BangumiResponseStatusCode.unauthorized) {
								launchUrlString(BangumiWebUrls.webAuthPage());
							}
						}
					).then((isValid) {
						if (isValid) {
							
							loginedUserInformations
							//返回的data数据不包含用户信息 仅包含用户的id(不是userName)
								//..userInformation = loadUserInformations(response.data["user"])
								..accessToken = response.data["access_token"]
								..expiredTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + (response.data["expires_in"] as int)
								..refreshToken = response.data["refresh_token"]
							;

							updateLoginInformation(loginedUserInformations);
							isLogining = false;
							getAccessTokenCompleter.complete(true);

						}

						else {
							loginedUserInformations = getDefaultLoginedUserInformations();
							isLogining = false;
							getAccessTokenCompleter.complete(false);
						}
					});

				}
          	});
        }

        on DioException catch(e){
            debugPrint(" ${e.response?.statusCode} error:${e.message}");
            getAccessTokenCompleter.complete(false);
            isLogining = false;
            loginedUserInformations = getDefaultLoginedUserInformations();
        }

        return getAccessTokenCompleter.future;

    }

    Future<void> updateAccessToken(String? refreshToken) async{
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
                            //"token:${loginedUserInformations.accessToken}"
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
                    }
                );
        }

        on DioException catch(e){
            debugPrint(" ${e.response?.statusCode} error:${e.message}");
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
            debugPrint("${e.response?.statusCode} error:${e.message}");
            userActionCompleter.complete(false);

            fallbackAction?.call('${e.message}');

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
            debugPrint("DioException:${e.response?.data}");
            fallbackAction?.call('${e.response?.statusCode} ${e.response?.data["message"]}');
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

            case PostCommentType.replyTimeline:{
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

        await commentFuture().then((response) {
                if (response.statusCode == 200) {
                    loginedUserInformations.turnsTileToken = null;
                    commentCompleter.complete(response.data["id"]);
                }

                else {
                    commentCompleter.complete(0);
                    fallbackAction?.call(response.data["message"]);
                }

            }
        );

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
                    fallbackAction?.call("${response.data["message"]}");
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
            debugPrint("账号未登录");
            notficationCompleter.complete(false);
        }


        await HttpApiClient.client.get(
          BangumiAPIUrls.notify,
          queryParameters: BangumiQuerys.notificationsQuery(limit: limit),
          options: BangumiAPIUrls.bangumiAccessOption,
        )
        .then((response) {
          if (response.statusCode == 200) {
            currentUserNotificaions = loadUserNotificaions(response.data["data"]);

			for(final currentNotification in currentUserNotificaions){
				if(currentNotification.isUnRead == true){
					unreadNotifications+=1;
				}
			}

            notficationCompleter.complete(true);
			notifyListeners();
            
          }

          else {
            notficationCompleter.complete(false);
            fallbackAction?.call("${response.data["message"]}");
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

			if(notificationIDList == null){
				unreadNotifications = 0;

			}

			else{
				currentUserNotificaions = currentUserNotificaions.map((currentNotificaion){
					if(notificationIDList.contains(currentNotificaion.notificationID)){
						currentNotificaion.isUnRead = false;
						unreadNotifications -= 1;
					}
					return currentNotificaion;
				}).toList();
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

