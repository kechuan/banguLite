class BaseDetails {
  BaseDetails();

  int? detailID = 0; // 通用ID字段
  
  // 工厂方法，创建空对象
  factory BaseDetails.empty() {
    throw UnimplementedError('BaseInfo.empty() must be implemented by subclasses');
  }
}