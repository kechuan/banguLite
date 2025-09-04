
import 'package:bangu_lite/models/informations/subjects/base_info.dart';
import 'package:bangu_lite/models/informations/surf/user_details.dart';

class TimelineChatDetails extends ContentInfo {
  TimelineChatDetails({
	super.id
  });


  factory TimelineChatDetails.empty() => TimelineChatDetails()..id = 0;

}

List<TimelineChatDetails> loadTimelineChatDetails(List<dynamic> timelineChatListData){
  List<TimelineChatDetails> timelineChatDetailsList = [];

  for(int index = 0; index < timelineChatListData.length; index++){

    TimelineChatDetails timelineChatDetails = TimelineChatDetails(
      id: timelineChatListData[index]["id"],
    )
      ..contentTitle = timelineChatListData[index]["content"]
      ..userInformation = loadUserInformations(timelineChatListData[index]["user"])
      ..createdTime = timelineChatListData[index]["createdAt"]
      
    ;


    timelineChatDetailsList.add(timelineChatDetails);
  }


  return timelineChatDetailsList;
}
