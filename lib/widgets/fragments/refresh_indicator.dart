import 'dart:math' as math;

import 'package:bangu_lite/internal/judge_condition.dart';
import 'package:bangu_lite/internal/utils/const.dart';
import 'package:bangu_lite/widgets/fragments/scalable_text.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'package:flutter/material.dart';

final iconsList = [
    Icons.refresh,
    
];

/// See [ProgressIndicator] _kMinCircularProgressIndicatorSize.
const double _kCircularProgressIndicatorSize = 48;

class TextIndicator extends StatefulWidget {
    //class TextIndicator extends _MaterialIndicator {

    /// Indicator properties and state.
    final IndicatorState state;

    /// See [ProgressIndicator.backgroundColor].
    final Color? backgroundColor;

    /// See [ProgressIndicator.color].
    final Color? color;

    /// See [ProgressIndicator.valueColor].
    final Animation<Color?>? valueColor;

    /// See [ProgressIndicator.semanticsLabel].
    final String? semanticsLabel;

    /// See [ProgressIndicator.semanticsLabel].
    final String? semanticsValue;

    /// Indicator disappears duration.
    /// When the mode is [IndicatorMode.processed].
    final Duration disappearDuration;

    /// True for up and left.
    /// False for down and right.
    final bool reverse;

    /// Icon when [IndicatorResult.noMore].
    final Widget? noMoreIcon;

    /// Show bezier background.
    final bool showBezierBackground;

    /// Bezier background color.
    /// See [BezierBackground.color].
    final Color? bezierBackgroundColor;

    /// Bezier background animation.
    /// See [BezierBackground.useAnimation].
    final bool bezierBackgroundAnimation;

    /// Bezier background bounce.
    /// See [BezierBackground.bounce].
    final bool bezierBackgroundBounce;

    const TextIndicator({
        super.key,
        required this.state,
        required this.disappearDuration,
        required this.reverse,
        this.backgroundColor,
        this.color,
        this.valueColor,
        this.semanticsLabel,
        this.semanticsValue,
        this.noMoreIcon,
        this.showBezierBackground = false,
        this.bezierBackgroundColor,
        this.bezierBackgroundAnimation = false,
        this.bezierBackgroundBounce = false,
    });

    @override
    State<TextIndicator> createState() => TextIndicatorState();
}

class TextIndicatorState extends State<TextIndicator> {

    IndicatorMode get _mode => widget.state.mode;
    IndicatorResult get _result => widget.state.result;

    Axis get _axis => widget.state.axis;

    double get _offset => widget.state.offset;

    double get _actualTriggerOffset => widget.state.actualTriggerOffset;

