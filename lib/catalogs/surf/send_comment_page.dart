
import 'dart:async';
import 'dart:io';

import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/widgets/components/custom_bbcode_text.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/utils/extract.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/request_client.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/webview_model.dart';
import 'package:bangu_lite/widgets/dialogs/draft_content_preserve_dialog.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/views/sticker_select_view.dart';
import 'package:bangu_lite/widgets/views/text_style_select_view.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

@FFAutoImport()
import 'package:bangu_lite/internal/utils/const.dart';
@FFAutoImport()
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';



@FFRoute(name: '/sendComment')
class SendCommentPage extends StatefulWidget {
    const SendCommentPage({
        super.key,

        this.contentID,
        this.replyID,
        this.title,
        this.postCommentType,
        this.actionType,
        this.referenceObject,

        this.onSendMessage,
        this.preservationContent,
        this.themeColor,

    });

    final Function(String)? onSendMessage;

    //如果是 timeline 则应无需 id
    final dynamic contentID;
    final int? replyID;

    final PostCommentType? postCommentType;
    final UserContentActionType? actionType;

    final String? title;

    //有可能是创建 但也有可能是编辑回复
    //quote 标签 之类的东西
    final String? referenceObject; 

    //草稿箱/编辑回复 依赖字段
    final (String,String)? preservationContent;

    final Color? themeColor;

    @override
    State<SendCommentPage> createState() => _SendCommentPageState();
}

class _SendCommentPageState extends LifecycleState<SendCommentPage> {
    final ValueNotifier<bool> expandedToolKitNotifier = ValueNotifier(false);

    final TextEditingController titleEditingController = TextEditingController();
    final TextEditingController contentEditingController = TextEditingController();
    final TextEditingController hexColorEditingController = TextEditingController();

    final FocusNode textEditingFocus = FocusNode();

    final PageController toolkitPageController = PageController();
    final PageController stickerPageController = PageController();

    final ValueNotifier<bool> turnsTileTokenNotifier = ValueNotifier(false);

    Timer? resetTimer;

    @override 
    void onResume() {
        expandedToolKitNotifier.value = false;
        super.onResume();
    }

    @override
    void initState() {
        textEditingFocus.requestFocus();
        super.initState();
    }

