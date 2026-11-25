import 'dart:async';
import 'dart:io';

import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/models/informations/subjects/comment_details.dart';
import 'package:bangu_lite/models/informations/subjects/eps_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class EpModel extends ChangeNotifier{

  /// [EPModel] 将划分为 [单EP模式] 与 [正常模式]
  /// 正常模式 就是普通的透过 subjectID 进入 能正常的访问相邻的EP
  /// 而对于 [单EP模式] 则只能访问单独的EP 因为缺失 subjectID 以及 自身的定位
  /// (虽然理论上这两个信息都能透过EP信息中补全 但这样我的设计水平恐怕不足以支撑得起还能让这个model保持精致...)
  /// 因此对于 [单EP模式] 来说 它将仅能访问该页面本身 无法访问相邻页面
  /// 该模式下 [selectedEp] 将被强制设置为 0
  /// 
  /// 该情况适用于浏览帖子时遇到一个超链接导向ep的情况 如果是用户动态依旧是遵循 [正常模式] 来运行的
  
  
  EpModel({
    this.subjectID = 0,
    this.selectedEp = 0,
    this.injectEpID = 0,
  }){
    /// 一般来说 单EP模式的特征就是 [selectedEp],[subjectID] 皆为0(遇到EP.0的表示就算了)
    if(subjectID != 0) getEpsInformation();
    if(injectEpID != 0) getSingleEPInformation();
  }

  Completer? getEpsInformationCompleter;

  int subjectID;
  num selectedEp;

  int injectEpID;
  
  final Map<num,EpsInfo> epsData = {};
  final Map<num,List<EpCommentDetails>> epCommentData = {};

  Color? bangumiThemeColor;

  void updateSelectedEp(num newEp){
    if(newEp == selectedEp) return;

    selectedEp = newEp;
    notifyListeners();

	  if(epCommentData[selectedEp] == null) loadEpComment();
  }

	Future<void> getEpsInformation({int? offset}) async {

    if(getEpsInformationCompleter != null) return getEpsInformationCompleter!.future;

    int requestOffset = (offset ?? 0)*100;
    int requestLimit = 100;


    if(epsData.isNotEmpty){
      if(offset==null) return; //内部有数据时再次请求且不携带 offset值 则视为重复获取.因为永远都是 1~100 先会触发

      //假设条件1: offset:2 
      // 如果 301~400 未加载 则开始加载它 同时 
      // 如果 300 也未加载 那么则需要同时加载 201~300
      // 这样 在打开301的时候 理应同时触发 201~400 的加载任务
      if(epsData[(offset*100)+1] != null && epsData[(offset*100)] != null) return;

      //那怎么办呢 自适应调整offset和limit了吧

       if(epsData[(offset*100)+1] == null && epsData[(offset*100)] == null){
        requestOffset -= 100;
        requestLimit = 200;
      }
        
    }

    if(epsData[requestOffset+1] != null){
      debugPrint("loading Info ${requestOffset+1}~${requestOffset+100}");
      return;
    }

    final completer = Completer<void>();
    getEpsInformationCompleter = completer;
   
    //get Start. 占位符
    epsData[requestOffset+1] = EpsInfo.empty();

    try {
      final response = await HttpApiClient.client.get(
        BangumiAPIUrls.eps,
        queryParameters:
          BangumiQuerys.epQuery
            ..["offset"] = requestOffset
            ..["limit"] = requestLimit
            ..["subject_id"] = subjectID
      );

      if(response.data["data"] != null){
        List<EpsInfo> currentRangeEpsData = loadEpsData(response.data["data"]);

        num? epOffset = currentRangeEpsData.isEmpty ? 0 : currentRangeEpsData[0].epIndex;

        if(epOffset!=null){
          for(int epInfoIndex = 0; epInfoIndex < currentRangeEpsData.length; epInfoIndex++){
            epsData.addAll({
              (epOffset+epInfoIndex) : currentRangeEpsData[epInfoIndex]
            });
          }
        }

        debugPrint("currentEpsData Length:${epsData.length}");
        notifyListeners(); //完成
      } else {
        epsData.remove(requestOffset + 1);
        debugPrint("getEpsInformation Error: ${response.statusCode} ${response.statusMessage}");
      }
    } on DioException catch (e) {
      epsData.remove(requestOffset + 1);
      debugPrint("getEpsInformation DioException: $e");
    } finally {
      if (!completer.isCompleted) completer.complete();
      if (identical(getEpsInformationCompleter, completer)) {
        getEpsInformationCompleter = null;
      }
    }
	}

  Future<bool> getSingleEPInformation() async {
    try {
      final singleEPResponse = await HttpApiClient.client.get(BangumiAPIUrls.ep(injectEpID));
      epsData[0] = loadEpsData([singleEPResponse.data]).first;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      debugPrint("getSingleEPInformation Error: $e");
      return false;
    }
  }

	Future<bool> loadEpComment() async {
    final num targetEp = selectedEp;
    int requestID = 0;

    if(injectEpID == 0){

      if(epsData.isEmpty){
        await (getEpsInformationCompleter?.future ?? getEpsInformation());
        if(epsData.isEmpty) return false;
      }

      else{
        if(epsData[targetEp] == null){

          await (getEpsInformationCompleter?.future ?? getEpsInformation(offset: convertSegment(targetEp.toInt(),100)));
          if(epsData.isEmpty) return false;
        }
      }

      if(epCommentData[targetEp] != null){

        if(epCommentData[targetEp]!.isEmpty){
          debugPrint("$targetEp in Progress");
        }

        else{
          debugPrint("$targetEp already loaded");
        }

        return false;
      }

      requestID = epsData[targetEp]?.epID ?? 0;
      if(requestID == 0) return false;
    }

    else{

      requestID = injectEpID;

      if(epCommentData[targetEp] != null){
        debugPrint("$targetEp => injectEpID: $requestID already loaded");
        return false;
      }

    }

		//初始化占位
		epCommentData[targetEp] = [];


    try{
      final response = await HttpApiClient.client.get(
        BangumiAPIUrls.epComment(requestID),
      )
      .timeout(
        const Duration(seconds: 10),
        onTimeout:() {
          throw DioException(
            requestOptions:RequestOptions(),
            error: TimeoutException("[Timeout] 加载时间超过10s, 请检查网络通畅状况,或可尝试重新加载"),
          );
        },
      );

      if(response.statusCode == HttpStatus.ok){

        epCommentData[targetEp] = loadEpCommentDetails(response.data);

        //空处理 userName = 0 代表为空
        if(epCommentData[targetEp]!.isEmpty){
          epCommentData[targetEp] = [
            EpCommentDetails.empty()
          ];

          debugPrint("$subjectID Ep.$targetEp comment is Empty.");
        }

        debugPrint("$subjectID load Ep.$targetEp detail done");
        notifyListeners();
        return true;
      }

      else{
        epCommentData.remove(targetEp);
        debugPrint("$subjectID load Ep.$targetEp detail error: ${response.data is Map ? response.data["message"] : response.statusMessage}");
        return false;
      }

    }

    on DioException catch (e){
      epCommentData.remove(targetEp);
      debugPrint("[EPComment Load] $targetEp ${e.toString()}");
      throw e.error ?? e;
    }
	}
	
}