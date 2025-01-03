
import 'dart:async';
import 'dart:math';

import 'package:bangu_lite/internal/convert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/comment_details.dart';

class CommentModel extends ChangeNotifier {
  
  CommentModel();

  final Map<int,List<CommentDetails>> commentsData = {}; 

  //commentPage
  //int commentID = 0;
  int commentLength = 0;
  int currentPageIndex = 1;

  void changePage(int newcurrentPageIndex){
    currentPageIndex = newcurrentPageIndex;
    notifyListeners();
  }

  Future<void> getCommentLength(int subjectID) async {
    await HttpApiClient.client.get(
      BangumiAPIUrls.comment(subjectID),
      queryParameters: BangumiQuerys.commentQuery..["limit"] = 1
    ).then((response){
      if(response.data != null && response.data["total"] != null){
        commentLength = response.data["total"];
      }
    });
  }

  Future<void> loadComments(int subjectID,{int pageIndex = 1,bool isReverse = false, int pageRange = 10}) async {

    if(subjectID == 0) return;

    //first effect loaded.
    if(commentLength==0){
      await getCommentLength(subjectID);

      //empty comment handler.
      if(commentLength == 0){
        debugPrint("comment subjectID $subjectID: was empty!");

        //因为 null/[] 已经被用来占用为 标志位了 无数据返回部分就以这种形式进行处理
        commentsData.addAll({1:[CommentDetails()..userId = 0]});

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
    if((currentPageIndex).abs() - pageIndex.abs() >= 3 || (currentPageIndex).abs() - pageIndex.abs() <= -3 ){
      debugPrint("prevent rebuild conflict:${commentsData.keys}");
      return;
    }


    //judge request start

    /*
      数据有3个状态 null,[],[...]  null => [] => [...] (Reset => null)
      null请求时 直接变为[] 意为activing
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

      final detailInformation = await HttpApiClient.client.get(
      BangumiAPIUrls.comment(subjectID),
      queryParameters: BangumiQuerys.commentQuery

      // 末数 比如 55-50 => 5 这样就不会请求一整页的数据 而是请求残余页的条目数
      ..["limit"] = min(pageRange , (commentLength - (pageRange)*(pageIndex - 1)).abs()) 
      ..["offset"] =  isReverse ?
                      (pageRange)*(pageIndex - 1) > commentLength ? commentLength - pageRange : (pageRange)*(pageIndex - 1) :
                      pageRange > commentLength ? 0 : (pageRange)*(pageIndex - 1).abs()

      //old Data
      //..["limit"] = min(pageRange , (commentLength - (pageRange)*(pageIndex)).abs()) 
      //..["offset"] =  isReverse ?
      //commentLength - (pageRange*(pageIndex-1)) : //要反向的话得从0开始算起offset
      //pageRange > commentLength ? 0 : (commentLength - (pageRange)*(pageIndex)).abs()

                
    );

      if(detailInformation.data!=null){
        commentsData[pageIndex] = loadCommentResponse(detailInformation);
      }

      else{
        debugPrint("wrong! server no response");

        commentsData.addAll({
          pageIndex:[CommentDetails()..userId = 0],
        });

      }

      
      debugPrint("comment: subjectID $subjectID: $pageIndex parse done, commentStamp: ${DateTime.now()}");


      //if(id!=0) commentID = id;
      notifyListeners();

    }

    on DioException catch(e){
      debugPrint("Request Error:${e.toString()}");
    }

  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

}