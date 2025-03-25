import 'dart:io';

import 'package:bangu_lite/internal/bus_register_method.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Lifecycle {
  const Lifecycle._();

  static RouteObserver lifecycleRouteObserver = RouteObserver();
}

//all
abstract class LifecycleState<T extends StatefulWidget> extends State<T>
    with RouteAware, WidgetsBindingObserver {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Lifecycle.lifecycleRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  @mustCallSuper
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        onPause();
    }
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  @mustCallSuper
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Lifecycle.lifecycleRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  @mustCallSuper
  void didPush() {
    super.didPush();
    onResume();
  }

  @override
  @mustCallSuper
  void didPopNext() {
    super.didPopNext();
    onResume();
  }

  @override
  @mustCallSuper
  void didPop() {
    super.didPop();
    onPause();
  }

  @override
  @mustCallSuper
  void didPushNext() {
    super.didPushNext();
    onPause();
  }

  void onPause() {}

  void onResume() {}
}

//For Route only
abstract class LifecycleRouteState<T extends StatefulWidget> extends State<T>
    with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Lifecycle.lifecycleRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  @mustCallSuper
  void dispose() {
    Lifecycle.lifecycleRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  @mustCallSuper
  void didPush() {
    super.didPush();
    onResume();
  }

  @override
  @mustCallSuper
  void didPopNext() {
    super.didPopNext();
    onResume();
  }

  @override
  @mustCallSuper
  void didPop() {
    super.didPop();
    onPause();
  }

  @override
  @mustCallSuper
  void didPushNext() {
    super.didPushNext();
    onPause();
  }

  void onPause() {}

  void onResume() {}
}

//For System only
abstract class LifecycleAppState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  @override
  @mustCallSuper
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        onPause();
    }
  }

  @override
  @mustCallSuper
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  @mustCallSuper
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void onPause() {}

  void onResume() {}
}

mixin RouteLifecycleMixin<T extends StatefulWidget> on LifecycleRouteState<T> {

  // 在极端状况之下 说不定会出现 多个 route 同时的监听一起被响应
  // 比如 (BangumiDetailPageA)EpPage => BangumiDetailPageB => EpPageB...
  // 此时 整个路由链存活的 EpPageState 都会触发这个 AppRoute  
  // 那就麻烦了, 因此需要加以管控 加个状态量

  // 而且需要多个State 都能被统一封装
  // 那就只能是 mixin 引入了

  //bool isActived = true;

  //@override
  //void initState() {
  //  bus.on('AppRoute', (link) {
  //    if (!isActived) return;
  //    if (!mounted) return;
  //    appRouteMethodListener(context, link);
  //  });
  //  super.initState();
  //}

 

}


Future<void> exitApp() async {
  await SystemNavigator.pop(animated: true);
  exit(0);
}
