import 'package:bangu_lite/models/informations/subjects/base_details.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';

class TimelineChatDetails extends ContentDetails {
  TimelineChatDetails({
    super.detailID
  });

  factory TimelineChatDetails.empty() => TimelineChatDetails(detailID: 0);
}
/// 空有 Replies/relatedID 字段
/// 但实际上在web的操作仅仅只是帮你输入了一个 [user][/user] 而已 与 默认指向 0 的数据而已
/// 那就暂且不用这个 TimelineChatDetails 了


List<TimelineChatDetails> loadTimelineChatDetails(List<dynamic> timelineChatListData){
  List<TimelineChatDetails> timelineChatDetailsList = [];

  for(int index = 0; index < timelineChatListData.length; index++){

    TimelineChatDetails timelineChatDetails = TimelineChatDetails(
      detailID: timelineChatListData[index]["id"],
    )
      
      ..content = timelineChatListData[index]["content"]
      ..userInformation = loadUserInformations(timelineChatListData[index]["user"])
      ..createdTime = timelineChatListData[index]["createdAt"]
      
    ;


    timelineChatDetailsList.add(timelineChatDetails);
  }


  return timelineChatDetailsList;
}
