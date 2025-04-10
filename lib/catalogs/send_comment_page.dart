import 'package:bangu_lite/bangu_lite_routes.dart';


import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/custom_toaster.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/lifecycle.dart';
import 'package:bangu_lite/internal/max_number_input_formatter.dart';
import 'package:bangu_lite/models/providers/account_model.dart';
import 'package:bangu_lite/models/providers/index_model.dart';
import 'package:bangu_lite/widgets/components/color_palette.dart';
import 'package:bangu_lite/widgets/dialogs/general_transition_dialog.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

@FFAutoImport()
import 'package:bangu_lite/internal/const.dart';
@FFAutoImport()
import 'package:bangu_lite/internal/bangumi_define/logined_user_action_const.dart';

import 'package:provider/provider.dart';

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
    this.preservationContent,

  });

  //如果是 timeline 则应无需 id
  final int? contentID;
  final int? replyID;

  final PostCommentType? postCommentType;
  final UserContentActionType? actionType;

  final String? title;

  //有可能是创建 但也有可能是编辑回复
  //quote 标签 之类的东西
  final String? referenceObject; 

  //草稿箱/编辑回复 依赖字段
  final String? preservationContent;


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

  final ValueNotifier<bool> isSendingNotifier = ValueNotifier(false);

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

    final indexModel = context.read<IndexModel>();
    final accountModel = context.read<AccountModel>();

    if(widget.preservationContent!=null && contentEditingController.text.isEmpty){
      contentEditingController.text = widget.preservationContent ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        
        leading: IconButton(
          onPressed: () {

			if(contentEditingController.text.isEmpty || contentEditingController.text == widget.preservationContent){
				 Navigator.of(context).pop();
			}

			else{
				showTransitionAlertDialog(
					context,
					title: "退出确认",
					content: "需要保留草稿纸吗? 编辑内容将会存留至退出APP之前",
					cancelText: "放弃修改",
					confirmText: "保留修改",
					cancelAction: () {
						//额外需要多 pop 一层
            indexModel.draftContent.addAll({
              widget.contentID ?? 0:{"":""}
            });

						Navigator.of(context).pop();
					},
					confirmAction: () {
            
            indexModel.draftContent.addAll({
              widget.contentID ?? 0:{
                titleEditingController.text.isEmpty ? "" : titleEditingController.text : contentEditingController.text
              }
            });

						Navigator.of(context).pop();
					},
				);

			}


          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: judgeCurrentThemeColor(context).withValues(alpha: 0.8),
        title: widget.actionType == UserContentActionType.edit ? 
          const ScalableText('编辑这段评论',style: TextStyle(fontSize: 18)) : 
		      ScalableText('吐槽 ${widget.title}',style: const TextStyle(fontSize: 18))
		    ,
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


          SizedBox(
            child: ValueListenableBuilder(
              valueListenable: isSendingNotifier,
              builder: (_,isSending,__){
            
                Widget showIcon = isSending ? 
                  const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(strokeWidth: 3)
                  ) : 
                  const Icon(Icons.send);
            
                return IconButton(
                  onPressed: () {
                    if(isSending) return;
                    if(contentEditingController.text.isEmpty){
                      fadeToaster(context: context, message: '不可发送空白内容');
                      return;
                    }
                
                    else{
                
                      debugPrint("id:${widget.contentID}/${widget.postCommentType}/${widget.actionType}");
                
                      invokeAsyncPopOut()=> Navigator.of(context).pop(contentEditingController.text);
            
                      isSendingNotifier.value = true;
            
                      accountModel.toggleComment(
                        commentID: widget.contentID,
                        commentContent: contentEditingController.text,
                        postCommentType: widget.postCommentType,
                        actionType : widget.actionType ?? UserContentActionType.post,
                        replyTo: widget.replyID ?? 0,
                        fallbackAction: (message){
                          fadeToaster(context: context, message: message,duration: const Duration(seconds: 5));
                        }
                      ).then((result){
                        if(result){
                          invokeAsyncPopOut();
                        }
            
                        isSendingNotifier.value = false;
                      });
                
                    }
                  },
                  icon: showIcon
                );
              
              }
              
            ),
          ),

        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: expandedToolKitNotifier,
            builder: (_,expandedToolKitStatus,toolKit) {
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

            Padding(
              padding: Padding16,
              child: Center(
              child: EasyRefresh(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: BBCodeText(
                    data: '[quote]${widget.referenceObject}[/quote]',
                    stylesheet: BBStylesheet(
                      tags: [AdapterQuoteTag()],
                      selectableText: true,
                      defaultText: const TextStyle(fontFamily: "MiSansFont")
                    ),
                  ),
                ),
              ),
              ),
            ): const SizedBox.shrink(),


            Expanded(
            child: Stack(
                  children: [
                  
                    Padding(
                    padding: Padding12,
                    child: Column(
                      spacing: 16,
                      children: [
                          
                      if (
                        widget.postCommentType == PostCommentType.postBlog ||
                        widget.postCommentType == PostCommentType.postTopic
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
                          focusNode:textEditingFocus,
                          maxLength: 2000,
                          controller: contentEditingController,
                          onTap: () async {
                            expandedToolKitNotifier.value = false;
                          },
                          
                          textAlignVertical: TextAlignVertical.top,
                          buildCounter: (context, {required currentLength, required isFocused, required maxLength}) {
                            return Text("$currentLength/$maxLength");
                          },
                          decoration:  InputDecoration(
                            hintText: '这里填可以引喷的内容',
                            hintStyle: TextStyle(color: judgeDarknessMode(context) ? Colors.white : Colors.black,),
                            border: const OutlineInputBorder(),
                          ),
                          expands : true,
                          maxLines: null,
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
                    builder: (_,expandedStatus,toolKitWidget) {
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

                        if(!expandedToolKitNotifier.value){
                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                        }
          
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if(!textEditingFocus.hasFocus){
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
                              
                              Divider(color: judgeDarknessMode(context) ? Colors.white : Colors.black,height: 1),
                              
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

class StickerSelectView extends StatelessWidget {
	StickerSelectView({
		super.key,
		required this.contentEditingController,
	});

	final TextEditingController contentEditingController;
	final PageController stickerPageController = PageController();

  @override
  Widget build(BuildContext context) {
	return Column(
		children: [

			Expanded(
				child: EasyRefresh(
					child: Builder(
					  builder: (_) {

						insertBgmSticker(int index){
							int currentPostion = contentEditingController.selection.start;
					    
							contentEditingController.text = 
								convertInsertContent(
									originalText: contentEditingController.text,
									insertText: '(bgm${convertDigitNumString(index+1)})',
									insertOffset:currentPostion
								);
							
							//(bgm01)=>(bgm1xx)
							contentEditingController.selection = TextSelection.fromPosition(
								TextPosition(offset: currentPostion + '(bgm)'.length + (index >= 100 ? 3 : 2) )
							);
						}

					    return PageView(
					    controller: stickerPageController,
					    children: [
					    	GridView(
					    		gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
					    			crossAxisCount: MediaQuery.orientationOf(context) == Orientation.landscape ? 16 : 8
					    		),
					    		children: List.generate(
					    		23,
					    		((index){
					    			return UnVisibleResponse(
					    			onTap: () => insertBgmSticker(index),
					    			child: Image.asset(
					    				'./assets/bangumiSticker/bgm${convertDigitNumString(index+1)}.gif',
					    				scale: 0.8,
					    			)
					    			);
					    		})
					    		),
					    	),
					    
					    	GridView(
					    
					    		gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
					    			crossAxisCount: MediaQuery.orientationOf(context) == Orientation.landscape ? 16 : 8
					    		),
					    		children: List.generate(
					    			102,
					    			((index){
					    			return UnVisibleResponse(
					    				onTap: () => insertBgmSticker(index+23),
					    				child: Image.asset(
					    					'./assets/bangumiSticker/bgm${convertDigitNumString(index+24)}.gif',
					    					scale: 0.8,
					    				)
					    		);
					    	})
					    	),
					    ),
					    
					    ],
					    
					    );
					  }
					),
				),
			),

			DefaultTabController(
				length: 2,
				child: TabBar(
					onTap: (index) {stickerPageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);},
					tabs: const [
						Tab(text: 'bgm 01-23(dsm)'),
						Tab(text: 'bgm 24-125(Cinnamor)'),
					]
				)
			)
		],
	);
  }
}

class TextStyleSelectView extends StatefulWidget {
	const TextStyleSelectView({
		super.key,
		required this.contentEditingController,
  	});

	final TextEditingController contentEditingController;
	

  @override
  State<TextStyleSelectView> createState() => _TextStyleSelectViewState();
}

class _TextStyleSelectViewState extends State<TextStyleSelectView> {

	final TextEditingController fontSizeEditingController = TextEditingController(text: "16");
	late final TextEditingController hexColorEditingController;

	@override
	void initState() {
		hexColorEditingController = TextEditingController(text: judgeCurrentThemeColor(context).hex);
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return EasyRefresh(
			child: Column(
				children: [

					Expanded(
						flex: 2,
						child: ColoredBox(
							color: judgeCurrentThemeColor(context).withValues(alpha: 0.33),
								child: Padding(
								padding: PaddingH12,
								child: GridView(
									shrinkWrap: true,
									gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
										crossAxisCount: MediaQuery.orientationOf(context) == Orientation.landscape ? 8 : 4
									),
									children: [
									//简单的包裹
										...List.generate(
										BBCodeTag.values.length,
										(index){
											return UnVisibleResponse(
												onTap: () {

													int currentPostion = widget.contentEditingController.selection.start;

													widget.contentEditingController.text = 
														convertInsertContent(
															originalText: widget.contentEditingController.text,
															insertText: '[${BBCodeTag.values[index].name}][/${BBCodeTag.values[index].name}]',
															insertOffset:currentPostion
														);
								
												
													widget.contentEditingController.selection = TextSelection.fromPosition(
														TextPosition(offset: currentPostion + 2 + BBCodeTag.values[index].name.length)
													);

												},
													child: GridTile(
													footer: Center(
														child: ScalableText(
															'[${BBCodeTag.values[index].name}]',
														),
													),
													child: Center(
														child: BBCodeText(
															data: '[${BBCodeTag.values[index].name}]${BBCodeTag.values[index].tagName}[/${BBCodeTag.values[index].name}]',
															
															stylesheet: BBStylesheet(
																tags: allEffectTag,
																defaultText: TextStyle(
																	fontFamily: 'MiSansFont',
																	color: judgeDarknessMode(context) ? Colors.white : Colors.black,
																)
															),
														),
													)
													),
												);
										}
								
									),
								
									//需携带参数的包裹
									//[url=test]链接描述[/url]
									UnVisibleResponse(
										onTap: (){
											int currentPostion = widget.contentEditingController.selection.start;

											widget.contentEditingController.text = 
												convertInsertContent(
													originalText: widget.contentEditingController.text,
													insertText: "[url='hyperLink']链接名称[/url]",
													insertOffset:currentPostion
												);
						

											widget.contentEditingController.selection = TextSelection(
												baseOffset: currentPostion + "[url='hyperLink']".length + '链接名称'.length,
												extentOffset: currentPostion +"[url='hyperLink']".length
											);
											
										},
										child: GridTile(
										footer: const Center(
											child: ScalableText(
												"[url='link']",
											),
										),
										child:Center(
											child: AbsorbPointer(
												child: BBCodeText(
												data: '[url=]超链接[/url]',
												stylesheet: BBStylesheet(
													tags: allEffectTag,
													defaultText: const TextStyle(fontFamily: 'MiSansFont')
												),
												),
											),
										),
										),
									),
								
									UnVisibleResponse(
										onTap: (){

											int currentPostion = widget.contentEditingController.selection.start;

											widget.contentEditingController.text = 
												convertInsertContent(
													originalText: widget.contentEditingController.text,
													insertText: "[img][/img]",
													insertOffset:currentPostion
												);
						

											widget.contentEditingController.selection = TextSelection.fromPosition(
												TextPosition(offset:currentPostion + "[img]".length)
											);

										},
										child: const GridTile(
										footer:  Center(
											child: ScalableText("[img]"),
										),
										child:Center(
											child: AbsorbPointer(
												child: ScalableText('图片'),
											),
										),
										),
									),
								
									UnVisibleResponse(
										onTap: ()=> widget.contentEditingController.text += "\n",
										child: const GridTile(
											footer: Center(child: ScalableText("enter")),
											child:Center(child: ScalableText('回车')),
										),
									),
								
								]
								),
								),
							),
					),

					Divider(color: judgeDarknessMode(context) ? Colors.white : Colors.black,height: 1),

					SizedBox(
						height: 150,
						child: Padding(
							padding: PaddingH12,
							child: Column(
							mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: [
						
								Row(
									spacing: 12,
									children: [
							
										ValueListenableBuilder(
											valueListenable: fontSizeEditingController,
											builder: (_,fontSize,child) {
												return ScalableText(
													"字号选择",
													style: TextStyle(
														fontSize: (double.tryParse(fontSizeEditingController.text) ?? 16).clamp(8, 64).toDouble()
													),
												);
											}
										),
							
										SizedBox(
											width: 50,
											child: TextField(
												
												controller: fontSizeEditingController,
												textAlign: TextAlign.center,
												decoration: const InputDecoration(
													isDense: true, //相当于shrinkWrap
												),
												
												inputFormatters: [
													FilteringTextInputFormatter.digitsOnly,
						
													ClampValueFormatter(
														minValue: 1,
														maxValue: 64,
													)
						
													
												],
												
											),
										),
							
										ConstrainedBox(
											constraints: const BoxConstraints(
												maxHeight: 24,
												maxWidth: 24,
											),
											child: PopupMenuButton(
												padding: const EdgeInsets.all(0),
												initialValue: 16,
												icon: const Icon(Icons.arrow_drop_down),
												onSelected: (value) => fontSizeEditingController.text = value.toString(),
												constraints: const BoxConstraints(maxHeight: 200),
							
												itemBuilder: (_){
													return List.generate(
														ScaleType.values.length, (index){
														return PopupMenuItem(
															height: 50,
															value: 12+2*index,
															child: ScalableText("${(12+2*index)} ${ScaleType.values[index].sacleName}"),
														);
														}
													);
												}
											),
										),
						
										IconButton(
											icon: const Icon(Icons.upload),
											onPressed: (){
												widget.contentEditingController.text += "[size=${(int.tryParse(fontSizeEditingController.text) ?? 16).clamp(8, 64)}][/size]";
											},
										),
											
									],
								),
							
								ValueListenableBuilder(
								valueListenable: hexColorEditingController,
								builder: (_,colorEditingValue,child) {
						
									Color selectedColor = Color(int.parse('0xFF${colorEditingValue.text}'));
						
									if(colorEditingValue.text.isEmpty && colorEditingValue.text.length < 6){
										selectedColor = judgeCurrentThemeColor(context);
									}
						
									return Row(
										spacing: 12,
										children: [
																
											ScalableText("文字颜色 #",style: TextStyle(
												color: Color(selectedColor.value32bit))
											),
																
											SizedBox(
												width: 80,
												child: TextField(
													controller: hexColorEditingController,
													textAlign: TextAlign.center,
													decoration: const InputDecoration(
														isDense: true, //相当于shrinkWrap
													),
													inputFormatters: [
														FilteringTextInputFormatter.allow(
															RegExp(r'^[0-9a-f]{1,6}$',caseSensitive: false),
														)
														
													],
													
												),
											),
																
											IconButton(
												icon: const Icon(Icons.brush_outlined),
												onPressed: (){
									
													//final Color color = Color(int.tryParse('0xFF${colorEditingValue.text}') ?? 0xFFFFFFFF);
						
													showModalBottomSheet(
														backgroundColor: Colors.transparent,
														constraints: BoxConstraints(
															maxWidth: MediaQuery.sizeOf(context).width,
															maxHeight: 500
														),
														context: context,
														builder: (_)=> HSLColorPicker(selectedColor:selectedColor)
													).then((newColor){
														if(newColor!=null && newColor is Color){
															hexColorEditingController.value = TextEditingValue(text: newColor.hex);
														}
													});
												}, 
												
											),
									
											IconButton(
												icon: const Icon(Icons.upload),
												onPressed: (){
													widget.contentEditingController.text += "[color=${hexColorEditingController.text}][/color]";
												},
											),
																
										],
									);
								
								}
								),
							],
						),
						),
					)
				],
			),
		);
	}
}