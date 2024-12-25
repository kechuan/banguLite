import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

//void customToaster({required BuildContext context,required String message}){

//  ScaffoldMessenger.of(context).showMaterialBanner(
//   const MaterialBanner(content: Text("test"), actions: [const SizedBox.shrink()])
    
//  );

//}

void fadeToaster({required BuildContext context,required String message}){

  showToastWidget(
    //duration: const Duration(milliseconds: 200),
    animDuration: const Duration(milliseconds: 200),
    animation: StyledToastAnimation.slideFromBottomFade,
    reverseAnimation: StyledToastAnimation.slideToBottomFade,
    SizedBox(
      height: 50,
      width: 350,
      
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16)
        ),
        child: Center(child: Text(message,style: const TextStyle(fontSize: 16,color: Colors.white))),
      ),
    ),
    context: context,
    
  );

}