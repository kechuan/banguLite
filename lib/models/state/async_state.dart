/// 显式异步加载状态机，替代用 `null` / `[]` / `*.empty()` 等哨兵值隐式表达状态的做法。
sealed class AsyncState<T> {
  const AsyncState();

  T? get dataOrNull => switch (this) {
    AsyncIdle<T>() => null,
    AsyncLoading<T>(: final previousData) => previousData,
    AsyncData<T>(: final data) => data,
    AsyncError<T>(: final previousData) => previousData,
  };

}

///划分一下 这里大部分实际上是test用到的
extension AsyncStateDisplay<T> on AsyncState<T>{
  bool get isIdle => this is AsyncIdle<T>;
  bool get isLoading => this is AsyncLoading<T>;
  bool get hasData => this is AsyncData<T>;
  bool get hasError => this is AsyncError<T>;

  String? get errorMessage => switch (this) {
    AsyncError<T>(: final message) => message,
    _ => null,
  };
}

final class AsyncIdle<T> extends AsyncState<T> {
  const AsyncIdle();
}

final class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading([this.previousData]);

  /// 刷新时保留旧数据，避免 UI 闪烁或在刷新失败后丢失已有内容
  final T? previousData;
}

final class AsyncData<T> extends AsyncState<T> {
  const AsyncData(this.data);

  final T data;
}

final class AsyncError<T> extends AsyncState<T> {
  const AsyncError(this.message, [this.previousData]);

  final String message;
  //理由一致
  final T? previousData;
}
