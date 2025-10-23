
import 'package:bangu_lite/internal/bangumi_define/bangumi_social_hub.dart';
import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:dio/dio.dart';



class HttpApiClient{
  static final client = Dio();
  static BaseOptions clientOption = BaseOptions(
    connectTimeout: const Duration(seconds: 5),
  );

  static Map<String,String> broswerHeader = {
    "User-Agent":'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0',
  };

  static Map<String,String> nonWebviewHeader = {
    "User-Agent":'Mozilla/5.0 (Linux; Android 13; 23049RAD8C Build/TKQ1.221114.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/128.0.6613.146 Mobile Safari/537.36'
  };

  static void init(){
    HttpApiClient.clientOption.baseUrl = BangumiAPIUrls.baseUrl;
    HttpApiClient.clientOption.headers = HttpApiClient.broswerHeader;
    HttpApiClient.client.options = HttpApiClient.clientOption;
  }




}

class BangumiAPIUrls {


  static Options bangumiAccessOption() => Options(
    headers: AccountModel.loginedUserInformations.accessToken != null ?
    BangumiQuerys.bearerTokenAccessQuery(AccountModel.loginedUserInformations.accessToken) :
    null
  );


  static const String baseUrl = "https://api.bgm.tv";
  static const String newUrl = "https://next.bgm.tv/p1";
  static const String baseResourceUrl = "https://lain.bgm.tv";

  static const String calendar = '$baseUrl/calendar';   

  static const String subject = '$baseUrl/v0/subjects';
  static const String eps = '$baseUrl/v0/episodes';
  static const String search = '$baseUrl/v0/search/subject';

  static const String bangumiSubjectSort = '$baseUrl/v0/search/subjects';

  //以v1为代表的新api

  //subject : GET/POST 通用 只要是只需求 subjectID 而非 需求具体的 sub-contentID 都能使用
  /// EP,Subject 划分 内容/评论 因此划分 comments 与 空
  /// Topic 则是单个一体 因此才会有 topics 这个字段

  //static String subject(int subjectID) => '${subjects()}/$subjectID';

  static String timeline() => '$newUrl/timeline';
  static String timelineReply(int timelineID) => '${timeline()}/$timelineID/replies';

  //基底
  static String subjects() => '$newUrl/subjects';
  static String topics() => '${subjects()}/-/topics';
  static String episodes() => '$newUrl/episodes';
  static String groups() => '$newUrl/groups';

  static String blogs() => '$newUrl/blogs';

  //Posts 则是 一个 用户管理它 在 subject 内发布的内容(collections之外)
  static String subjectPosts() => '${subjects()}/-/posts';
  static String groupPosts() => '${groups()}/-/posts';

  static String groupsTopics() => '${groups()}/-/topics';
  

  static String relations(int subjectID) => '${subjects()}/$subjectID/relations';
  static String reviews(int subjectID) => '${subjects()}/$subjectID/reviews';


  static String groupTopics(String groupName) => '${groups()}/$groupName/topics';
  static String groupTopic(int groupTopicID) => '${groupsTopics()}/$groupTopicID';


  static String ep(int epID) => '${episodes()}/$epID';
  static String topic(int subjectID) => '${subjects()}/$subjectID/topics';
  
  static String subjectComment(int subjectID) => '${subjects()}/$subjectID/comments';
  static String epComment(int epID) => '${episodes()}/$epID/comments';
  static String topicComment(int topicID) => '${topics()}/$topicID';
  static String groupTopicComment(int postID) => '${groupPosts()}/$postID';

  //surf information
  static String latestGroupTopics() => groupsTopics();
  static String latestSubjectTopics() => topics();

  //user
  static String me = '$newUrl/me';

  static String notify = '$newUrl/notify';
  static String clearNotify = '$newUrl/clear-notify';

  static String user(String username) => '$newUrl/users/$username';
  static String userSubjectComment(String username,int subjectID) => '$baseUrl/v0/users/$username/collections/$subjectID';

  static String userBlog(int blogID) => '${blogs()}/$blogID';
  static String userTimeline(String username) => '${user(username)}/timeline';
  
  
  static String blogComment(int blogID) => '${userBlog(blogID)}/comments';
  static String blogPhotos(int blogID) => '${userBlog(blogID)}/photos';

