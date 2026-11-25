import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:flutter/foundation.dart';
import 'package:win32_registry/win32_registry.dart';

Future<void> registerWindowDeepLink(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = 'Software\\Classes\\$scheme';

  RegistryValue protocolRegValue = const RegistryValue.string(
    'URL Protocol',
    '',
  );

  String protocolCmdRegKey = 'shell\\open\\command';
  RegistryValue protocolCmdRegValue = RegistryValue.string(
    '',
    '"$appPath" "%1"',
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  final cmdKey = regKey.createKey(protocolCmdRegKey);
  try {
    regKey.createValue(protocolRegValue);
    cmdKey.createValue(protocolCmdRegValue);
  } finally {
    cmdKey.close();
    regKey.close();
  }
}

Future<void> registerBGMLoginDeepLink() async {
  try {
    await registerWindowDeepLink("bangulite");
  } catch (e) {
    // 注册失败会导致登录不可用
    debugPrint("register window deep link error:$e");
  }

  debugPrint("register windows bgm.tv deepLink success");
}

Future<void> listenAPPLink() async {
  if (Platform.isWindows) {
    await registerBGMLoginDeepLink();
  }

  AppLinks().uriLinkStream.listen((uri) {
    handleLink(uri);
  });
}

bool handleLink(Uri uri) {
  debugPrint("listenAPPLink: $uri");

  if (uri.host == APPInformationRepository.bangumiOAuthCallbackUri.host &&
      uri.path == APPInformationRepository.bangumiOAuthCallbackUri.path) {
    if (uri.queryParameters["client_id"] == APPInformationRepository.bangumiAPPID) {
      bus.emitLoginRoute(uri.toString());
      return true;
    }
  }

  if (uri.scheme == "bangulite" && uri.host.startsWith('turnstile')) {
    AccountModel.loginedUserInformations.turnstileToken = uri.queryParameters["token"];
  }

  return false;
}
