import 'dart:math';

import 'package:bangu_lite/internal/const.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class AnimatedSortSelector extends StatelessWidget {
  const AnimatedSortSelector({
    super.key,
    
    required this.currentType,
    required this.selectedType,

    this.labelText,
    this.labelIcon,

    this.onTap,
  });


  final SortType currentType;
  final SortType selectedType;

  final String? labelText;
  final IconData? labelIcon;
  
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffd1e5f4),
          brightness: Theme.of(context).brightness
        )
      ),
      child: Column(
        children: [
      
          //min(30,MediaQuery.sizeOf(context).width/20) - 10
          
          AnimatedContainer(
            //color: currentType == selectedType ? const Color(0xffd1e5f4) : null,
            color: currentType == selectedType ? Theme.of(context).brightness == Brightness.light ? const Color(0xffd1e5f4) : const Color.fromARGB(255,130,211,224)  : null,
            height: currentType == selectedType ? min(30,MediaQuery.sizeOf(context).width/20) : min(40,MediaQuery.sizeOf(context).width/20),
            width: currentType == selectedType ? min(30,MediaQuery.sizeOf(context).width/20) : min(40,MediaQuery.sizeOf(context).width/20),
            duration: const Duration(milliseconds: 150),
            curve: Curves.linear,
            child: InkResponse(
              containedInkWell: true,
              highlightColor: Colors.transparent,
              radius: 12,
              onTap: onTap ?? (){},
              child: LayoutBuilder(
                builder: (_,constraint) {
                  return Icon(
                    labelIcon ?? Icons.question_mark ,
                    size: constraint.maxHeight, 
                  );
                }
              ),
            ),
          ),
      
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: animation
                .drive(Tween<Offset>(begin: Offset.zero,end: const Offset(0, -0.3))),
                child: child,
              );
            },
            child: currentType == selectedType ? 
             Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ScalableText( labelText ?? "测试",style: const TextStyle(fontSize: 12)),
            ) : 
            const SizedBox.shrink(),
          ),
      
        ],
      ),
    );
  }
}