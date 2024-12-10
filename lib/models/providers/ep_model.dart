import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/ep_details.dart';
import 'package:bangu_lite/models/eps_info.dart';
import 'package:flutter/material.dart';

class EpModel extends ChangeNotifier{
  
  EpModel({
    required this.subjectID,
    required this.selectedEp,
  }){
    getEpsInformation();
  }

  int subjectID;
  int selectedEp;
  
  final Map<int,EpsInfo> epsData = {};
  final Map<int,List<EpCommentDetails>> epCommentData = {}; 

  void updateSelectedEp(int newEp){
    if(newEp == selectedEp) return;

    selectedEp = newEp;
    notifyListeners();

	  if(epCommentData[selectedEp] == null) loadEp();
  }

	Future<void> getEpsInformation({int? offset}) async {

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

    if(epsData[requestOffset+1]!= null){
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

        if(response.data != null && response.data["data"] != null){
        
          List<EpsInfo> currentRangeEpsData = loadEpsData(response);

          int? epOffset = currentRangeEpsData[0].epIndex;

          if(epOffset!=null){
            for(int epInfoIndex = 0; epInfoIndex < currentRangeEpsData.length; epInfoIndex++){
              epsData.addAll({
                (epOffset+epInfoIndex): currentRangeEpsData[epInfoIndex]
              });
            }
          }

          debugPrint("currentEpsData Length:${epsData.length}");

          notifyListeners(); //完成

        }

    });

	}

	Future<void> loadEp() async{

		if(epsData.isEmpty){
			await getEpsInformation();
			if(epsData.isEmpty) return;
		}

    else{
      if(epsData[selectedEp] == null){
        await getEpsInformation(offset: convertSegement(selectedEp,100));
        if(epsData.isEmpty) return;
      }
    }

    

		if(epCommentData[selectedEp] != null){

			if(epCommentData[selectedEp]!.isEmpty){
				debugPrint("$selectedEp in Progress");
				return;
			}

			debugPrint("$selectedEp already loaded");
			
			return;
		}

		//初始化占位
		epCommentData[selectedEp] = [];
		
		await HttpApiClient.client.get(
			BangumiAPIUrls.epComment(epsData[selectedEp]!.epID!),
		).then((response){
			if(response.data != null){

			epCommentData[selectedEp] = loadEpCommentDetails(response);

			//空处理 userId = 0 代表为空
			if(epCommentData[selectedEp]!.isEmpty){
				epCommentData[selectedEp] = [EpCommentDetails()..userId = 0];
			}
			
			debugPrint("$subjectID load Ep.$selectedEp detail done");

			notifyListeners();

			}
		});

	}
	
}