import 'dart:async';

import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/request_client.dart';
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
  
  
  EpModel({
    this.subjectID = 0,
    this.selectedEp = 0,
    this.injectEpID = 0
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

  void updateSelectedEp(num newEp){
    if(newEp == selectedEp) return;

    selectedEp = newEp;
    notifyListeners();

	  if(epCommentData[selectedEp] == null) loadEpComment();
  }

	Future<void> getEpsInformation({int? offset}) async {

    if(getEpsInformationCompleter != null) return;

    getEpsInformationCompleter ??= Completer();


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
   
    //get Start. 占位符
    epsData[requestOffset+1] = EpsInfo();

		await HttpApiClient.client.get(
      BangumiAPIUrls.eps,
      queryParameters: 
        BangumiQuerys.epQuery
          ..["offset"] = requestOffset
          ..["limit"] = requestLimit
          ..["subject_id"] = subjectID
          
    ).then((response){

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

          getEpsInformationCompleter?.complete();

          notifyListeners(); //完成

        }

        else{
          debugPrint("getEpsInformation Error: ${response.statusCode} ${response.statusMessage}");
          getEpsInformationCompleter?.complete();
        }



    });

    return getEpsInformationCompleter?.future;

	}

  Future<bool> getSingleEPInformation() async {

    if(injectEpID == 0) return false;

    Completer<bool> singleEPCompleter = Completer();

    await HttpApiClient.client.get(BangumiAPIUrls.ep(injectEpID)).then((singleEPResponse){
      epsData[0] = loadEpsData([singleEPResponse.data]).first;
      singleEPCompleter.complete(true);
    });


    return singleEPCompleter.future;
  }

	Future<bool> loadEpComment() async {

    Completer<bool> epCommentCompleter = Completer();

    int requestID = 0;

    if(injectEpID == 0){

      if(epsData.isEmpty){
        await getEpsInformationCompleter?.future ?? await getEpsInformation();
        if(epsData.isEmpty) return false;
      }

      else{
        if(epsData[selectedEp] == null){

          await getEpsInformationCompleter?.future ?? await getEpsInformation(offset: convertSegement(selectedEp.toInt(),100));
          if(epsData.isEmpty) return false;
        }
      }

      if(epCommentData[selectedEp] != null){

        if(epCommentData[selectedEp]!.isEmpty){
          debugPrint("$selectedEp in Progress");
        }

        else{
          debugPrint("$selectedEp already loaded");
        }

        
        
        return false;
      }

      requestID = epsData[selectedEp]?.epID ?? 0;
      if(requestID == 0) return false;
    }

    else{

      requestID = injectEpID;

      if(epCommentData[selectedEp] != null){
        debugPrint("$selectedEp => injectEpID: $requestID already loaded");
        return false;
      }

    }

		//初始化占位
		epCommentData[selectedEp] = [];


    try{
      await HttpApiClient.client.get(
        BangumiAPIUrls.epComment(requestID),
      )
      .timeout(
        Duration(seconds: 10),
        //DEBUG Duration(microseconds: isRefresh == true ? 30 : 10),
        onTimeout:() {
          throw DioException(
            requestOptions:RequestOptions(),
            error: TimeoutException("[Timeout] 加载时间超过10s, 请检查网络通畅状况,或可尝试重新加载"),
          );
        },
      )
      .then((response){
        if(response.statusCode == 200){

          epCommentData[selectedEp] = loadEpCommentDetails(response.data);

          //空处理 userName = 0 代表为空
          if(epCommentData[selectedEp]!.isEmpty){
            epCommentData[selectedEp] = [
              EpCommentDetails.empty()
            ];
          }

          epCommentCompleter.complete(true);
          
          debugPrint("$subjectID load Ep.$selectedEp detail done");

          notifyListeners();

        }

        else{
          debugPrint("$subjectID load Ep.$selectedEp detail error: ${response.data["message"]}");
          epCommentCompleter.complete(false);
        }
        
      });

    }

    on DioException catch (e){
      debugPrint("[EPComment Load] $selectedEp ${e.toString()}");
      epCommentCompleter.completeError(e.error!);
    }
		


    return epCommentCompleter.future;
	}
	
}