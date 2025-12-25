import 'package:flutter/material.dart';

class CustomDampingPhysic extends BouncingScrollPhysics {

  const CustomDampingPhysic({
    super.parent,
    this.decelerationDegree = 400.0,
  });

  final double decelerationDegree;

  @override
  CustomDampingPhysic applyTo(ScrollPhysics? ancestor) {
    return CustomDampingPhysic(
      parent: buildParent(ancestor),
      decelerationDegree: decelerationDegree,
    );
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);
    if (!position.outOfRange && velocity.abs() >= tolerance.velocity) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
        constantDeceleration: decelerationDegree,
      );
    }
    // 越界或无速度时，交给父级（这里父级通常是 AlwaysScrollableScrollPhysics）
    return super.createBallisticSimulation(position, velocity);
  }
}