    /// Build [RefreshProgressIndicator].
    Widget _buildIndicator() {
        //debugPrint("_buildIndicator mode: $_mode value:$_value");
        if (_offset <= 0) {
            return const SizedBox();
        }

		String stateText = "";
		IconData stateIcon = Icons.abc;

		switch (_mode) {
            case IndicatorMode.drag : {
				stateText = widget.reverse ? "上拉加载获取更多内容" : "下拉刷新内容";
				stateIcon = Icons.refresh;
			}

            case IndicatorMode.armed :
            case IndicatorMode.ready : {
				stateText = widget.reverse ? "释放以加载" : "释放以刷新";
				stateIcon = Icons.refresh;
			}

            case IndicatorMode.processing : 
            case IndicatorMode.processed : {
				stateText = widget.reverse ? '获取中' : '刷新中';
				stateIcon = widget.reverse ? Icons.more_horiz : Icons.more_horiz;
			}

            case IndicatorMode.done : {
				stateText = widget.reverse ? "加载完成" : "刷新成功";
				stateIcon = Icons.done;
			}

           	default: {
				stateText = 'default Text';
			}

        }

        return Container(
            alignment: _axis == Axis.vertical
                ? (widget.reverse ? Alignment.topCenter : Alignment.bottomCenter)
                : (widget.reverse ? Alignment.centerLeft : Alignment.centerRight),
            height: _axis == Axis.vertical ? _actualTriggerOffset : double.infinity,
            width: _axis == Axis.horizontal ? _actualTriggerOffset : double.infinity,
            child: Container(
                decoration: BoxDecoration(
                    color: judgeCurrentThemeColor(context),
                    borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                    padding: Padding12,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 12,
                        children: [

                            _mode == IndicatorMode.drag ?
                                Transform.rotate(
                                    angle: math.max(0, _offset).clamp(0, 360).toDouble() * math.pi / 45,
                                    child: Icon(stateIcon)
                                ) :
                                Icon(stateIcon),

                            ScalableText(stateText),
                        ],
                    ),
                ),
            ),

        );
    }

    @override
    Widget build(BuildContext context) {
        double offset = _offset;
        if (widget.state.indicator.infiniteOffset != null &&
            widget.state.indicator.position == IndicatorPosition.locator &&
            (_mode != IndicatorMode.inactive ||
                _result == IndicatorResult.noMore)) {
            offset = _actualTriggerOffset;
        }
        final padding = math.max(_offset - _kCircularProgressIndicatorSize, 0) / 2;
        return Opacity(
            opacity: [IndicatorMode.ready, IndicatorMode.processed].contains(_mode) ? 1 : math.max(0.5, padding / 20).clamp(0, 1),
            child: Stack(
                clipBehavior: Clip.none,
                children: [
                    SizedBox(
                        width: _axis == Axis.vertical ? double.infinity : offset,
                        height: _axis == Axis.horizontal ? double.infinity : offset,
                    ),

                    Positioned(
                        top: _axis == Axis.vertical
                            ? widget.reverse
                                ? padding
                                : null
                            : 0,
                        bottom: _axis == Axis.vertical
                            ? widget.reverse
                                ? null
                                : padding
                            : 0,
                        left: math.max(0, (padding - 25) / 1.5).clamp(0, 16).toDouble(),
                        right: _axis == Axis.horizontal
                            ? widget.reverse
                                ? null
                                : padding
                            : 0,
                        child: Center(
                            child: _buildIndicator(),
                        ),
                    ),
                ],
            ),
        );
    }
}


class TextHeader extends MaterialHeader{

    const TextHeader({
        this.reverse
    });

    final bool? reverse;

    @override
    Widget build(BuildContext context, IndicatorState state) {
        return TextIndicator(
            key: key,
            state: state,
            disappearDuration: processedDuration,
            reverse: reverse ?? state.reverse,
            backgroundColor: backgroundColor,
            color: color,
            valueColor: valueColor,
            semanticsLabel: semanticsLabel,
            semanticsValue: semanticsValue,
            noMoreIcon: noMoreIcon,
            showBezierBackground: showBezierBackground,
            bezierBackgroundColor: bezierBackgroundColor,
            bezierBackgroundAnimation: bezierBackgroundAnimation,
            bezierBackgroundBounce: bezierBackgroundBounce,
        );
    }
}

class TextFooter extends MaterialFooter{

    const TextFooter({
        this.reverse = true
    });

    final bool? reverse;

    @override
    Widget build(BuildContext context, IndicatorState state) {
        return TextIndicator(
            key: key,
            state: state,
            disappearDuration: processedDuration,
            reverse: reverse ?? state.reverse,
            backgroundColor: backgroundColor,
            color: color,
            valueColor: valueColor,
            semanticsLabel: semanticsLabel,
            semanticsValue: semanticsValue,
            noMoreIcon: noMoreIcon,
            showBezierBackground: showBezierBackground,
            bezierBackgroundColor: bezierBackgroundColor,
            bezierBackgroundAnimation: bezierBackgroundAnimation,
            bezierBackgroundBounce: bezierBackgroundBounce,
        );
    }
}
