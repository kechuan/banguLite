import 'package:flutter/material.dart';

Widget fadeSizeTransition({
  required Widget child,
  required Animation<double> animation
}){
  return FadeTransition(
    opacity: animation,
    child: SizeTransition(
      sizeFactor: animation,
      axis: Axis.vertical,
      child: child,
    ),
    
  );
}