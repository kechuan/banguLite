
import 'dart:async';
import 'dart:math';


import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';

class CommentModel extends ChangeNotifier {
  
  CommentModel({required this.subjectID});

  static const int disactivePageRange = 5;

  final int subjectID;

  ///subject的评论详情, 一页的长度为10个 [CommentDetails]
  ///透过 [loadComments] 函数进行装载, 并在 [dispose] 时移除数据.
  ///
  ///该数据一共被我认为的设立三种状态: 
  ///- null
  ///- []
  ///- [...]
  ///
  ///其演变流程为:null => [] => [...] (Reset => null)
  ///
  /// 数据为null: 请求时 直接变为数据空 [] 意为 [activing]
  /// 
  /// 数据为[]: 再被请求时 直接return; 相当于 [completer] 的使用方式
  /// 
  /// 当[] => [...]时 触发 [notifiedListener] 意为 [done]
  /// 
  /// 而加载失败时 []就会被重新remove变回 null 意为 [fail]
  /// 
  /// [...]状态时再被请求时 如没有 refresh Flag 类似的标识时 return.
  final Map<int,List<CommentDetails>> commentsData = {}; 

  //APP用户自己发的评论
  CommentDetails? userCommentDetails;

  int commentLength = 0;
  int currentPageIndex = 1;

  void changePage(int newcurrentPageIndex){
    currentPageIndex = newcurrentPageIndex;
    notifyListeners();
  }

  Future<void> getCommentLength(int subjectID) async {
    await HttpApiClient.client.get(
      BangumiAPIUrls.subjectComment(subjectID),
      queryParameters: BangumiQuerys.commentAccessQuery..["limit"] = 1
    ).then((response){
      if(response.data != null && response.data["total"] != null){
        commentLength = response.data["total"];
      }
    });
  }

  ///触发 [isReverse] flag与否以进行 最新/最早 评论的切换
  ///
  ///请求到数据后会透过 [notifyListeners] 通知UI组件这个数据已准备好
  //Future<void> loadComments(int subjectID,{int pageIndex = 1,bool isReverse = false, int pageRange = 10}) async {

  //筛选 用途?
  Future<void> loadUserComment({
    UserInformation? currentUserInformation,
    Function(String)? fallbackAction
  }) async {
    if(subjectID == 0 || currentUserInformation == null) return;
    if(userCommentDetails != null) return; 

    //占位符
    userCommentDetails = CommentDetails();

    try{
      final userStarInformation = await HttpApiClient.client.get(
        BangumiAPIUrls.userSubjectComment(currentUserInformation.userName!,subjectID)
      );

      if(userStarInformation.data != null){
        userCommentDetails = CommentDetails()
          ..userInformation = currentUserInformation
          ..commentTimeStamp = DateTime.parse(userStarInformation.data["updated_at"]).toLocal().millisecondsSinceEpoch
          ..comment = userStarInformation.data["comment"]
          ..rate = userStarInformation.data["rate"]
          ..type = StarType.values.firstWhere(
            (element) => element.starTypeIndex == userStarInformation.data["type"]
          )
        ;

        debugPrint("用户收藏了该条目: $subjectID, ${userCommentDetails?.type?.starTypeName}");

        notifyListeners();
      }
    
    }

    on DioException catch(e){
      if(e.response?.statusCode == 404){
        debugPrint("用户未收藏该条目: $subjectID");
      }

      else{
        fallbackAction?.call("Request Error:${e.toString()}");
        debugPrint("Request Error:${e.toString()}");
      }
        
    }

    
  }
  
  Future<void> loadComments(
    {
      int pageIndex = 1,
      bool isReverse = false,
      int pageRange = 10,
      bool isReloaded = false,
      Function(String)? fallbackAction
    }
  ) async {

    if(subjectID == 0) return;

    //first effect loaded.
    if(commentLength==0){
      await getCommentLength(subjectID);

      //empty comment handler.
      if(commentLength == 0){
        debugPrint("comment subjectID $subjectID: was empty!");

        //因为 null/[] 已经被用来占用为 标志位了 无数据返回部分就以这种形式进行处理
        commentsData.addAll({0:[CommentDetails.empty()]});

        notifyListeners();
        return;

      }
    }

    int totalPageCount = convertTotalCommentPage(commentLength, pageRange);

    //pageIndex Convert
    if(isReverse){
      //pageIndex = totalPageCount - (pageIndex-1);
      pageIndex = totalPageCount - (pageIndex);
    }

    //aliveKeepPage Judge. must notifier at First then disposed.
    if((currentPageIndex).abs() - pageIndex.abs() >= disactivePageRange || (currentPageIndex).abs() - pageIndex.abs() <= -disactivePageRange ){
      debugPrint("prevent rebuild conflict:${commentsData.keys}");
      return;
    }

    if(isReloaded){
      debugPrint("$pageIndex: reloaded");
      commentsData.remove(pageIndex);
    }


    //judge request start

    //duplicate request Data Handler
    if(commentsData.isNotEmpty && commentsData[pageIndex] != null){

      if(commentsData[pageIndex]!.isEmpty){
        debugPrint("$pageIndex: already in queue");
        return; 
      }

      else{
        debugPrint("$pageIndex: data already loaded");
        return;
      }

    }

    //完全为空时
    if(commentsData[pageIndex] == null){
      commentsData[pageIndex] = []; //初始化
      debugPrint("pageIndex $pageIndex comment was inited.");
    }

    debugPrint("subjectID $subjectID: $pageIndex parse start, commentStamp: ${DateTime.now()}");


    //data Get

    //2024.10.01 update 官方数据似乎终于把 1 放到 最新的数据 而非最旧的数据了。
    try{

      int currentRequestRange = (pageRange)*(pageIndex - 1).abs();

      final detailInformation = await HttpApiClient.client.get(
      BangumiAPIUrls.subjectComment(subjectID),
      queryParameters: BangumiQuerys.commentAccessQuery

      // 末数 比如 55-(10*(6-1)) => 5 这样就不会请求一整页的数据 而是请求残余页的条目数
      ..["limit"] = min(pageRange , (commentLength - currentRequestRange)) 
      ..["offset"] =  isReverse ?
                      (currentRequestRange > commentLength ? commentLength - pageRange : currentRequestRange) :
                      pageRange > commentLength ? 0 : currentRequestRange

                
    ).catchError((error){
        commentsData.remove(pageIndex);
        return Response(requestOptions: RequestOptions());
    });

      if(detailInformation.data!=null){
        commentsData[pageIndex] = loadCommentResponse(detailInformation);
      }

      else{
        debugPrint("wrong! server no response");

        commentsData.addAll({
          pageIndex:[CommentDetails.empty()]
        });
      }

      
      debugPrint("comment: subjectID $subjectID: $pageIndex parse done, commentStamp: ${DateTime.now()}");

      notifyListeners();

    }

    on DioException catch(e){
      debugPrint("Request Error:${e.toString()}");
      fallbackAction?.call("Request Error:${e.toString()}");
    }

  }

  @override
  void notifyListeners() {
    //For exernal use with no warnning hint
    super.notifyListeners();
  }

  @override
  void dispose() {
    commentsData.clear();
    super.dispose();
  }

}