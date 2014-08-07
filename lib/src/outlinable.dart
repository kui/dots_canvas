library pixel_canvas.src.outlinable;

import 'dart:math';
import 'dart:collection';

const _LEFT = const Point(-1, 0);
const _RIGHT = const Point(1, 0);
const _UPPER = const Point(0, -1);
const _LOWER = const Point(0, 1);

List<Point<int>> getArounds(Point<int> p) =>
  [p + _LEFT, p + _RIGHT, p + _UPPER, p + _LOWER];

abstract class Outlinable {
  Set<Point<int>> get points;

  Set<Line> get outline {
    final Set<Point<int>> pts = new HashSet.from(points);

    return pts.map((p) {
      final lines = [];
      final upper = p + _UPPER, lower = p + _LOWER,
          left = p + _LEFT, right = p + _RIGHT;
      if (!pts.contains(upper)) lines.add(new HorizontalLine(p));
      if (!pts.contains(lower)) lines.add(new HorizontalLine(lower));
      if (!pts.contains(left))  lines.add(new VerticalLine(p));
      if (!pts.contains(right)) lines.add(new VerticalLine(right));
      return lines;
    }).expand((List<Line> lines) => lines).toSet();
  }

  bool contains(Point<int> p) => points.contains(p);

  @override
  String toString() => points.toString();
}

abstract class Line {
  Point<int> get base;
  int get _typeCode;
  @override
  int get hashCode => (_typeCode * 31 + base.hashCode) & 0x3fffffff;
  @override
  bool operator ==(o) =>
    o is Line && o._typeCode == _typeCode && o.base == base;
}
class HorizontalLine extends Line {
  final Point<int> base;
  final int _typeCode = 0;
  HorizontalLine(this.base);
  @override
  String toString() => 'HLine(${base.x}, ${base.y})';
}
class VerticalLine extends Line {
  final Point<int> base;
  final int _typeCode = 1;
  VerticalLine(this.base);
  @override
  String toString() => 'VLine(${base.x}, ${base.y})';
}
