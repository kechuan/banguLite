// GENERATED CODE - DO NOT MODIFY MANUALLY
// **************************************************************************
// Auto generated by https://github.com/fluttercandies/ff_annotation_route
// **************************************************************************
// fast mode: true
// version: 10.1.0
// **************************************************************************
// ignore_for_file: prefer_const_literals_to_create_immutables,unused_local_variable,unused_import,unnecessary_import,unused_shown_name,implementation_imports,duplicate_import,library_private_types_in_public_api
/// The routeNames auto generated by https://github.com/fluttercandies/ff_annotation_route
const List<String> routeNames = <String>[
  '/Blog',
  '/index',
  '/moreReviews',
  '/moreTopics',
  '/photoView',
  '/subjectComment',
  '/subjectDetail',
  '/subjectEp',
  '/subjectTopic',
  'about',
  'settings',
];

/// The routes auto generated by https://github.com/fluttercandies/ff_annotation_route
class Routes {
  const Routes._();

  /// '/Blog'
  ///
  /// [name] : '/Blog'
  ///
  /// [constructors] :
  ///
  /// BangumiBlogPage : [ReviewModel(required) reviewModel, ReviewInfo(required) reviewInfo]
  static const String blog = '/Blog';

  /// '/index'
  ///
  /// [name] : '/index'
  static const String index = '/index';

  /// '/moreReviews'
  ///
  /// [name] : '/moreReviews'
  ///
  /// [constructors] :
  ///
  /// MoreReviewsPage : [ReviewModel(required) reviewModel, Color? bangumiThemeColor, String? title]
  static const String moreReviews = '/moreReviews';

  /// '/moreTopics'
  ///
  /// [name] : '/moreTopics'
  ///
  /// [constructors] :
  ///
  /// MoreTopicsPage : [TopicModel(required) topicModel, Color? bangumiThemeColor, String? title]
  static const String moreTopics = '/moreTopics';

  /// '/photoView'
  ///
  /// [name] : '/photoView'
  ///
  /// [constructors] :
  ///
  /// BangumiPictureViewPage : [ImageProvider(required) imageProvider]
  static const String photoView = '/photoView';

  /// '/subjectComment'
  ///
  /// [name] : '/subjectComment'
  ///
  /// [constructors] :
  ///
  /// BangumiCommentPage : [CommentModel(required) commentModel, int(required) subjectID, Color? bangumiThemeColor, String? name]
  static const String subjectComment = '/subjectComment';

  /// '/subjectDetail'
  ///
  /// [name] : '/subjectDetail'
  ///
  /// [constructors] :
  ///
  /// BangumiDetailPage : [int(required) subjectID]
  static const String subjectDetail = '/subjectDetail';

  /// '/subjectEp'
  ///
  /// [name] : '/subjectEp'
  ///
  /// [constructors] :
  ///
  /// BangumiEpPage : [EpModel(required) epModel, int(required) totalEps, Color? bangumiThemeColor]
  static const String subjectEp = '/subjectEp';

  /// '/subjectTopic'
  ///
  /// [name] : '/subjectTopic'
  ///
  /// [constructors] :
  ///
  /// BangumiTopicPage : [TopicModel(required) topicModel, TopicInfo(required) topicInfo]
  static const String subjectTopic = '/subjectTopic';

  /// 'about'
  ///
  /// [name] : 'about'
  static const String about = 'about';

  /// 'settings'
  ///
  /// [name] : 'settings'
  static const String settings = 'settings';
}