  //user-relation
  static String addBlockList(String username) => '$newUrl/blocklist/$username';
  static String removeBlockList(String username) => '$newUrl/blocklist/$username';
  static String addFriend(String username) => '$newUrl/friends/$username';
  static String removeFriend(String username) => '$newUrl/friends/$username';

  //comment-action put/delete 目前发评论 仅支持EP/topic内容
  
  /// 行为允许 POST blog目前API没有
  /// /p1/subjects/-/topics/{topicID}

  static String postEpComment(int epID) => epComment(epID);
  
  static String postTopic(int subjectID) => topic(subjectID);
  static String postTopicComment(int topicID) => '${topicComment(topicID)}/replies';

  static String postBlogComment(int subjectID) => '${userBlog(subjectID)}/comments';

  static String postGroupTopic(String groupName) => groupTopics(groupName);
  static String postGroupTopicComment(int postID) => '${actionGroupTopicComment(postID)}/replies';

  
  static String postTimeline() => timeline();
  static String postTimelineComment(int timelineID) => '${timeline()}/$timelineID/replies';
  
  
  /// 行为允许 PUT/PATCH
  static String actionSubjectComment(int subjectID) => '$newUrl/collections/subjects/$subjectID';

  /// 行为允许 GET/PUT/DELETE
  /// '${subjects()}/-/topics/$topicID';

  static String actionGroupTopicComment(int commentID) => '${groupsTopics()}/$commentID';
  static String actionTopicComment(int commentID) => '${subjectPosts()}/$commentID';
  static String actionEpComment(int commentID) => '${episodes()}/-/comments/$commentID';
  static String actiongroupTopicComment(int postID) => groupTopicComment(postID);
  
  ///这个不允许GET
  static String actionBlogComment(int commentID) => '${blogs()}/-/comments/$commentID';


  /// 行为允许 PUT/DELETE
  
  //static String toggleSubjectCommentLike(int commentID) => '${actionSubjectComment(commentID)}/like';
  static String toggleSubjectCommentLike(int commentID) => '${subjects()}/-/collects/$commentID/like';  
  static String toggleEPCommentLike(int commentID) => '${actionEpComment(commentID)}/like';
  static String toggleTopicLike(int commentID) => '${actionTopicComment(commentID)}/like';
  static String toggleGroupTopicLike(int commentID) => '${actiongroupTopicComment(commentID)}/like';

  ///[POST]
  static String report() => '$newUrl/report';


  //other
  static String imgurl(String imageSuffix) => '$baseResourceUrl/pic/photo/l/$imageSuffix';
  static String imgurlThumbnail(
    String imagePath,
    {
      int width = 0,
      int height = 0,
    }
  ) => '$baseResourceUrl/r/${width}x$height/$imagePath';


  
}

class BangumiWebUrls{
  static const String baseUrl = "https://bangumi.tv";
  static const String relativeUrl = "https://bgm.tv";

  static const String nextUrl = "https://next.bgm.tv";

  static String login() => '$baseUrl/login';

  static String subject(int subjectID) => '$baseUrl/subject/$subjectID';
  static String subjectComment(int subjectID) => '$baseUrl/subject/$subjectID/comments';
  static String subjectReviews(int subjectID) => '${subject(subjectID)}/reviews';
  static String subjectTopics(int subjectID) => '${subject(subjectID)}/board';

  static String subjectTopic(int topicID) => '$baseUrl/subject/topic/$topicID';

  //附带: https://bangumi.tv/index/77285/comments#post_86407
  static String indexComment(int indexID) => '$baseUrl/index/$indexID/comments';
  

  static String ep(int epID) => '$baseUrl/ep/$epID';
  static String user(String username) => '$baseUrl/user/$username';
  static String userTimeline(String username) => '${user(username)}/timeline';

  ///relationsUser 只是一个摆设 实际上只要 timelineID 正确就行...
  static String timelineReplies(String relationsUser,int timelineID) => '${userTimeline(relationsUser)}/status/$timelineID';

  //接受数字ID 与 name 作为参数
  static String group(dynamic groupName) => '$baseUrl/group/$groupName';
  static String groupTopic(int postID) => '$baseUrl/group/topic/$postID';

  static String userBlog(int blogID) => '$baseUrl/blog/$blogID';

