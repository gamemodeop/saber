
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'canvas.dart';

class Stroke {
  static const double minSqrDistBetweenPoints = 50;
  bool _wasLastPointExtraneous = false;

  final List<Point> _points = [];

  Color _color;
  Color get color => _color;
  set color(Color value) { _color = value; _polygonNeedsUpdating = true; }
  double _strokeWidth;
  double get strokeWidth => _strokeWidth;
  set strokeWidth(double value) { _strokeWidth = value; _polygonNeedsUpdating = true; }
  bool _isComplete = false;
  bool get isComplete => _isComplete;
  set isComplete(bool value) { _isComplete = value; _polygonNeedsUpdating = true; }

  bool _polygonNeedsUpdating = true;

  List<Offset>? _polygon;
  List<Offset> get polygon {
    if (_polygonNeedsUpdating) {
      _polygon = _getPolygon();
      _polygonNeedsUpdating = false;
    }
    return _polygon!;
  }

  Stroke({
    required Color color,
    required double strokeWidth,
  }): _color = color, _strokeWidth = strokeWidth;

  addPoint(Offset offset, [ double pressure = 0.5 ]) {
    double x = max(min(offset.dx, Canvas.canvasWidth), 0);
    double y = max(min(offset.dy, Canvas.canvasHeight), 0);
    Point point = Point(x, y, pressure);

    if (_wasLastPointExtraneous) {
      _points.removeLast();
      _wasLastPointExtraneous = false;
    }
    if (_points.isNotEmpty && sqrDistBetweenPoints(_points.last, point) < minSqrDistBetweenPoints) {
      // If the point is too close to the last point, add it for now but remove it next time.
      // This helps performance while reducing the gap between the line and user's finger.
      _wasLastPointExtraneous = true;
    }

    _points.add(point);
    _polygonNeedsUpdating = true;
  }

  List<Offset> _getPolygon() {
    return getStroke(
      _points,
      size: strokeWidth,
      isComplete: isComplete,
    )
      .map((Point point) => Offset(point.x, point.y))
      .toList(growable: false);
  }

  static sqrDistBetweenPoints(Point p1, Point p2) {
    return pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2);
  }
}
