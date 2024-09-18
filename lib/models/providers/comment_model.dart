
import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/comment_details.dart';

class CommentModel extends ChangeNotifier {
  CommentModel();

  final Map<int,List<CommentDetails>> commentsData = {}; 

  //commentPage
  int commentID = 0;
  int commentLength = 0;
  int currentPageIndex = 1;

  void resetProp(){

    commentID = 0;
    commentLength = 0;
    currentPageIndex = 1;
    commentsData.clear();

    debugPrint("comments is clear:$commentsData");
    
  }

  void changePage(int newcurrentPageIndex){
    currentPageIndex = newcurrentPageIndex;
    notifyListeners();
  }

  //多重rebuild问题:  我需要区分 自动rebuild触发的loadComments 与 我真正想要触发的loadComments问题

  Future<void> getCommentLength(int subjectID) async {
    await HttpApiClient.client.get(
      BangumiUrls.comment(subjectID),
      queryParameters: BangumiQuerys.commentQuery..["limit"] = 1
    ).then((response){
      if(response.data != null && response.data["total"] != null){
        commentLength = response.data["total"];
        
      }
    });
  }

  Future<void> loadComments(int id,{int pageIndex = 1,bool isReverse = false, int pageRange = 10}) async {

    if(id == 0) return;

    //first effect loaded.
    if(commentLength==0){
      await getCommentLength(id);

      //empty comment handler.
      if(commentLength == 0){
        debugPrint("comment ID $id: was empty!");

        commentsData.addAll({
          1:[CommentDetails()..userId = 0],
        });

        notifyListeners();
        return;

      }
    }

    int totalPageCount = commentLength%pageRange == 0 ? commentLength~/pageRange : (commentLength~/pageRange)+1;

    //pageIndex Convert
    if(isReverse){
      //pageIndex = totalPageCount - (pageIndex-1);
      pageIndex = totalPageCount - (pageIndex);
    }

    //aliveKeepPage Judge. must notifier at First then disposed.
    if((currentPageIndex).abs() - pageIndex.abs() >= 3 || (currentPageIndex).abs() - pageIndex.abs() <= -3 ){
      debugPrint("prevent rebuild conflict:${commentsData.keys}");
      return;
    }


    //judge request start

    /*数据有3个状态 null,[],[...]  null => [] => [...] (Reset => null)
      null请求时 直接变为[] 
      []再被请求时 直接return; 相当于completer的使用方式
      当[]变为[...]时 通知notified
      [...]状态时再被请求时 如没有 refresh Flag类似的标识时 return;
    */


    //duplicate request Data Handler
    if(commentsData.isNotEmpty && commentsData[pageIndex] != null){

      if(commentsData[pageIndex]!.isEmpty){
        debugPrint("$pageIndex: already in queue");
        return; 
      }

      else{

        if(id == commentID){
          debugPrint("$pageIndex: data already loaded");
          return;
        }

        //此时为新替换

          WidgetsBinding.instance.addPostFrameCallback((timestamp){

            if(commentID != 0 && id != commentID){
              debugPrint("$pageIndex: it is new ID. update");
              commentID = id;
              resetProp(); //ready Reload

              notifyListeners();
            }

          });

        


        return; 
      }

    }

    //完全为空时
    if(commentsData[pageIndex] == null){
      commentsData[pageIndex] = []; //初始化
      debugPrint("pageIndex $pageIndex comment was inited.");
    }

    //期望行为: 当选中的页面 没有数据时才应该被触发 或许以后可以加refreshFlag 
    //但感觉。。又没什么必要 这里又不是什么高强度的信息流
    if(commentsData[pageIndex]!.isNotEmpty){
      debugPrint("[Warning] $pageIndex reParse");
      return;
    }

    debugPrint("ID $id: $pageIndex parse start, commentStamp: ${DateTime.now()}");

    //data Get

    try{

      final detailInformation = await HttpApiClient.client.get(
      BangumiUrls.comment(id),
      queryParameters: BangumiQuerys.commentQuery

      // 末数 比如 55-50 => 5 这样就不会请求一整页的数据 而是请求残余页的条目数
      ..["limit"] = min(pageRange , (commentLength - (pageRange)*(pageIndex)).abs()) 
      ..["offset"] =  isReverse ?
                      commentLength - (pageRange*(pageIndex-1)) : //要反向的话得从0开始算起offset
                      pageRange > commentLength ? 0 : (commentLength - (pageRange)*(pageIndex)).abs()
    );

      if(detailInformation.data!=null){
        commentsData[pageIndex] = CommentDetails.loadCommentResponse(detailInformation);
      }

      else{
        debugPrint("wrong!");
      }

      
      debugPrint("comment: ID $id: $pageIndex parse done, commentStamp: ${DateTime.now()}");


      if(id!=0) commentID = id;
      notifyListeners();

    }

    on DioException catch(e){
      debugPrint(e.toString());
    }


      

  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

}