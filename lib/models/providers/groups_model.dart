import 'dart:async';

import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/group_details.dart';
import 'package:flutter/foundation.dart';

//全局Model 
//但适用规则 GroupDetails 基本等于 info 
// 而对于 Detail 来说 其子信息应当是 


class GroupsModel extends ChangeNotifier{

  GroupsModel(){loadGroups();}
  
  final Map<BangumiSurfGroupType,List<GroupInfo>> groupsData = {
    BangumiSurfGroupType.all: [],
    BangumiSurfGroupType.joined: [],
    BangumiSurfGroupType.created: [],
  };
  
  Future<bool> loadGroups({ 
    BangumiSurfGroupType mode = BangumiSurfGroupType.all,
    int? limit,
    int? offset
  }) async {

    Completer<bool> requestGroupsCompleter = Completer();

    await HttpApiClient.client.get(
      BangumiAPIUrls.groups(),
      queryParameters: BangumiQuerys.groupsQuery(
        mode: mode,
        limit: limit,
        offset: offset,
      )
    ).then((response){
      if(response.statusCode == 200){
        groupsData[mode] = loadGroupsInfo(response.data["data"]);
        notifyListeners();
      }
    });

    return requestGroupsCompleter.future;
    
  }

 




}