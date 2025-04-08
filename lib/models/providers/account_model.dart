

import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';
import 'package:bangu_lite/internal/bangumi_define/response_status_code.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AccountModel extends ChangeNotifier {

	AccountModel(){
		initModel();
	}

	LoginedUserInformations loginedUserInformations = getDefaultLoginedUserInformations();

  HeadlessInAppWebView? headlessWebView;

	void initModel(){
		loadUserDetail();
		verifySessionValidity(
      loginedUserInformations.accessToken,
      fallbackAction: (statusCode){
        if(statusCode == BangumiResponseStatusCode.unauthorized){
          launchUrlString(BangumiWebUrls.webAuthPage());
        }
      }
    ).then((status){
		if(status){
			updateAccessToken(loginedUserInformations.refreshToken);
		}
		
		notifyListeners();

		});
	}

	bool isLogined() => loginedUserInformations.accessToken!=null;

	void loadUserDetail(){
		loginedUserInformations = MyHive.loginUserDataBase.get('loginUserInformations') ?? getDefaultLoginedUserInformations();
	}

	void updateLoginInformation(LoginedUserInformations loginedUserInformations){
		MyHive.loginUserDataBase.put('loginUserInformations', loginedUserInformations);
		notifyListeners();
	}

	Future<bool> verifySessionValidity(
    String? accessToken,
    {Function(int?)? fallbackAction}
  ) async {

		Completer<bool> verifyCompleter = Completer();

		if(accessToken==null){
      debugPrint("账号未登录");

      if(fallbackAction!=null){
        fallbackAction(BangumiResponseStatusCode.unauthorized);
      }

      verifyCompleter.complete(false);
		}

		else{
		try{
			await HttpApiClient.client.get(
			BangumiAPIUrls.me,
			options: Options(
				headers: BangumiQuerys.bearerTokenAccessQuery(accessToken),
			),
		
			).then((response) {
        if(response.statusCode == 200){
          debugPrint("accessToken: Valid, ${DateTime.now().millisecondsSinceEpoch~/1000} / ${loginedUserInformations.expiredTime}");
          loginedUserInformations.userInformation = loadUserInformations(response.data);
          verifyCompleter.complete(true);
        }
        });
			}

			on DioException catch(e){
				debugPrint(" ${e.response?.statusCode} verifySessionValidity:${e.message}");

        if(fallbackAction!=null){
          fallbackAction(e.response?.statusCode);
        }

        

				verifyCompleter.complete(false);
			}

		}

		return verifyCompleter.future;
	}

	Future<void> getAccessToken(String code) async{
		try{
		await HttpApiClient.client.post(
			BangumiWebUrls.oAuthToken,
			data: BangumiQuerys.getAccessTokenQuery(code),
		).then((response) async {
			if(response.statusCode == 200){
			debugPrint("accessToken: Valid, ${DateTime.now().millisecondsSinceEpoch~/1000} / ${loginedUserInformations.expiredTime}");

			
			await verifySessionValidity(
        response.data["access_token"],
        fallbackAction: (statusCode){
        if(statusCode == BangumiResponseStatusCode.unauthorized){
          launchUrlString(BangumiWebUrls.webAuthPage());
        }
      }
      ).then((isValid){
				if(isValid){
				loginedUserInformations
					..accessToken = response.data["access_token"]
					..expiredTime = DateTime.now().millisecondsSinceEpoch~/1000 + (response.data["expires_in"] as int)
					..refreshToken = response.data["refresh_token"]
				;

				updateLoginInformation(loginedUserInformations);
					
				}
			});

			

			}
		});
		}

		on DioException catch(e){
		debugPrint(" ${e.response?.statusCode} error:${e.message}");
		}
	}

	Future<void> updateAccessToken(String? refreshToken) async{
		if(refreshToken==null) return;

		try{
		await HttpApiClient.client.post(
			BangumiWebUrls.oAuthToken,
			data: BangumiQuerys.refreshTokenQuery(refreshToken),
		).then((response) {
			if(response.statusCode == 200){
			debugPrint(
        "update succ, ${DateTime.fromMillisecondsSinceEpoch((loginedUserInformations.expiredTime ?? 0)*1000)} =>"
        "${DateTime.now().add(Duration(seconds: response.data["expires_in"]))} \n"
        "token:${loginedUserInformations.accessToken}"
      );

			loginedUserInformations
				..accessToken = response.data["access_token"]
				..expiredTime = DateTime.now().millisecondsSinceEpoch~/1000 + (response.data["expires_in"] as int)
				..refreshToken = response.data["refresh_token"]
			;
			updateLoginInformation(loginedUserInformations);
			
			}

			else{
			debugPrint("update fail. token may already expired");
			launchUrlString(BangumiWebUrls.webAuthPage());
			}
		});
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

    if(username==null) return false;

    try{
      switch(relationType){
          case UserRelationsActionType.add: await HttpApiClient.client.put(BangumiAPIUrls.addFriend(username)); break;
          case UserRelationsActionType.remove: await HttpApiClient.client.delete(BangumiAPIUrls.removeFriend(username)); break;
          case UserRelationsActionType.block: await HttpApiClient.client.put(BangumiAPIUrls.addBlockList(username)); break;
          case UserRelationsActionType.removeBlock: await HttpApiClient.client.delete(BangumiAPIUrls.removeBlockList(username)); break;
      }

      userActionCompleter.complete(true);
    }

    on DioException catch(e){
      debugPrint("${e.response?.statusCode} error:${e.message}");
      userActionCompleter.complete(false);
      if(fallbackAction!=null){
        fallbackAction('${e.message}')!;
      }

    }

    return userActionCompleter.future;

  }

  Future<bool> getTrunsTileToken({
    Function(String)? fallbackAction
  }){
    Completer<bool> getTrunsTileTokenCompleter = Completer();

    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(BangumiWebUrls.trunstileAuth())),
      initialSettings: InAppWebViewSettings(isInspectable: kDebugMode),
      onWebViewCreated: (controller) {
        debugPrint("webview created");
      },
      onLoadStart: (controller, url){
        if(url.toString().contains(APPInformationRepository.bangumiTurnstileCallbackUri.toString())){
          if(url?.queryParameters["token"] != null){
            loginedUserInformations.turnsTileToken = url?.queryParameters["token"];
            getTrunsTileTokenCompleter.complete(true);
            headlessWebView?.dispose();
          }

        }
      },

    );

    headlessWebView?.run();


    return getTrunsTileTokenCompleter.future;
  }

  Future<bool> postContent(
		{
      int? subjectID,
      String? titleContent,
		  String? contentContent,
      PostCommentType? postcontentType,
      UserContentActionType actionType = UserContentActionType.post,
    }
	) async {

		Completer<bool> contentCompleter = Completer();

		String requestUrl = "";

		late Future<Response<dynamic>> Function(int? contentContent) contentFuture;

		if(loginedUserInformations.accessToken==null){
			debugPrint("账号未登录");
			contentCompleter.complete(false);
		}

		switch(postcontentType){

      case PostCommentType.subjectComment:{

      }

      
      case PostCommentType.postTopic:{
				
			}
				
			case PostCommentType.postBlog:{
				
			}

			case PostCommentType.timeline:{
				subjectID = 0;
			}

			default:{}
			
		}

		if(postcontentType == null || subjectID == null || requestUrl.isEmpty){
			debugPrint(
				"content空数据错误:"
				"postcontentType:$postcontentType/subjectID:$subjectID/requestUrl:$requestUrl"
			);
			contentCompleter.complete(false);
		}

    await getTrunsTileToken();

		switch(actionType){
			case UserContentActionType.post:{
				contentFuture = (data) => HttpApiClient.client.post(
					requestUrl,
          data: BangumiQuerys.postQuery(
            title: titleContent,
            content: contentContent,
            turnstileToken: loginedUserInformations.turnsTileToken,
          ),
					options: Options(
						headers: BangumiQuerys.bearerTokenAccessQuery(loginedUserInformations.accessToken!),
					),
				);
			}

			case UserContentActionType.edit:{
				contentFuture = (data) => HttpApiClient.client.put(
					requestUrl,
					options: Options(
						headers: BangumiQuerys.bearerTokenAccessQuery(loginedUserInformations.accessToken!),
					),
				);
			}
			
			case UserContentActionType.delete:{
        contentFuture = (data) => HttpApiClient.client.delete(
          requestUrl,
          options: Options(
            headers: BangumiQuerys.bearerTokenAccessQuery(loginedUserInformations.accessToken!),
          ),
        );
		}
			
			
		}

		await contentFuture(subjectID).then((response){
			if(response.statusCode == 200){
				contentCompleter.complete(true);
			}

			else{
				contentCompleter.complete(false);
			}
		
		});

		return contentCompleter.future;

	}

