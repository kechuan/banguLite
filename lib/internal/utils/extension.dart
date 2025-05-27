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