import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:bangu_lite/internal/event_bus.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:flutter/foundation.dart';
import 'package:win32_registry/win32_registry.dart';

Future<void> registerWindowDeepLink(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = 'Software\\Classes\\$scheme';
  RegistryValue protocolRegValue = const RegistryValue(
    'URL Protocol',
    RegistryValueType.string,
    '',
  );
  String protocolCmdRegKey = 'shell\\open\\command';
  RegistryValue protocolCmdRegValue = RegistryValue(
    '',
    RegistryValueType.string,
    '"$appPath" "%1"',
  );

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
}

Future<void> registerBGMLoginDeepLink() async {
  try {
    //疑问 注册了之后 是不是会让。。整个域名都能被响应???
    //await registerWindowDeepLink("bgm.tv");
    await registerWindowDeepLink("bangulite");
  } 
  
  catch (e) {
    // 注册失败会导致登录不可用
    debugPrint("register window deep link error:$e");
    
  }

  debugPrint("register windows bgm.tv deepLink success");
}

//bool firstLink = true;

void listenAPPLink() async{

  if(Platform.isWindows){
    await registerBGMLoginDeepLink();
  }

  debugPrint("listenAPPLink");

  AppLinks().uriLinkStream.listen((uri) async {
    handleLink(uri); //开启监听
  });
}

bool handleLink(Uri uri) {

  debugPrint("listenAPPLink: $uri");

  if (
    uri.host == APPInformationRepository.bangumiAuthCallbackUri.host && 
    uri.path == APPInformationRepository.bangumiAuthCallbackUri.path
  ) {

    if(uri.queryParameters["client_id"] == APPInformationRepository.bangumiAPPID){
      bus.emit('LoginRoute', uri.toString());
      return true;
    }

  }

  return false;
}

