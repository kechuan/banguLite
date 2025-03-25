import 'package:flutter/material.dart';

class UnVisibleResponse extends InkResponse {
  const UnVisibleResponse({
    super.key,
    super.containedInkWell,
    super.hoverDuration,
    super.onTap,
    super.onLongPress,
    super.onHover,
    super.child,
    
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap ?? (){}, //Active onTap Action: it don't anything but block the hitTest to the downfloor
      onHover: onHover,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,     // 悬浮时圆点
      highlightColor: Colors.transparent, // 点击时的圆点
      splashColor: Colors.transparent,    // 扩散水圈
      child: child,
    );

  }
}