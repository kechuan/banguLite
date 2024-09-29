import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedWaveFooter extends StatefulWidget {
  const AnimatedWaveFooter({
    super.key,
    this.waveHeight,
    this.painter
  });

  final double? waveHeight;
  final Paint? painter;

  @override
  State<AnimatedWaveFooter> createState() => _AnimatedWaveFooterState();
}

class _AnimatedWaveFooterState extends State<AnimatedWaveFooter> with SingleTickerProviderStateMixin {

  late AnimationController waveController;

  @override
  void initState() {

    waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6)
    );

    waveController.repeat();
    super.initState();
  }


  @override
  void dispose() {
    waveController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: waveController,
      builder: (_, child) {
        return RepaintBoundary(
          child: CustomPaint(
            painter: WavePainter(
              offsetY: 30,
              waveHeight: widget.waveHeight ?? 30,
              wavePainter: widget.painter
                ?? 
                  Paint()
                    ..color = const Color.fromARGB(255, 222, 238, 252)
                    ..strokeWidth = 6
                    ..isAntiAlias = true
                    ..style = PaintingStyle.fill
              ,
              animationProgress: waveController.value,
            ),
            size: const Size.fromHeight(12),
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {

  WavePainter({
    
    required this.waveHeight,
    required this.wavePainter,
    this.animationProgress,
    this.offsetX,
    this.offsetY,

  });

  final double waveHeight;
  final Paint wavePainter;
  final double? animationProgress;

  final double? offsetX;
  final double? offsetY;

  static const double pi = 3.1415926;

  @override
  void paint(Canvas canvas, Size size) {

    Path wavePath = Path();
    Offset centerOffset = Offset(size.width / 2, waveHeight); //绘制位置


    double currentOffsetX = (offsetX ?? 0);

    double currentPharse = 0.0;

    //相位绘制法 对于缓和角度的采样精度 需求较低 所以32点采样一次
    for (currentOffsetX; currentOffsetX < size.width; currentOffsetX += 12) {

      //if(currentOffsetX%3 != 0 && currentOffsetX!=1) continue;

      currentPharse = 
        sin(
          (3*pi*currentOffsetX / size.width) //获取整个周期 offset内的相对相位位置 32/600 => 0.05什么的 代表频率
          + (animationProgress!*pi) //让整个周期的相位跟随着Animation移动起来 代表速度
        );

      wavePath.lineTo(
        currentOffsetX,
        centerOffset.dy +
          waveHeight * 
            (
              currentPharse > 0 ? -currentPharse : currentPharse
            ) //波峰翻倍
          - (offsetY ?? 0), //基础位移高度(负值代表上)
      );
      
    }

    //finally Linked 弥补最终的未到达的缺陷

    wavePath.lineTo(
      size.width,
      centerOffset.dy +
        //waveHeight * sin(2*pi * currentOffset / size.width + animationProgress! * pi * 4),
        waveHeight * sin(
          (4*pi*currentOffsetX / size.width) //获取整个周期 offset内的相对相位位置 32/600 => 0.05什么的
          + (animationProgress!*4*pi) //让整个周期的相位跟随着Animation移动起来
        )
        - (offsetY ?? 0), //基础位移高度(负值代表上)
    );


    wavePath.lineTo(size.width, waveHeight);  //闭合图形
    wavePath.lineTo(0, waveHeight); //闭合图形
    
    wavePath.close();




    canvas.drawPath(wavePath, wavePainter);



  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
