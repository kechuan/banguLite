import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:flutter/material.dart';

class ErrorLoadPrompt extends StatelessWidget {
  const ErrorLoadPrompt({
    super.key,
    this.message,
    this.onRetryAction,

  });

  final Object? message;
  final Function()? onRetryAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      mainAxisAlignment: MainAxisAlignment.center,
      
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            const Icon(Icons.warning_amber_outlined),
            ScalableText("$message"),
          ],
        ),
        
        TextButton(
          onPressed: onRetryAction, 
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: [
              Icon(Icons.refresh_outlined),
              ScalableText("重试",style: TextStyle(fontSize: 16))
            ],
          )
        )
      ],
    );
  }
}