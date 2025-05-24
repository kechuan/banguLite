
import 'dart:io';

import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/platforms/android_intent.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/update_client.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:dio/dio.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NewUpdateDialog extends StatelessWidget {
  const NewUpdateDialog({
    super.key,
    required this.latestRelease
  });

  final Release latestRelease;

  @override
  Widget build(BuildContext context) {

    final UpdateClient updateClient = UpdateClient.updateClient;
    final ValueNotifier<bool> expandedStatusNotifier = ValueNotifier<bool>(false);

    return Padding(
      padding: Padding16,
      child: EasyRefresh(
        child: Column(
          spacing: 12,
          children: [
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ScalableText("New Version"),
                ScalableText("Tag v${APPInformationRepository.version} => v${latestRelease.tagName}"),
              ],
            ),
        
            const ScalableText("GitHub源,下载前请确认当前网络状况通畅"),

            ValueListenableBuilder(
              valueListenable: updateClient.progressNotifier,
              builder: (_, progress, __) {
                return Stack(
                  children: [

                    Offstage(
                      offstage: updateClient.progressNotifier.value == 0,
                      child: Text("存储位置:${MyHive.downloadDir?.path}"),
                    ),

                    Offstage(
                      offstage: updateClient.progressNotifier.value != 0,
                      child: const ScalableText("(长按项目以复制下载链接)"),
                    ),
                  ],
                );
              },
            ),

            ValueListenableBuilder(
              valueListenable: updateClient.progressNotifier,
              builder: (_,progress,child) {
                return AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    height: progress != 0 ? 50 : 0,
                    
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [

                              Positioned.fill(
                                child: Offstage(
                                  offstage: progress == 1,
                                  child: LinearProgressIndicator(value: progress),
                                ),
                              ),

                              Offstage(
                                offstage: progress == 1,
                                child: ScalableText("${(progress*100).toStringAsFixed(2)}%"),
                              ),
                              
                            ],
                          ),
                        ),

                        const Padding(padding: PaddingH6),
                          
                        ScalableText("${updateClient.speedValue}/s")
                      ],
                    ),
                  ),
                );
              }
            ),

            ExpansionTile(
              initiallyExpanded: false,
              tilePadding: const EdgeInsets.all(0),
              title: const ScalableText("更新说明:"),
              shape: const Border(),
              onExpansionChanged:(infoCollapseStatus) => expandedStatusNotifier.value = infoCollapseStatus,
              children: [
                SizedBox(
                  height: 200,
                  child: ListView(
                    children: [
                      ScalableText("${latestRelease.body}")
                    ],
                  ),
                )
              ],
            ),

            Expanded(
              child: ListView.builder(
                itemCount: latestRelease.assets?.length ?? 0,
                itemBuilder: (_,index){
                  return ListTile(

                    onLongPress: () async {
                      Clipboard.setData(ClipboardData(text: latestRelease.assets![index].browserDownloadUrl ?? ""));
                      fadeToaster(context: context, message: "下载链接已复制剪切板");
                    },

                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 50,
                          width: MediaQuery.sizeOf(context).width*2/5,
                          child: ScalableText("${latestRelease.assets![index].name}",maxLines: 2,overflow: TextOverflow.ellipsis,)
                        ),
                        
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: (){
                        UpdateClient.getInstance().totalSize = latestRelease.assets![index].size ?? 0;
                        downloadApplication(
                          context,
                          latestRelease.assets![index].browserDownloadUrl,
                          updateClient.progressNotifier
                        );
                      },
                      icon: const Icon(Icons.download)
                    ),
                    subtitle: Row(
                      spacing: 3,
                      children: [
                        
                        Text(convertTypeSize(latestRelease.assets![index].size ?? 0),style: const TextStyle(fontSize: 12)),

                        Builder(
                          builder: (_) {
                            String currentAbiName = "";
                            AbiType.values.any(
                              (currentAbi){
                                if(latestRelease.assets![index].name?.contains(currentAbi.name) ?? false){
                                  currentAbiName = currentAbi.abiName;
                                  return true;
                                }
                                return false;
                              }
                            );

                            return Text("/ $currentAbiName",style: const TextStyle(fontSize: 12));
                           
                          }
                        )

                      ],
                    ),
                  );
                }
              ),
            ),
        
            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: ()=>launchUrlString(APPInformationRepository.link), child: const ScalableText("浏览器打开")),
                TextButton(onPressed: ()=>Navigator.of(context).maybePop(), child: const ScalableText("下次再说"))
              ],
            ),
        
          ],
        ),
      ),
    );
                            
  }

  void downloadApplication(
    BuildContext context,
    String? assestUrl,
    ValueNotifier<double> progressNotifier
  ) async {
    if(assestUrl == null || MyHive.downloadDir == null) return;

    invokeDialog() => showTransitionAlertDialog(
      context,
      title: "安装授权已取消",
      content: "如要安装应用 则需要授于本应用安装权限.或者自行在文件管理器安装",
      confirmAction: () async => await checkInstallPermission()
    );

    String storagePath = "${MyHive.downloadDir!.path}${Platform.pathSeparator}${assestUrl.split('/').last}";
    File downloadedFile = File(storagePath);
    bool fileExist = false;

    fileExist = await downloadedFile.exists();

    //hash when..
    if(fileExist){
      installApk(downloadedFile,fallback: invokeDialog);
    }

    else{
      UpdateClient.getInstance().startDownloadTimer();

      await HttpApiClient.client.download(
        assestUrl,
        storagePath,
        onReceiveProgress:(count, total)=>progressNotifier.value = (count/total)
      ).then((_) async {

        UpdateClient.getInstance().finishDownload();
        if(MyHive.downloadDir?.uri != null){

          if(Platform.isAndroid){
            installApk(downloadedFile);
          }

          else{
            if (await canLaunchUrl(MyHive.downloadDir!.uri)){
              launchUrl(MyHive.downloadDir!.uri);
            }
          }

        }

        
      }).catchError((dioException){
        //debugPrint(dioException);

        switch (dioException.type) {
          case DioExceptionType.badResponse: {
            debugPrint('链接不存在或拒绝访问'); 
            break;
          }
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout: {
            debugPrint('请求超时');
            break;
          }
        }
      });
    }


  }

}


