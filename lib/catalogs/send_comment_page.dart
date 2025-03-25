import 'package:bangu_lite/bangu_lite_routes.dart';
import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/internal/convert.dart';
import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/max_number_input_formatter.dart';
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

@FFRoute(name: '/TestPage')
class SendCommentPage extends StatefulWidget {
  const SendCommentPage({
    super.key,
    this.isReply = false,
    this.replyTitle,
    this.referenceObject = 'sth wrong!',
    this.preservationContent,
  });

  final bool isReply;
  final String? replyTitle;
  final String? referenceObject; //quote 标签 之类的东西
  final String? preservationContent;

  @override
  State<SendCommentPage> createState() => _SendCommentPageState();
}

class _SendCommentPageState extends State<SendCommentPage> {
  final ValueNotifier<bool> expandedToolKitNotifier = ValueNotifier(true);

  final TextEditingController titleEditingController = TextEditingController();
  final TextEditingController contentEditingController = TextEditingController();
  final TextEditingController hexColorEditingController = TextEditingController();

  final FocusNode textEditingFocus = FocusNode();
  final FocusNode toolKitFocus = FocusNode();

  final PageController toolkitPageController = PageController();
  final PageController stickerPageController = PageController();

  @override
  Widget build(BuildContext context) {

    if(widget.referenceObject!=null){
      contentEditingController.text = '[quote]${widget.referenceObject}[/quote]\n';
    }

    return Scaffold(
      appBar: AppBar(
        
        leading: IconButton(
          onPressed: () {

            showTransitionAlertDialog(
              context,
              title: "退出确认",
              content: "需要保留草稿纸吗? 内容会存留至退出详情页面之前",
              cancelText: "放弃修改",
              confirmText: "保留修改",
              cancelAction: () {
                //额外需要多 pop 一层
                Navigator.of(context).pop();
              },
              confirmAction: () {
                
              },
            );

            //Navigator.of(context).pop();

          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: judgeCurrentThemeColor(context).withValues(alpha: 0.8),
        title: widget.isReply ? 
          ScalableText('吐槽 ${widget.referenceObject}',style: const TextStyle(fontSize: 18)) : 
          ScalableText('回复 ${widget.referenceObject}',style: const TextStyle(fontSize: 18)) ,
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
            onPressed: () {},
            icon: const Icon(Icons.send),
          ),

        ],
      ),
      body: Stack(
        children: [
            Padding(
              padding: Padding12,
              child: Column(
                spacing: 16,
                children: [
                        
                  if (widget.isReply) ...[
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
						onTapOutside: (event) {
						  if(toolKitFocus.hasFocus){
							textEditingFocus.requestFocus();
						  }
						  else{
							textEditingFocus.unfocus();
						  }
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
                  height: 350,
                  width: MediaQuery.sizeOf(context).width,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                  bottom: expandedStatus ? 0 : -290,
                  child: toolKitWidget!
                );
              },
              child: Focus(
				focusNode: toolKitFocus,
				
				child: Listener(
					onPointerDown: (event) {

						toolKitFocus.requestFocus();

						WidgetsBinding.instance.addPostFrameCallback((_) {
							if(!textEditingFocus.hasFocus){
								textEditingFocus.requestFocus();
							}
							
							debugPrint("trigged onPointerDown: ${textEditingFocus.hasFocus} / ${toolKitFocus.hasFocus}");
						});
						
						

						

						//toolKitFocus.requestFocus();
						
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
										child: Builder(
											builder: (_) {
										
											return PageView(
												controller: toolkitPageController,
										
												children: [
										
																StickerSelectView(contentEditingController: contentEditingController),
										
																TextStyleSelectView(contentEditingController: contentEditingController),
																
										
												],
											);
											}
										),
									)
								],
							),
						),
					),
			),
                
            )
        ]
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
					child: PageView(
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
								onTap: () {
									contentEditingController.text += '(bgm${convertDigitNumString(index+1)})';
									
						
								},
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
							onTap: () {
								contentEditingController.text += '(bgm${convertDigitNumString(index+24)})';
							},
							child: Image.asset(
								'./assets/bangumiSticker/bgm${convertDigitNumString(index+24)}.gif',
								scale: 0.8,
							)
							);
						})
						),
					),
					
					],
					
					),
				),
			),

			DefaultTabController(
				length: 2,
				child: TabBar(
					onTap: (index) {stickerPageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);},
					tabs: const [
						Tab(text: 'bgm 01-24(dsm)'),
						Tab(text: 'bgm 25-125(Cinnamor)'),
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
						child: Padding(
							padding: PaddingH12,
							child: GridView(
								shrinkWrap: true,
								gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: MediaQuery.orientationOf(context) == Orientation.landscape ? 8 : 5
								),
								children: [
								//简单的包裹
									...List.generate(
									BBCodeTag.values.length,
									(index){
										return UnVisibleResponse(
											onTap: () {
												widget.contentEditingController.text += '[${BBCodeTag.values[index].name}][/${BBCodeTag.values[index].name}]';
												widget.contentEditingController.selection = TextSelection.fromPosition(
													TextPosition(offset: widget.contentEditingController.text.length - 3 - BBCodeTag.values[index].name.length)
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
										widget.contentEditingController.text += "[url='hyperLink']链接名称[/url]";
										widget.contentEditingController.selection = TextSelection(
											baseOffset: widget.contentEditingController.text.length - 3 - 'url'.length - '链接名称'.length,
  											extentOffset: widget.contentEditingController.text.length - 3 - 'url'.length
											
										);
										
										TextSelection.fromPosition(
											TextPosition(offset: widget.contentEditingController.text.length - 3 - 'url'.length)
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
										widget.contentEditingController.text += "[img][/img]";
										widget.contentEditingController.selection = TextSelection.fromPosition(
											TextPosition(offset: widget.contentEditingController.text.length - 3 - 'img'.length)
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