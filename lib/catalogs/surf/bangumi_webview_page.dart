import 'dart:convert';

import 'package:bangu_lite/internal/utils/extract.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/webview_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

//预计用途: 查看外部图片之类的
@FFRoute(name: '/webview')
class BangumiWebviewPage extends StatefulWidget {
  const BangumiWebviewPage({
    super.key,
    required this.url,
    this.title,
    this.injectHTML,
    this.onTargetUrlReached,
  });

  final String url;
  final String? title;

  final String? injectHTML;
  
  final Function(String?)? onTargetUrlReached;

  @override
  State<BangumiWebviewPage> createState() => _BangumiWebviewPageState();
}

class _BangumiWebviewPageState extends LifecycleRouteState<BangumiWebviewPage> with RouteLifecycleMixin {
  
  PullToRefreshController? pullToRefreshController;
  

  final urlController = TextEditingController();
  ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  ValueNotifier<String> currentSurfingUrlNotifier = ValueNotifier("");
  ValueNotifier<String> currentSurfingTitleNotifier = ValueNotifier("");

  int wrongRedirectCount = 0;
  
  @override
  void initState() {
    super.initState();
    currentSurfingUrlNotifier.value = widget.url;
    currentSurfingTitleNotifier.value = widget.title ?? "";
  }



  @override
  Widget build(BuildContext context) {
	  final webviewModel = context.read<WebViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).pop();
          }, icon: const Icon(Icons.arrow_back)
        ),
        title: ValueListenableBuilder(
          valueListenable: currentSurfingTitleNotifier,
          builder: (_,title,__) {
            return Text(title,style: const TextStyle(fontSize: 16));
          }
        ),
        //actions: [

        //  IconButton(
        //    icon: const Icon(Icons.cookie),
        //    onPressed: () {
        //      //取样=>验证


        //    },
        //  ),
          
        //],
      ),
      body: SafeArea(
          child: Column(
          spacing: 6,
          children: [

            ValueListenableBuilder(
              valueListenable: currentSurfingUrlNotifier,
                builder: (_,surfingUrl,child) {
                urlController.text = surfingUrl;

                  return DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: judgeCurrentThemeColor(context)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      textAlign: TextAlign.center,
                      //虽然没有 align/center 来直接作用 输入文字 但好在有这种 textAlignVertical
                      textAlignVertical: const TextAlignVertical(y: -0.4),
                      readOnly: true,
                      controller: urlController,
                      keyboardType: TextInputType.url,
                      
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(MdiIcons.web),
                    
                        suffixIcon: ValueListenableBuilder(
                          valueListenable: progressNotifier,
                          builder: (_,progress,child) {
                            
                            if (progress == 0) {
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 3)
                              );
                            }
                            
                            return IconButton(
                              icon: progress < 1.0 ? const Icon(Icons.close,size: 24,) : const Icon(Icons.refresh,size: 24,),
                              onPressed: () {
                                if(progress < 1.0){
                                  webviewModel.webViewController?.stopLoading();
                                }
                            
                                else{
                                  webviewModel.webViewController?.reload();
                                }
                            
                                progressNotifier.value = 0;
                    
                              },
                            );
                    
                          }
                        ),
                        
                      ),
                      
                    ),
                  ),
                );
                
                },
              
            ),
            
            Expanded(
              child: Stack(
              children: [
                InAppWebView(
                  webViewEnvironment: webviewModel.webViewEnvironment,
                  initialUrlRequest: URLRequest(url: WebUri(currentSurfingUrlNotifier.value)),
                  initialSettings: InAppWebViewSettings(
                    isInspectable: kDebugMode,
                    userAgent: HttpApiClient.broswerHeader["User-Agent"],
                    useShouldInterceptRequest: true,
                  ),
                  pullToRefreshController: pullToRefreshController,
                  
                  onTitleChanged: (controller, title) {
                    currentSurfingTitleNotifier.value = title ?? "";
                  },
                  onWebViewCreated: (controller) {
                    webviewModel.webViewController = controller;
                  },
                  onLoadStart: (controller, url){
                    currentSurfingUrlNotifier.value = url.toString();
                  },
                  shouldInterceptRequest: (controller,request){
                    
                    if (request.url.toString().contains(BangumiWebUrls.trunstileAuth())) {
                      debugPrint("shouldInterceptRequest inject succ");
                      return Future.value(WebResourceResponse(data: utf8.encode(widget.injectHTML!)));
                    }
                    
                    return Future.value(null); // 其他请求正常处理
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                      resources: request.resources,
                      action: PermissionResponseAction.GRANT);
                  },
                  onConsoleMessage:(controller, consoleMessage) {
                    debugPrint("Console message: ${consoleMessage.message}");
                  },
                  //shouldOverrideUrlLoading: (controller, navigationAction) async {


                  //  var uri = navigationAction.request.url!;

                  //  if (!["http","https","file"].contains(uri.scheme)) {
                  //    if (await canLaunchUrl(uri)) {
                  //      await launchUrl(uri);
                  //      return NavigationActionPolicy.CANCEL;
                  //    }
                  //  }

                  //  return NavigationActionPolicy.ALLOW;
                  //},

                  onReceivedError: (controller, request, error) {
                    //fallbackAction may deal with Indicates that the connection was stopped.

                    if(widget.url.contains(BangumiWebUrls.trunstileAuth())){
                      debugPrint("error:${error.description}");

                      invokePop() => Navigator.of(context).pop();

                      Future.delayed(const Duration(seconds: 5), (){

                        extractFallbackToken(controller).then((result){
                          if(result != null){
                            AccountModel.loginedUserInformations.turnsTileToken = result;
                            invokePop();
                            controller.dispose();
                            
                          }

                          else{
                            if(wrongRedirectCount == 3){ 
                              invokePop();
                              controller.dispose();
                            }

                            controller.reload();
                            wrongRedirectCount+=1;
                          }
                          
                            
                        });

                          

                      });
                    }
                    
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    progressNotifier.value = progress / 100;

                  },

                ),

                ValueListenableBuilder(
                  valueListenable: progressNotifier,
                  builder: (_,progress,child){
                    return progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container();
                  }
                )
                  
                ],
              ),
            ),
            
          ]
        )
      )
	);
  }
}

//Future<String?> getCookie(String? targetUrl,{String? cookiesName = 'chii_sec_id'}) async {

//	String? cookieValue;

//	if(targetUrl == null || cookiesName == null) return '';

//	final cookieManager = CookieManager.instance();

//	await cookieManager.getCookies(url: WebUri(targetUrl)).then((cookiesList) {
//		cookiesList.any(
//			(currentCookie){
//				if(currentCookie.name == cookiesName){
//					debugPrint("$cookiesName:${currentCookie.value}");
//					cookieValue = currentCookie.value;
//					return true;
//				}

//				return false;
				
//			}
//		);

//	});

//	return cookieValue;
						
//}


