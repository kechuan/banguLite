extension SafeCallExtension<T> on Function(T?)?{
  void call({T? information}) async {
    if(this!=null){
      await this!(information);
    }
  }
}