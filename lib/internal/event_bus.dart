import 'dart:async';

class AppRouteEvent {
  const AppRouteEvent(this.link, {this.data});

  final String link;
  final Object? data;
}

class EventBus {
  EventBus.internal();

  static final EventBus singleton = EventBus.internal();

  factory EventBus() => singleton;

  final StreamController<AppRouteEvent> appRouteController =
    StreamController<AppRouteEvent>.broadcast();

  final StreamController<String> loginRouteController =
    StreamController<String>.broadcast();

  String? cachedLoginLink;

  StreamSubscription<AppRouteEvent> onAppRoute(
    void Function(AppRouteEvent event) listener,
  ) {
    return appRouteController.stream.listen(listener);
  }

  void emitAppRoute(String link, {Object? data}) {
    appRouteController.add(AppRouteEvent(link, data: data));
  }

  StreamSubscription<String> onLoginRoute(
    void Function(String link) listener,
  ) {
    final subscription = loginRouteController.stream.listen(listener);
    final pendingLink = cachedLoginLink;

    if (pendingLink != null) {
      cachedLoginLink = null;
      scheduleMicrotask(() => listener(pendingLink));
    }

    return subscription;
  }

  void emitLoginRoute(String link) {
    if (loginRouteController.hasListener) {
      loginRouteController.add(link);
    }

    else {
      cachedLoginLink = link;
    }
  }
}

final EventBus bus = EventBus();