  static String relativeSubject(int subjectID) => '$relativeUrl/subject/$subjectID';
  static String relativeSubjectComment(int subjectID) => '$relativeUrl/subject/$subjectID/comments';
  static String relativeSubjectReviews(int subjectID) => '${relativeSubject(subjectID)}/reviews';
  static String relativeSubjectTopic(int topicID) => '$relativeUrl/subject/topic/$topicID';

  static String relativeEp(int epID) => '$relativeUrl/ep/$epID';
  static String relativeGroupTopic(int postID) => '$relativeUrl/group/topic/$postID';

  static String relativeBlog(int blogID) => '$relativeUrl/blog/$blogID';
  static String relativeGroup(dynamic groupName) => '$relativeUrl/group/$groupName';

  static String person(int personID) => '$baseUrl/person/$personID';
  static String character(int characterID) => '$baseUrl/character/$characterID';
  

  //Auth Area

  static String webAuthPage(){
    final entries =  BangumiQuerys.authorizationQuery().entries;
        
    final authParams = 
      entries.map((entry) =>'${entry.key}=${entry.value}')
      .toList()
      .join('&');

    return '${BangumiWebUrls.oAuth}?$authParams';
  }


  static const String oAuth = '$relativeUrl/oauth/authorize';
  static const String oAuthToken = '$relativeUrl/oauth/access_token';

  static String trunstileAuth() => '$nextUrl/p1/turnstile?redirect_uri=${APPInformationRepository.bangumiTurnstileCallbackUri.toString()}';

}

class BangumiQuerys {

	static Map<String,String> authorizationQuery() => {
		"client_id":APPInformationRepository.bangumiAPPID,
		"response_type":"code",
		"chii_referer":APPInformationRepository.bangumiOAuthCallbackUri.toString(),
		"client_secret":APPInformationRepository.bangumiAPPSecret,
	};

  static Map<String,String> getAccessTokenQuery(
		String code,
	) => {
		"grant_type":'authorization_code',
		"client_id":APPInformationRepository.bangumiAPPID,
		"client_secret":APPInformationRepository.bangumiAPPSecret,
		"code":code,
		"redirect_uri":'banguLite://oauth/bgm_login?client_id=bgm369067d8f39dea8d4',
		"accept": "application/json"
	};

	static Map<String,String> bearerTokenAccessQuery(String? accessToken) => {
		"Authorization": 'Bearer $accessToken',
		"accept": "application/json"
	};

	static Map<String,String> refreshTokenQuery(String refreshToken) => {
		"grant_type": 'refresh_token',
		"client_id":APPInformationRepository.bangumiAPPID,
		"client_secret":APPInformationRepository.bangumiAPPSecret,
		"refresh_token":refreshToken,
		"redirect_uri":'banguLite://oauth/bgm_login?client_id=bgm369067d8f39dea8d4',
		
		
		"accept": "application/json",
	};

	static Map<String,dynamic> searchQuery = {
		"type":2,
		"responseGroup":"small",
		"start":0,
		"max_results":10
	};

  static Map<String,dynamic> subjectCommentQuery({
    String? content,
    int rate = 0,
    StarType starType = StarType.want,
    bool isPrivate = false,
    List<String>? tagList
  }){
    return {
      "comment": "$content",
      "type": starType.starTypeIndex,
      "rate": rate,
      "private": isPrivate,
      "progress": true,
      "tags": tagList ?? [],
    };
  }

  static Map<String,dynamic> groupsQuery({
    String? modeName,
    String? sort,
		int? limit,
		int? offset
  }) => {
		"mode": modeName ?? "all",
		"limit": limit ?? 20,
		"offset": offset ?? 0,
    "sort": sort ?? "members"
	};
  
    // posts/topics/members/created/updated
    
  

  static Map<String,dynamic> groupsTopicsQuery({
		BangumiSurfGroupType? mode,
		int? limit,
		int? offset
	}) => {
		"mode": mode?.name ?? "all",
		"limit": limit ?? 20,
		"offset": offset ?? 0
	};

	static Map<String,dynamic> postQuery({
		String? content,
		String? title,
		String? turnstileToken
	}) => {
		"title": title,
		"content": content,
		"turnstileToken": turnstileToken
	};

	static Map<String,dynamic> replyQuery({
		String? content,
		int? replyTo,
		String? turnstileToken,
	}) => {
		"content": content,
		"replyTo": replyTo,
		"turnstileToken": turnstileToken
	};

