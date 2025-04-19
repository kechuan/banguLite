import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/models/social_details.dart';
import 'package:bangu_lite/models/timeline_details.dart';

class UserInformation {

  UserInformation({
    this.userID
  });

  int? userID;
  String? userName;
  String? nickName;
  String? avatarUrl;
  String? sign;

  int? joinedAtTimeStamp;
  int? group;

  String getName() => nickName ?? userName ?? '$userID';

  factory UserInformation.empty() => UserInformation(userID: 0);
  
}

class UserDetails{

	UserInformation? userInfomation;

	String? introduction;

	//site 字段 也会算在 这里面 计入为 home

	//UserInfo
	//Map? subjectStat;
	Map? subjectStat;
	List<SocialDetails>? socialAccounts;
	//Timeline
	List<TimelineDetails>? timelineActions;

	
}


class LoginedUserInformations{

  UserInformation? userInformation;

  String? accessToken;
  int? expiredTime;
  String? refreshToken;

  String? turnsTileToken;

}



UserInformation getDefaultUserInformations()=> UserInformation();
LoginedUserInformations getDefaultLoginedUserInformations() => LoginedUserInformations();


UserInformation loadUserInformations(Map<String,dynamic>? bangumiUserData){

  final userInformation = UserInformation.empty();

  if(bangumiUserData == null || bangumiUserData.isEmpty) return userInformation;

  userInformation
    ..userID = bangumiUserData["id"]
    ..userName = bangumiUserData["username"]
    ..nickName = bangumiUserData["nickname"].isEmpty ? bangumiUserData["username"] : bangumiUserData["nickname"]
    ..avatarUrl = bangumiUserData["avatar"]["large"]
    ..sign = bangumiUserData["sign"]
    ..joinedAtTimeStamp = bangumiUserData["joinedAt"]
    ..group = bangumiUserData["group"]
  ;
  
  return userInformation;
}


UserDetails loadUserDetails(
	Map<String,dynamic> bangumiUserDetailsData,
	{UserInformation? currentUserInformation}
){
	UserDetails userDetails = UserDetails();

	userDetails
		..userInfomation = currentUserInformation ?? loadUserInformations(bangumiUserDetailsData)
		..introduction = bangumiUserDetailsData["bio"]
		..socialAccounts = loadSocialDetails(bangumiUserDetailsData["networkServices"])
		..subjectStat = bangumiUserDetailsData["stats"]["subject"]
	;

	return userDetails;


}

List<dynamic> convertSubjectStat(
  Map? statData,
  {
    SubjectType subjectType = SubjectType.anime
  }
){

  if(statData == null) return List.filled(5, 0);

  return statData['${subjectType.subjectType}']?.values.toList()  ?? List.filled(5, 0);
}