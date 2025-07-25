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

  //old format
  //RegistryValue protocolRegValue = const RegistryValue(
  //  'URL Protocol',
  //  RegistryValueType.string,
  //  '',
  //);

  RegistryValue protocolRegValue = const RegistryValue.string(
    'URL Protocol',
    '',
  );


  //old format
  String protocolCmdRegKey = 'shell\\open\\command';
  RegistryValue protocolCmdRegValue = RegistryValue.string(
    '',
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

Future<String> listenAPPLink() async {

  String listenUri = "";

  if(Platform.isWindows){
    await registerBGMLoginDeepLink();
  }


  AppLinks().uriLinkStream.listen((uri){
    listenUri = uri.toString();
    handleLink(uri); //开启监听

  });

  return listenUri;
}

bool handleLink(Uri uri) {

  debugPrint("listenAPPLink: $uri");

  if (
    uri.host == APPInformationRepository.bangumiOAuthCallbackUri.host && 
    uri.path == APPInformationRepository.bangumiOAuthCallbackUri.path
  ) {

    if(uri.queryParameters["client_id"] == APPInformationRepository.bangumiAPPID){
      bus.emit('LoginRoute', uri.toString());
      return true;
    }

  }

  if(
    uri.scheme == "bangulite" &&
    uri.host.startsWith('turnstile')
  ){
    AccountModel.loginedUserInformations.turnsTileToken = uri.queryParameters["token"];
  }

  return false;
}

