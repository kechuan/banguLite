import 'package:bangu_lite/models/blog_details.dart';

class UserDetails {

  UserDetails();

  int? userID;
  String? userName;
  String? nickName;
  String? avatarUrl;
  String? sign;

  int? joinedAtTimeStamp;
  int? group;
  List<BlogDetails>? blogs;
  
}

class LoginedUserDetails extends UserDetails{
  LoginedUserDetails();

  String? accessToken;
  int? expiredTime;
  String? refreshToken;

}

LoginedUserDetails getDefaultLoginedUserDetails() => LoginedUserDetails();


UserDetails loadUserDetails(Map<String,dynamic> bangumiUserData){
  final userDetails = UserDetails();

  userDetails
    ..userID = bangumiUserData["id"]
    ..userName = bangumiUserData["username"]
    ..nickName = bangumiUserData["nickname"].isEmpty ? bangumiUserData["username"] : bangumiUserData["nickname"]
    ..avatarUrl = bangumiUserData["avatar"]["large"]
    ..sign = bangumiUserData["sign"]
    ..joinedAtTimeStamp = bangumiUserData["joinedAt"]
    ..group = bangumiUserData["group"]
  ;

  return userDetails;
}