abstract class BaseInfo {
  BaseInfo({this.id});

  int? id = 0; // 通用ID字段
  
  // 工厂方法，创建空对象
  factory BaseInfo.empty() {
    throw UnimplementedError('BaseInfo.empty() must be implemented by subclasses');
  }
  
}