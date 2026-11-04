import 'dart:ui';

import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class ImageNotAvailable extends StatelessWidget {
  final String? reason;

  const ImageNotAvailable({
    super.key,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: const Image(
            image: AssetImage("assets/icons/icon.png"),
          ),
        ),

        ScalableText(
          "Image Not Available\n${reason ?? ""}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            //fontSize: 12
          ),
        ),
      ],
    );
  }
}