/// 通用回复字段 {
///  "content": "string",
///  "replyTo": 0, replyComment/replyContent 的区分
///  "turnstileToken": "string"

//待测试: 在 topic之下 0 与 楼主id 的效果是否会相同? 
//例: replyTo: 0 与 replyTo: 248073
//嗯。。别搞这些 直接按严格不相同就行

	Future<bool> toggleComment({
    int? commentID,
    String? commentContent,
    PostCommentType? postCommentType,
    UserContentActionType actionType = UserContentActionType.post,
    int? replyTo
  }) async {

		Completer<bool> commentCompleter = Completer();

		String requestUrl = "";

		late Future<Response<dynamic>> Function(int? commentContent) commentFuture;

		if(loginedUserInformations.accessToken==null){
			debugPrint("账号未登录");
			commentCompleter.complete(false);
		}

    if(postCommentType == null || commentID == null){
			debugPrint(
				"comment空数据错误:"
				"postCommentType:$postCommentType/commentID:$commentID"
			);
			commentCompleter.complete(false);
		}

		switch(postCommentType){

      case PostCommentType.replyEpComment:{
        
        if(actionType == UserContentActionType.post){
          requestUrl = BangumiAPIUrls.postEpComment(commentID!);
        }

        else{
          requestUrl = BangumiAPIUrls.actionEpComment(commentID!);
        }


			}
				
			case PostCommentType.replyTopic:{
        if(actionType == UserContentActionType.post){
          requestUrl = BangumiAPIUrls.postTopicComment(commentID!);
        }

        else{
          
        }
				
			}

			case PostCommentType.replyBlog:{
        if(actionType == UserContentActionType.post){
          requestUrl = BangumiAPIUrls.postBlogComment(commentID!);
        }

        else{
          requestUrl = BangumiAPIUrls.actionBlogComment(commentID!);
        }
				
			}

			default:{}
			
		}

		

    await getTrunsTileToken();

		switch(actionType){
			case UserContentActionType.post:{
				commentFuture = (data) => HttpApiClient.client.post(
					requestUrl,
          data: 
            BangumiQuerys.replyQuery(
              content: commentContent,
              replyTo: replyTo,
              turnstileToken: loginedUserInformations.turnsTileToken,
            ),
					options: Options(
						headers: BangumiQuerys.bearerTokenAccessQuery(loginedUserInformations.accessToken!),
					),
				);
			}

			case UserContentActionType.edit:{
				commentFuture = (data) => HttpApiClient.client.put(
					requestUrl,
					options: Options(
						headers: BangumiQuerys.bearerTokenAccessQuery(loginedUserInformations.accessToken!),
					),
				);
			}
			
			case UserContentActionType.delete:{
        commentFuture = (data) => HttpApiClient.client.delete(
          requestUrl,
          options: Options(
            headers: BangumiQuerys.bearerTokenAccessQuery(loginedUserInformations.accessToken!),
          ),
        );
		}
			
			
		}

		await commentFuture(commentID).then((response){
			if(response.statusCode == 200){
				commentCompleter.complete(true);
			}

			else{
				commentCompleter.complete(false);
			}
		
		});

		return commentCompleter.future;

	}





	//目前缺乏反馈
	Future<bool> toggleCommentLike(
		int? commentID,
		int stickerLikeIndex,
		PostCommentType? postCommentType,
		{UserContentActionType actionType = UserContentActionType.post}
	) async {

		Completer<bool> likeCompleter = Completer();

		String requestUrl = "";

		late Future<Response<dynamic>> Function(int? stickerLikeIndex) actionLikeFuture;

		if(loginedUserInformations.accessToken==null){
			debugPrint("账号未登录");
			likeCompleter.complete(false);
		}

		bool isEffectRequest = true;

		switch(postCommentType){
			
			//  case PostCommentType.comment:{}
				
			case PostCommentType.replyEpComment:
			case PostCommentType.replyEpComment:{
				requestUrl = BangumiAPIUrls.toggleEPCommentLike(commentID!);
			}
				
			case PostCommentType.replyTopic:
			{
				requestUrl = BangumiAPIUrls.toggleTopicLike(commentID!);
			}
				

			//case PostCommentType.postBlog:
			//case PostCommentType.replyBlog:{
			//	requestUrl = BangumiAPIUrls.toggleBlogLike(commentID!);
			//}	
			//  case PostCommentType.commentTopicReply:{}
			//  case PostCommentType.postBlog:{}
			//  case PostCommentType.replyBlog:{}
			//  case PostCommentType.commentBlogReply:{}

			default:{}
			
		}

		if(postCommentType == null || commentID == null || requestUrl.isEmpty){
			debugPrint("commentLike空数据错误");
			isEffectRequest = false;
		}

		switch(actionType){
			case UserContentActionType.post:{

				if(!isEffectRequest) {
					actionLikeFuture = (data) => Future(()=>Response(requestOptions: RequestOptions()));
				}

				else{
					actionLikeFuture = (data) => HttpApiClient.client.put(
						requestUrl,
						options: Options(
							headers: BangumiQuerys.bearerTokenAccessQuery(loginedUserInformations.accessToken!),
						),
						data: {"value": stickerLikeIndex}
					);
				}


				
			}
			
			case UserContentActionType.delete:{
				if(!isEffectRequest){
					actionLikeFuture = (data) => Future(()=>Response(requestOptions: RequestOptions()));
				}

				else{
					actionLikeFuture = (data) => HttpApiClient.client.delete(
						requestUrl,
						options: Options(
							headers: BangumiQuerys.bearerTokenAccessQuery(loginedUserInformations.accessToken!),
						),
					);
				}

				
			}
			
			default: {}
		}

		await actionLikeFuture(stickerLikeIndex).then((response){
			if(response.statusCode == 200){
				debugPrint("$actionType succ: $commentID => $stickerLikeIndex");
				likeCompleter.complete(true);
			}

			else{
				likeCompleter.complete(false);
			}
		
		});

		return likeCompleter.future;
	}

}

