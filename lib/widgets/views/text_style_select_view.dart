import 'package:bangu_lite/internal/custom_bbcode_tag.dart';
import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/max_number_input_formatter.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/internal/utils/convert.dart';
import 'package:bangu_lite/internal/utils/extension.dart';
import 'package:bangu_lite/widgets/components/color_palette.dart';
import 'package:bangu_lite/widgets/components/custom_bbcode_text.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:bangu_lite/widgets/fragments/unvisible_response.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bbcode/flutter_bbcode.dart';

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
                                            (index) {
                                                return UnVisibleResponse(
                                                    onTap: () {

                                                      insertTagContent(BBCodeTag.values[index].name);

                                                    },
                                                    child: GridTile(
                                                        footer: Center(
                                                            child: ScalableText('[${BBCodeTag.values[index].name}]',),
                                                        ),
                                                        child: Center(
                                                            child: AdapterBBCodeText(
                                                                data: '[${BBCodeTag.values[index].name}]${BBCodeTag.values[index].tagName}[/${BBCodeTag.values[index].name}]',

                                                                stylesheet: BBStylesheet(
                                                                    tags: allEffectTag.getRange(0, allEffectTag.length - 1).toList().also(
                                                                        (it) => it.add(CodeTag(tagName: 'codeExample'))
                                                                    ),
                                                                    defaultText: TextStyle(
                                                                        fontFamilyFallback: convertSystemFontFamily(),
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
                                            onTap: () {

                                              insertTagContent("url",tagContent: "hyperLink",selectionContent: "链接名称");

                                            },
                                            child: GridTile(
                                                footer: const Center(
                                                    child: ScalableText(
                                                        "[url='link']",
                                                    ),
                                                ),
                                                child: Center(
                                                    child: AbsorbPointer(
                                                        child: AdapterBBCodeText(
                                                          data: '[url=]超链接[/url]',
                                                          stylesheet: appDefaultBBStyleSheet(context)
                                                        ),
                                                    ),
                                                ),
                                            ),
                                        ),

                                        UnVisibleResponse(
                                            onTap: () {
                                               insertTagContent("img");
                                            },
                                            child: const GridTile(
                                                footer: Center(
                                                    child: ScalableText("[img]"),
                                                ),
                                                child: Center(
                                                    child: AbsorbPointer(
                                                        child: ScalableText('图片'),
                                                    ),
                                                ),
                                            ),
                                        ),

                                        UnVisibleResponse(
                                            onTap: () => widget.contentEditingController.text += "\n",
                                            child: const GridTile(
                                                footer: Center(child: ScalableText("enter")),
                                                child: Center(child: ScalableText('回车')),
                                            ),
                                        ),

                                    ]
                                ),
                            ),
                        ),
                    ),

                    Divider(color: judgeDarknessMode(context) ? Colors.white : Colors.black, height: 1),

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
                                                builder: (_, fontSize, child) {
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
                                                    scrollPhysics: const NeverScrollableScrollPhysics(),
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
                                                    onSelected: (value)=> fontSizeEditingController.text = value.toString(),
                                                    constraints: const BoxConstraints(maxHeight: 200),

                                                    itemBuilder: (_) {
                                                        return List.generate(
                                                            ScaleType.values.length, (index) {
                                                                return PopupMenuItem(
                                                                    height: 50,
                                                                    value: 12 + 2 * index,
                                                                    child: ScalableText("${(12 + 2 * index)} ${ScaleType.values[index].sacleName}"),
                                                                );
                                                            }
                                                        );
                                                    }
                                                ),
                                            ),

                                            IconButton(
                                                icon: const Icon(Icons.upload),
                                                onPressed: () {
                                                  insertTagContent("size",tagContent: (int.tryParse(fontSizeEditingController.text) ?? 16).clamp(8, 64).toString());
                                                },
                                            ),

                                        ],
                                    ),

                                    ValueListenableBuilder(
                                        valueListenable: hexColorEditingController,
                                        builder: (_, colorEditingValue, child) {

                                            Color selectedColor = Color(int.parse('0xFF${colorEditingValue.text}'));

                                            if (colorEditingValue.text.isEmpty && colorEditingValue.text.length < 6) {
                                                selectedColor = judgeCurrentThemeColor(context);
                                            }

                                            return Row(
                                                spacing: 12,
                                                children: [

                                                    ScalableText("文字颜色 #", style: TextStyle(
                                                      color: Color(selectedColor.value32bit))
                                                    ),

                                                    SizedBox(
                                                        width: 80,
                                                        child: TextField(
                                                            controller: hexColorEditingController,
                                                            scrollPhysics: const NeverScrollableScrollPhysics(),
                                                            textAlign: TextAlign.center,
                                                            decoration: const InputDecoration(
                                                                isDense: true, //相当于shrinkWrap
                                                            ),
                                                            inputFormatters: [
                                                                FilteringTextInputFormatter.allow(
                                                                    RegExp(r'^[0-9a-f]{1,6}$', caseSensitive: false),
                                                                )

                                                            ],

                                                        ),
                                                    ),

                                                    IconButton(
                                                        icon: const Icon(Icons.brush_outlined),
                                                        onPressed: () {

                                                            showModalBottomSheet(
                                                                backgroundColor: Colors.transparent,
                                                                constraints: BoxConstraints(
                                                                    maxWidth: MediaQuery.sizeOf(context).width,
                                                                    maxHeight: 500
                                                                ),
                                                                context: context,
                                                                builder: (_) => HSLColorPicker(selectedColor: selectedColor)
                                                            ).then((newColor) {
                                                                if (newColor != null && newColor is Color) {
                                                                    hexColorEditingController.value = TextEditingValue(text: newColor.hex);
                                                                }
                                                            });
                                                        }, 

                                                    ),

                                                    IconButton(
                                                        icon: const Icon(Icons.upload),
                                                        onPressed: () {
                                                          insertTagContent("color",tagContent: hexColorEditingController.text);
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


    void insertTagContent(
      String tag,
      {
        String? tagContent,
        String? selectionContent,

      }
    ){
      int currentPostion = widget.contentEditingController.selection.start;

      String resultPrefixTag = "";

      if(tagContent == null && selectionContent == null) {
        resultPrefixTag = "[$tag]";
      }

      else if(tagContent == null && selectionContent != null) {
        resultPrefixTag = "[$tag]$selectionContent";
      }

      else if(tagContent != null && selectionContent == null) {
        resultPrefixTag = "[$tag=$tagContent]";
      }

      else{
        resultPrefixTag = "[$tag=$tagContent]$selectionContent";
      }

      widget.contentEditingController.text = 
      convertInsertContent(
          originalText: widget.contentEditingController.text,
          insertText: "$resultPrefixTag[/$tag]",
          insertOffset: currentPostion
      );

      if(selectionContent == null){
        widget.contentEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: currentPostion + resultPrefixTag.length)
        );

      }

      else{
        widget.contentEditingController.selection = TextSelection(
          baseOffset: currentPostion + resultPrefixTag.length - selectionContent.length,
          extentOffset: currentPostion + resultPrefixTag.length
        );
      }


    }

}