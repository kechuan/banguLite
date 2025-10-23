import 'package:bangu_lite/internal/bangumi_define/content_status_const.dart';
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';

/// 任意扩展 仿kt语法糖
extension ScopeFunctions<T> on T {
  /// 类似 Kotlin 的 let 函数
  /// 在对象上执行 [action] 并返回结果
  /// 对象作为参数传递给 [action]
  R? let<R>(R Function(T it) action) {
     
    return action.call(this);
  }
  
  /// 类似 Kotlin 的 also 函数
  /// 在对象上执行 [action] 并返回对象本身
  T also(void Function(T it) action) {
    action(this);
    return this;
  }
  
  /// 类似 Kotlin 的 run 函数 
  /// 在对象上执行 [action] 并返回结果
  R run<R>(R Function() action) {
    return action();
  }
  
  /// 类似 Kotlin 的 apply 函数
  /// 在对象的上下文中执行 [action] 并返回对象本身
  T apply(void Function() action) {
    action();
    return this;
  }

  bool takeCondition(bool Function(T) predicate) {
    return predicate(this);
  }


}

extension NumExtensions on num { 
  bool isInRange(num min, num max) {
    return this >= min && this <= max;
  }
}

extension IterableExtension on Iterable<num>{
	num sum(){
		num sum = 0;
		for(num i in this){
			sum += i;
		}
		return sum;
	}
}

extension ReportConvert on PostCommentType{

  ReportSubjectType convertReportReason(){
    switch(this){
      
      /// 不知道这个指的是不是 subjectComment 但是Web 没有举报入口 无法验证
      case PostCommentType.subjectComment:{
        return ReportSubjectType.subjectReply;
      }
        
      case PostCommentType.replyEpComment:{
        return ReportSubjectType.episodeReply;
      }
        
      case PostCommentType.postBlog:{
        return ReportSubjectType.blog;
      }
        
      case PostCommentType.replyBlog:{
        return ReportSubjectType.blogReply;
      }
        
      case PostCommentType.postTopic:{
        return ReportSubjectType.subjectTopic;
      }
      
      ///TODO 暂时无法 举报replyTopic
      case PostCommentType.replyTopic:{
        return ReportSubjectType.subjectReply;
      }
        
      case PostCommentType.postGroupTopic:{
        return ReportSubjectType.groupTopic;
      }
        
      case PostCommentType.replyGroupTopic:{
        return ReportSubjectType.groupReply;
      }
        
      case PostCommentType.postTimeline:{
        return ReportSubjectType.timeline;
      }
        
      case PostCommentType.replyTimeline:{
        return ReportSubjectType.timelineReply;
      }

      //default:{
      //  return ReportSubjectType.subjectReply;
      //}
        
    }
  
  }
}