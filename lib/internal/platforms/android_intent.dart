import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void noop(){}

Future<void> installApk(File downloadedApkFile,{Function() fallback = noop}) async {

  // 请求安装权限（Android 8.0+）
  if (await checkInstallPermission()) {
    await launchInstallIntent(downloadedApkFile);
  }

  else{
    //后备行为
    fallback();

  }

}

// 检查并请求安装未知来源权限
Future<bool> checkInstallPermission() async {
  
  if (Platform.isAndroid) {
    final status = await Permission.requestInstallPackages.status;
    if (!status.isGranted) {
      // 跳转到设置页
      final result = await Permission.requestInstallPackages.request();
      return result.isGranted;
    }
    return true;
  }

  return true;
}


// 生成适配不同 Android 版本的 Uri
Future<String> getApkContentProviderUri(File apkFile) async {

  if (Platform.isAndroid) {
    
      const authority = '${GithubRepository.packageName}.fileprovider';
      final filePath = apkFile.absolute.path;

      return 'content://$authority/external_files/downloads/${filePath.split('/downloads/').last}';
    
  }
  // Android 7.0 以下使用 file://
  return 'file://${apkFile.path}';
}

// 触发安装 Intent
Future<void> launchInstallIntent(File apkFile) async {
  String contentProviderPath = await getApkContentProviderUri(apkFile);

  debugPrint("contentProviderPath:$contentProviderPath");

  //content://io.flutter.banguLite.fileprovider/external_files/downloads/banguLite-arm64-v8a-v0.5.2-release.apk

  //content://io.flutter.banguLite.fileprovider/external_files/downloads/banguLite-arm64-v8a-v0.5.2-release.apk

  
  final intent = AndroidIntent(
    action: 'android.intent.action.INSTALL_PACKAGE',
    //action: ACTION_INSTALL_PACKAGE,
    data: contentProviderPath,
    flags: [
      Flag.FLAG_GRANT_READ_URI_PERMISSION,
      Flag.FLAG_ACTIVITY_NEW_TASK
    ],
  );
  try {
    await intent.launch();
  } 
  
  catch (e) {
    debugPrint('启动安装界面失败: $e');
  }
}
