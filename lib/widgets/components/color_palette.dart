import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class HSLColorPicker extends StatelessWidget {
  const HSLColorPicker({
    super.key,
    required this.selectedColor
  });

  final Color selectedColor;

  @override
  Widget build(BuildContext context) {

    ValueNotifier<Color> currentColorNotifier = ValueNotifier<Color>(selectedColor);


      return ValueListenableBuilder(
        valueListenable: currentColorNotifier,
        builder: (_, currentColor, child){

          return ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Scaffold(
              backgroundColor: currentColor.withValues(alpha: 0.8) ,
              body: child!
            ),
          );
          
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16)
          ),
          child: Column(
            children: [
          
              Padding(
                padding: Padding6,
                child: Row(
                  children: [
                    IconButton(onPressed: ()=>Navigator.of(context).maybePop(), icon: const Icon(Icons.arrow_back)),
                    const Spacer(),
                    ScalableText('选择主题色调',style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    TextButton(onPressed: ()=>Navigator.of(context).maybePop(currentColorNotifier.value), child: const ScalableText("保存")),
                  ],
                ),
              ),
          
              ValueListenableBuilder(
                valueListenable: currentColorNotifier,
                builder: (_,currentColor,child) {
                  
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 12,
                    children: [
                      
                      Container(
                        height: 50,
                        width: 50,
                        color: currentColor,
                      ),
                      SizedBox(
                        width: 250,
                        child: ScalableText(
                          "#${currentColor.hex}  RGB:(${currentColor.red8bit},${currentColor.green8bit},${currentColor.blue8bit})",
                          selectable: true,
                        ),
                      ),
                    ],
                  );
                }
              ),

              Flexible(
                child: SingleChildScrollView(
                  child: ColorPicker(
                        color: selectedColor,
                        padding: Padding12,
                        
                        pickerTypeLabels: const {
                          ColorPickerType.both: '主色调',
                          ColorPickerType.wheel: '自定义',
                        },
                        
                        pickersEnabled: const <ColorPickerType, bool>{
                          ColorPickerType.both: true,
                          ColorPickerType.primary: false,
                          ColorPickerType.accent: false,
                          ColorPickerType.bw: false,
                          ColorPickerType.wheel: true,
                        },
                        enableShadesSelection: false,
                        onColorChanged: (newColor) {
                          if (newColor == selectedColor) return;
                          currentColorNotifier.value = newColor;
                        },
                    ),
                ),
              ),
          

            ],
          ),
        ),
      );
  }
}