	static Map<String,dynamic> editQuery({
		String? title,
		String? content,
	}) => {
		"title": title ?? "",
		"content": content,
	};

  static Map<String,dynamic> notificationsQuery({
		int? limit,
		//bool? unread,
	}) => {
		"limit": limit ?? 20,
		//"unread": unread
	};

  static Map<String,dynamic> clearNotificationsQuery({
		List<int>? notificationIDList
	}) => {
		"id": notificationIDList ?? []
	};

  static Map<String,dynamic> timelineQuery({
    int? limit,
    int? until,
    BangumiTimelineSortType? mode
  }) {

    Map<String,dynamic> defaultQuery = {
      "limit":limit ?? 20,
      "mode": mode ?? "all",
    };

    if(mode != null){
      defaultQuery["mode"] = mode.name;
    }

    return defaultQuery;

  }

  ///Detail: [ReportSubjectType]/[ReportReasonType]
  static Map<String,dynamic> reportQuery(
    {
      required int reportID,
      required int reportType,
      required int reportValue,
      String? comment
    }
  ) {
    return {
      "id":reportID,
      "type":reportType,
      "value":reportValue,
      "comment":comment ?? "",
    };
  }

  static Map<String,int>  commentAccessQuery = {"limit":10,"offset":0},
                          sortQuery = {"limit":10,"offset":0},
                          topicsQuery = {"limit":30,"offset":0},
                          epQuery = {"subject_id":0,"limit":100,"offset":0},
                          relationsQuery = {"type":2,"limit":20,"offset":0},
                          reviewsQuery = {"limit":20,"offset":0},
                          groupTopicQuery = {"limit":20,"offset":0}
                          //until字段 timelineID count Down 如目标为 998 那么 就要从 999 开始搜寻
                          
  ;
                             

  
}

class BangumiDatas {

  //神奇的数据装载。。 rank方面的数据 还不如拆分成 minRank & maxRank 。。
  static Map<String,dynamic> get sortData => {
    "keyword": '',
    "sort": 'rank',
    "filter": {
      "type": [2],
      "tag": [],
      "rank": [">2", "<=99999"],
      "air_date": [">=${DateTime.now().year}-01-01","<${DateTime.now().toString().substring(0,10)}"],
      "rating": [">=5","<9"],
      "nsfw": false,
    }
  };
}

class APPInformationRepository{
  static const String link = "https://github.com/kechuan/banguLite/releases",
                      projectName = "banguLite",
                      packageName = "io.flutter.banguLite",
                      version = "0.9.12",
                      author = "kechuan"
  ;

  //纯本地应用  
  static const String bangumiAPPID = 'bgm369067d8f39dea8d4';
  static const String bangumiAPPSecret = 'e34be838faee529cb7df1bad76a66db3';

  static final Uri bangumiOAuthCallbackUri = Uri.parse('bangulite://oauth/bgm_login?client_id=$bangumiAPPID');
  static final Uri bangumiTurnstileCallbackUri = Uri.parse('bangulite://turnstile/callback');

}



void downloadSticker({bool isOldType = true}) async {
  
  if(isOldType){
      String authorPath = "";

      await Future.wait(
        List.generate(
          126, (index){

            if(index == 0) return Future((){});

            String suffix = "gif"; 
            
            if(index < 24){
              authorPath = "01-23 dsm";
              suffix = "png";
              if(index == 11 || index == 23) suffix = "gif";
            }

            authorPath = "24-125 Cinnamor";

            return HttpApiClient.client.download(
              "https://bgm.tv/img/smiles/${index > 23 ? "tv" : "bgm"}/${convertDigitNumString(index > 23 ? index-23 : index)}.$suffix",
              './assets/bangumiSticker/$authorPath/bgm${convertDigitNumString(index)}.gif',
            );
          
          }
        )
      );

  }

  else{
    await Future.wait(
        List.generate(
          39, (index){
            return HttpApiClient.client.download(
              "https://bgm.tv/img/smiles/tv_vs/bgm_${convertDigitNumString(index+200)}.png",
              './assets/bangumiSticker/200-238 神戶小鳥/bgm${convertDigitNumString(index+200)}.gif',
            );
          
          }
        )
      );
  }

}
