import 'package:bangu_lite/internal/convert.dart';
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
    return Column(
      children: [
        
        AnimatedContainer(
          color: currentType == selectedType ? const Color(0xffd1e5f4)  : null,
          height: currentType == selectedType ? 30 : 40,
          width: currentType == selectedType ? 30 : 40,
          duration: const Duration(milliseconds: 150),
          curve: Curves.linear,
          child: InkResponse(
            containedInkWell: true,
            //focusColor: Colors.transparent,
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
            child: Text( labelText ?? "测试",style: const TextStyle(fontSize: 12)),
          ) : 
          const SizedBox.shrink(),
        ),
    
      ],
    );
  }
}