
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/hive.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/internal/update_client.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
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
                ScalableText("Tag v${GithubRepository.version} => v${latestRelease.tagName}")
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
                      child: const ScalableText("(长按复制下载链接)"),
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

                              ScalableText("${(progress*100).toStringAsFixed(2)}%")
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
                        downloadApplication(latestRelease.assets![index].browserDownloadUrl,updateClient.progressNotifier);
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
                TextButton(onPressed: ()=>launchUrlString(GithubRepository.link), child: const ScalableText("浏览器打开")),
                TextButton(onPressed: ()=>Navigator.of(context).maybePop(), child: const ScalableText("下次再说"))
              ],
            ),
        
          ],
        ),
      ),
    );
                            
  }

  void downloadApplication(String? assestUrl, ValueNotifier<double> progressNotifier) async {
    if(assestUrl == null || MyHive.downloadDir == null) return;

    String storagePath = "${MyHive.downloadDir!.path}${Platform.pathSeparator}${assestUrl.split('/').last}";

    UpdateClient.getInstance().startDownload();

    await HttpApiClient.client.download(
      assestUrl,
      storagePath,
      onReceiveProgress:(count, total)=>progressNotifier.value = (count/total)
    ).then((_) async {

      UpdateClient.getInstance().finishDownload();
      if(MyHive.downloadDir?.uri != null){

        if(Platform.isAndroid){
          const fallbackIntent = AndroidIntent(
            action: 'android.intent.action.VIEW',
            type: 'resource/folder',
            package: 'com.android.documentsui',
          );
        
          await fallbackIntent.launch();
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