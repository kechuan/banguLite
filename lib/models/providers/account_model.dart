

import 'dart:async';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AccountModel extends ChangeNotifier {

	AccountModel(){
		initModel();
	}

	LoginedUserInformations loginedUserInformations = getDefaultLoginedUserInformations();

	void initModel(){
		loadUserDetail();
		verifySessionValidity(loginedUserInformations.accessToken).then((status){
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

	Future<bool> verifySessionValidity(String? accessToken) async {

		Completer<bool> verifyCompleter = Completer();

		if(accessToken==null){
		debugPrint("账号未登录");
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

			
			await verifySessionValidity(response.data["access_token"]).then((isValid){
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
			debugPrint("update succ, ${loginedUserInformations.expiredTime} => ${DateTime.now().millisecondsSinceEpoch~/1000 + (response.data["expires_in"])}");

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

/// 通用回复字段 {
///  "content": "string",
///  "replyTo": 0, replyComment/replyContent 的区分
///  "turnstileToken": "string"

//待测试: 在 topic之下 0 与 楼主id 的效果是否会相同?
//例: replyTo: 0 与 replyTo: 248073
//如果不相同。。恐怕要额外增加switch了。。
	Future<bool> toggleComment(
		int? commentID,
		String? commentContent,
		String? turnstileToken,
		PostCommentType? postCommentType,
		{UserContentActionType actionType = UserContentActionType.post}
	) async {

		Completer<bool> commentCompleter = Completer();

		String requestUrl = "";

		late Future<Response<dynamic>> Function(int? commentContent) commentFuture;

		if(loginedUserInformations.accessToken==null){
			debugPrint("账号未登录");
			commentCompleter.complete(false);
		}

		switch(postCommentType){
			//reply部分统统未开放
				
			//  case PostCommentType.comment:{}
				
			case PostCommentType.replyEpComment:{
				/// /p1/episodes/{episodeID}/comments
				requestUrl = BangumiAPIUrls.postEPComment(commentID!);
			}

			//case PostCommentType.replyEpComment:{
			//	/// /p1/episodes/{episodeID}/comments/{commentID}
			//	requestUrl = BangumiAPIUrls.epComment(commentID!);
			//}
				
			//  case PostCommentType.commentEpCommentReply:{}
				
			case PostCommentType.postTopic:{
				// /p1/subjects/-/topics/{topicID}/replies
				requestUrl = BangumiAPIUrls.postTopic(commentID!);
			}

			case PostCommentType.replyTopic:{
				// /p1/subjects/-/posts/{postID}
				requestUrl = BangumiAPIUrls.postTopicComment(commentID!);
				
			}

			//case PostCommentType.postBlog:{
			//	//requestUrl = BangumiAPIUrls.postBlogComment(commentID!);
			//}
				
			//  case PostCommentType.commentTopicReply:{}
			case PostCommentType.replyBlog:{
				requestUrl = BangumiAPIUrls.postBlogComment(commentID!);
			}

			//  case PostCommentType.commentBlogReply:{}

			default:{}
			
		}

		if(postCommentType == null || commentID == null || requestUrl.isEmpty || turnstileToken == null){
			debugPrint(
				"comment空数据错误:"
				"postCommentType:$postCommentType/commentID:$commentID/requestUrl:$requestUrl/turnstileToken:$turnstileToken"
			);
			commentCompleter.complete(false);
		}

		switch(actionType){
			case UserContentActionType.post:{
				commentFuture = (data) => HttpApiClient.client.post(
					requestUrl,
					queryParameters: BangumiQuerys.replyQuery
					..["content"] = commentContent
					..['replyTo'] = commentID
					..['turnstileToken'] = commentID
					,
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
				
			case PostCommentType.postEpComment:
			case PostCommentType.replyEpComment:{
				requestUrl = BangumiAPIUrls.toggleEPCommentLike(commentID!);
			}
				
			case PostCommentType.replyTopic:
			case PostCommentType.commentTopicReply:{
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