    @override
    Widget build(BuildContext context) {

        debugPrint("[Enter SendCommentPage] id:${widget.contentID} type:${widget.postCommentType} replyTo:${widget.replyID}");

        final webviewModel = context.read<WebViewModel>();

        if (widget.preservationContent != null && contentEditingController.text.isEmpty) {
          titleEditingController.text = widget.preservationContent?.$1 ?? "";
          contentEditingController.text = widget.preservationContent?.$2 ?? "";
        }

        return Scaffold(
            appBar: AppBar(

                leading: IconButton(
                    onPressed: () {

                        if (
                          titleEditingController.text.isEmpty && contentEditingController.text.isEmpty || 
                          (titleEditingController.text,contentEditingController.text) == widget.preservationContent
                        ) {
                            Navigator.of(context).pop();
                        }

                        else {

                          showDraftContentPreserveDialog(
                            context,
                            widget.replyID ?? widget.contentID ?? 0,
                            title: titleEditingController.text,
                            content: contentEditingController.text,
                          );

                        }

                    },
                    icon: const Icon(Icons.arrow_back),
                ),
                backgroundColor: judgeCurrentThemeColor(context).withValues(alpha: 0.8),
                title: ScalableText(widget.title ?? '吐槽 ${widget.title}', style: const TextStyle(fontSize: 18)),
                actions: [

                    IconButton(
                        onPressed: () {
                            Navigator.of(context).pushNamed(
                                Routes.commentPreview,
                                arguments: {'renderText': contentEditingController.text}
                            );
                        },
                        icon: const Icon(Icons.remove_red_eye),
                    ),

                    const Padding(padding: PaddingH6),

                    IconButton(
                        onPressed: () {

                            //if (turnsTileTokenNotifier.value == false) {
                            //  fadeToaster(context: context, message: '请通过验证以发布内容');
                            //  return;
                            //}

                            if (
                              [
                                PostCommentType.postBlog,
                                PostCommentType.postTopic,
                                PostCommentType.postGroupTopic
                              ].contains(widget.postCommentType)
                            ) {

                              if(
                                titleEditingController.text.isEmpty ||
                                contentEditingController.text.isEmpty
                              ){
                                fadeToaster(context: context, message: '不允许发布空白内容');
                                return;
                              }

                              Navigator.of(context).pop((titleEditingController.text,contentEditingController.text));

                            }

                            else{

                              if(contentEditingController.text.isEmpty){
                                fadeToaster(context: context, message: '不允许发布空白内容');
                                return;
                              }
                              
                              Navigator.of(context).pop(contentEditingController.text);

                            }

                        },
                        icon: const Icon(Icons.send)
                    ),

                ],
            ),
            body: ValueListenableBuilder(
                valueListenable: expandedToolKitNotifier,
                builder: (_, expandedToolKitStatus, toolKit) {
                    return Padding(
                        padding: EdgeInsets.only(
                            bottom: !expandedToolKitNotifier.value ? MediaQuery.paddingOf(context).bottom : 0,
                        ),
                        child: toolKit!
                    );
                },
                child: Column(
                    children: [

                        widget.referenceObject != null ?

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                  padding: Padding16,
                                  child: EasyRefresh(
                                      child: ConstrainedBox(
                                          constraints: const BoxConstraints(maxHeight: 200),
                                          child: AdapterBBCodeText(
                                              data: '${widget.title?.split('回复').last} 说: ${widget.referenceObject}',
                                              stylesheet: appDefaultStyleSheet(context,richless: true)
                                  
                                          ),
                                      ),
                                  ),
                              ),
                            ) : const SizedBox.shrink(),

                        Expanded(
                            child: Stack(
                                children: [

                                    Padding(
                                        padding: Padding12,
                                        child: Column(
                                            spacing: 16,
                                            children: [

                                                if (
                                                  [
                                                    PostCommentType.postBlog,
                                                    PostCommentType.postTopic,
                                                    PostCommentType.postGroupTopic
                                                  ].contains(widget.postCommentType)

                                                ) ...[
                                                    TextField(
                                                        decoration: const InputDecoration(
                                                            labelText: '这里填可以引喷的标题',
                                                        ),
                                                        controller: titleEditingController,
                                                        maxLines: null,
                                                    ),
                                                ],

                                                Expanded(
                                                    child: TextField(		
                                                        focusNode: textEditingFocus,
                                                        maxLength: 2000,
                                                        controller: contentEditingController,
                                                        onTap: () async {
                                                            expandedToolKitNotifier.value = false;
                                                        },

                                                        textAlignVertical: TextAlignVertical.top,
                                                        buildCounter: (context, {required currentLength, required isFocused, required maxLength}) {
                                                            return Text("$currentLength/$maxLength");
                                                        },
                                                        decoration: InputDecoration(
                                                            hintText: '这里填可以引喷的内容',
                                                            hintStyle: TextStyle(color: judgeDarknessMode(context) ? Colors.white : Colors.black,),
                                                            border: const OutlineInputBorder(),
                                                        ),
                                                        expands: true,
                                                        maxLines: null,
                                                    ),
                                                ),

                                                Row(
                                                  spacing: 12,
                                                  children: [
                                                    const ScalableText("请通过发帖验证:"),

                                                    SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child: ValueListenableBuilder(
                                                        valueListenable: turnsTileTokenNotifier,
                                                        builder: (_,isEffect,child){
                                                          if(isEffect) return const Icon(Icons.done);
                                                      
                                                          return const CircularProgressIndicator(
                                                            strokeWidth: 4,
                                                          );
                                                        }
                                                      ),
                                                    )
                                                  ],
                                                ),

                                                Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: ValueListenableBuilder(
                                                      valueListenable: turnsTileTokenNotifier,
                                                      builder: (_,isEffect,webviewChild) {

                                                        //虽然我觉得不会真有人这么整 就当是一个兜底了
                                                        if(isEffect){
                                                          resetTimer ??= Timer(
                                                            const Duration(seconds: 300),(){
                                                              WidgetsBinding.instance.addPostFrameCallback((_){
                                                                turnsTileTokenNotifier.value = false;
                                                                resetTimer = null;
                                                              });
                                                            }
                                                          );
                                                        }

                                                        return AnimatedSize(
                                                            duration: const Duration(milliseconds: 300),
                                                            child: SizedBox(
                                                                //300,65 为原来 turnstile 大小
                                                                height: isEffect ? 0 : (65 + 20),
                                                                width: 300 + 20,
                                                                child: isEffect ? const SizedBox.shrink() : webviewChild!
                                                            ),
                                                        
                                                        );
                                                      },
                                                      child: InAppWebView(
                                                        webViewEnvironment: webviewModel.webViewEnvironment,
                                                        initialUrlRequest: URLRequest(url: WebUri(BangumiWebUrls.trunstileAuth())),
                                                        initialSettings: InAppWebViewSettings(
                                                            isInspectable: kDebugMode,
                                                            displayZoomControls: false,
                                                            useWideViewPort: true,
                                                            pageZoom: 2.0,
                                                            transparentBackground: true
                                                        ),
                                            
                                                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                                            
                                                            //似乎对Android 生效 对window难以拦截? window似乎并不会触发这个拦截
                                                            debugPrint("shouldOverrideUrlLoading url:${navigationAction.request.url}");
                                                            
                                            
                                                            if (navigationAction.request.url.toString().startsWith(APPInformationRepository.bangumiTurnstileCallbackUri.toString())) {
                                                                 
                                                              AccountModel.loginedUserInformations.turnsTileToken = navigationAction.request.url?.queryParameters["token"];

                                                              turnsTileTokenNotifier.value = true;
                                          
                                                              return NavigationActionPolicy.CANCEL;
                                                            }
                                                            return NavigationActionPolicy.ALLOW;
                                            
                                                        },
                                                        onWebViewCreated: (controller) {
                                                            AccountModel.loginedUserInformations.turnsTileToken = null;
                                                        },
                                            
                                                        onLoadStart: (controller, url) async {
                                                            if (url?.queryParameters["token"] != null) {
                                                                AccountModel.loginedUserInformations.turnsTileToken = url?.queryParameters["token"];
                                                                turnsTileTokenNotifier.value = true;
                                                            }
                                                        },
                                            
                                                        onLoadStop: (controller, url) async {
                                                            if (Platform.isAndroid) {
                                                                await controller.injectCSSCode(
                                                                  source: """
                                                                    body * { 
                                                                      font-size: 2em !important; 
                                                                      transform: scale(2);
                                                                      transform-origin: top left;
                                                                      color: #000 !important;
                                                                    }
                                                                    """
                                                                );
                                                            }
                                                        },
                                            
                                                        onReceivedError: (controller, request, error) {
                                                          if (request.url.toString().contains(APPInformationRepository.bangumiTurnstileCallbackUri.toString())) {
                                                            extractFallbackToken(controller).then((result) {
                                                              if (result != null) {
                                                                  AccountModel.loginedUserInformations.turnsTileToken = result;
                                                                  turnsTileTokenNotifier.value = true;
                                                              }
                                                            });
                                                          }
                                            
                                                        }
                                                      ),
                                                
                                                    ),
                                                ),

                                                //countText 预留位置
                                                const Padding(padding: PaddingV24)

                                            ],
                                        ),
                                    ),

                                    //工具栏
                                    ValueListenableBuilder(
                                        valueListenable: expandedToolKitNotifier,
                                        builder: (_, expandedStatus, toolKitWidget) {
                                            return AnimatedPositioned(
                                                height: 400,
                                                width: MediaQuery.sizeOf(context).width,
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.ease,
                                                bottom: expandedStatus ? MediaQuery.systemGestureInsetsOf(context).bottom : -350,
                                                child: toolKitWidget!,
                                            );
                                        },
                                        child: Listener(

                                            onPointerDown: (event) {

                                                if (!expandedToolKitNotifier.value) {
                                                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                                                }

                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  if (!textEditingFocus.hasFocus) {
                                                      textEditingFocus.requestFocus();
                                                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                                                  }
                                                });

                                            },
                                            child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                    color: judgeCurrentThemeColor(context).withValues(alpha: 0.6),
                                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16))
                                                ),
                                                child: Column(
                                                    children: [
                                                        SizedBox(
                                                            height: kToolbarHeight,
                                                            child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [

                                                                    IconButton(
                                                                        icon: const Row(
                                                                            spacing: 6,
                                                                            children: [
                                                                                Icon(Icons.emoji_emotions),
                                                                                ScalableText("贴纸表情")
                                                                            ],
                                                                        ),
                                                                        onPressed: () {
                                                                            expandedToolKitNotifier.value = true;
                                                                            toolkitPageController.animateToPage(
                                                                                0, 
                                                                                duration: const Duration(milliseconds: 300),
                                                                                curve: Curves.easeIn
                                                                            );
                                                                        },
                                                                    ),

                                                                    IconButton(
                                                                        icon: const Row(
                                                                            spacing: 6,
                                                                            children: [
                                                                                Icon(Icons.format_color_text),
                                                                                ScalableText("文字样式")
                                                                            ],
                                                                        ),
                                                                        onPressed: () {
                                                                            expandedToolKitNotifier.value = true;
                                                                            toolkitPageController.animateToPage(
                                                                                1, 
                                                                                duration: const Duration(milliseconds: 300),
                                                                                curve: Curves.easeIn
                                                                            );
                                                                        },
                                                                    ),

                                                                    IconButton(
                                                                        icon: const Icon(Icons.keyboard),
                                                                        onPressed: () {

                                                                            expandedToolKitNotifier.value = !expandedToolKitNotifier.value;

                                                                        },
                                                                    ),

                                                                ],
                                                            ),
                                                        ),

                                                        Divider(color: judgeDarknessMode(context) ? Colors.white : Colors.black, height: 1),

                                                        Expanded(
                                                            child: PageView(
                                                                controller: toolkitPageController,

                                                                children: [

                                                                    StickerSelectView(contentEditingController: contentEditingController),

                                                                    TextStyleSelectView(contentEditingController: contentEditingController),

                                                                ],
                                                            ),
                                                        )
                                                    ],
                                                ),
                                            ),
                                        ),

                                    )
                                ]
                            ),
                        ),

                    ],
                ),

            ),
        );
    }
}

