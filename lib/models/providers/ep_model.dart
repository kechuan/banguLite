import 'dart:async';

import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/comment_details.dart';
import 'package:bangu_lite/models/eps_info.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/user_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EpModel extends ChangeNotifier{
  
  EpModel({
    this.subjectID = 0,
    this.selectedEp = 0,
    //this.episodesID,
  }){
    //遇到直接需要加载Ep Page 的页面话 需要做 Completer 处理
    getEpsInformation();
  }

  //final int? episodesID; //一旦提供 则只能是固定数据

  Completer? getEpsInformationCompleter;

  int subjectID;
  int selectedEp;
  
  final Map<num,EpsInfo> epsData = {};
  final Map<num,List<EpCommentDetails>> epCommentData = {}; 

  //double => 浮点 #3 / #3-1 etc
  final Map<int,Map<num,int>> userCommentLikeData = {}; 

  void updateSelectedEp(int newEp){
    if(newEp == selectedEp) return;

    selectedEp = newEp;
    notifyListeners();

	  if(epCommentData[selectedEp] == null) loadEpComment();
  }

  bool? updateUserEpCommentDataLike(
    int commentID,
    int dataLikeIndex,
    {
      int? commentIndex,
      int? replyCommentIndex,
    }){

      if(epCommentData[selectedEp] == null || commentIndex == null) return null;

      	bool isExist = true;

		if(userCommentLikeData[selectedEp] == null){

			userCommentLikeData[selectedEp] = {
			double.parse('$commentIndex.${replyCommentIndex ?? 0}') : dataLikeIndex
			};
		}

		else{

			if(userCommentLikeData[selectedEp]![double.parse('$commentIndex.${replyCommentIndex ?? 0}')] == dataLikeIndex){
				userCommentLikeData[selectedEp]![double.parse('$commentIndex.${replyCommentIndex ?? 0}')] = -1;
				isExist = false;
			}

			else{
				userCommentLikeData[selectedEp]![double.parse('$commentIndex.${replyCommentIndex ?? 0}')] = dataLikeIndex;
			}


		}

		WidgetsBinding.instance.addPostFrameCallback((_) {
			notifyListeners();
		});

		return isExist;


  }

  void updateEpCommentDataLike(
    BuildContext context,
    int dataLikeIndex,
    {
      int? commentIndex,
      int? replyCommentIndex,
    }
  ){

    if(epCommentData[selectedEp] == null || commentIndex == null) return;

    final accountModel = context.read<AccountModel>();

    epCommentData.update(
      selectedEp, 
      (epCommentDetailsList){

        if(replyCommentIndex != null){
          epCommentDetailsList[commentIndex-1].repliedComment![replyCommentIndex-1].commentReactions!.update(
            dataLikeIndex, 
            (commentReactionData){
              commentReactionData.add(
                AccountModel.loginedUserInformations.userInformation!.getName()
              );
              return commentReactionData;
            }, 
            ifAbsent: (){
              return { 
                AccountModel.loginedUserInformations.userInformation!.getName()
              };
            }
          );


        }

        else{

          epCommentDetailsList[commentIndex-1].commentReactions!.update(
            dataLikeIndex, 
            (commentReactionData){
              commentReactionData.add(
                AccountModel.loginedUserInformations.userInformation!.getName()
              );
              return commentReactionData;
            }, 
            ifAbsent: (){
              return { 
                AccountModel.loginedUserInformations.userInformation!.getName()
              };
            }
          );


        }

        return epCommentDetailsList;

      }
    );

    notifyListeners();
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
        
          List<EpsInfo> currentRangeEpsData = loadEpsData(response);

          num? epOffset = currentRangeEpsData.isEmpty ? 0 : currentRangeEpsData[0].epIndex;

          if(epOffset!=null){
            for(int epInfoIndex = 0; epInfoIndex < currentRangeEpsData.length; epInfoIndex++){
              epsData.addAll({
                (epOffset+epInfoIndex): currentRangeEpsData[epInfoIndex]
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

	Future<void> loadEpComment() async{

      //TODO 加载顺序有问题
      if(epsData.isEmpty){
        await getEpsInformationCompleter?.future ?? await getEpsInformation();
        
        if(epsData.isEmpty) return;
      }

      else{
        if(epsData[selectedEp] == null){

          await getEpsInformationCompleter?.future ?? await getEpsInformation(offset: convertSegement(selectedEp,100));
          if(epsData.isEmpty) return;
        }
      }

      if(epCommentData[selectedEp] != null){

        if(epCommentData[selectedEp]!.isEmpty){
          debugPrint("$selectedEp in Progress");
        }

        debugPrint("$selectedEp already loaded");
        
        return;
      }
    


    int requestID = epsData[selectedEp]?.epID ?? 0;
    if(requestID == 0) return;

		//初始化占位
		epCommentData[selectedEp] = [];
		
		await HttpApiClient.client.get(
			BangumiAPIUrls.epComment(requestID),
		).then((response){
			if(response.data != null){

			epCommentData[selectedEp] = loadEpCommentDetails(response.data);

			//空处理 userName = 0 代表为空
			if(epCommentData[selectedEp]!.isEmpty){
				epCommentData[selectedEp] = [
          EpCommentDetails()
            ..userInformation = (
              UserInformation()..userID = 0
            )
            
        ];
			}
			
			debugPrint("$subjectID load Ep.$selectedEp detail done");

			notifyListeners();

			}
		});

	}
	
}