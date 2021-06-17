import 'dart:ui';

import 'package:flutter/material.dart';

bool _isEmpty(double? d) {
  return d == null || d == 0.0;
}

class FsLineDots extends StatefulWidget {
  ///
  /// Dotted line color
  final Color color;

  ///
  /// height. If there is only [height] and no [width], you will get a dotted line in the vertical direction
  /// If there are both [width] and [height], you will get a dotted border.
  final double? height;

  ///
  /// width. If there is only [width] and no [height], you will get a dotted line in the horizontal direction
  /// If there are both [width] and [height], you will get a dotted border.
  final double? width;

  ///
  /// The thickness of the dotted line
  final double strokeWidth;

  ///
  /// The length of each small segment in the dotted line
  final double dottedLength;

  ///
  /// The distance between each segment in the dotted line
  final double space;

  ///
  /// [FsLineDots] provides developers with the ability to create dashed lines. It also supports creating a dashed border for a [Widget]. Support for controlling the thickness, spacing, and corners of the dotted border.
  FsLineDots({
    Key? key,
    this.color = Colors.black,
    this.height,
    this.width,
    this.dottedLength = 5.0,
    this.space = 3.0,
    this.strokeWidth = 1.0,
  }) : super(key: key) {
    assert(width != null && height != null);
  }

  @override
  _FsLineDotsState createState() => _FsLineDotsState();
}

class _FsLineDotsState extends State<FsLineDots> {
  double? childWidth;
  double? childHeight;
  GlobalKey childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (_isEmpty(widget.width) && _isEmpty(widget.height)) return Container();
    return dashPath(width: widget.width, height: widget.height);
  }

  void tryToGetChildSize() {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      try {
        RenderBox? box =
            childKey.currentContext?.findRenderObject() as RenderBox?;
        double tempWidth = box!.size.width;
        double tempHeight = box.size.height;
        bool needUpdate = tempWidth != childWidth || tempHeight != childHeight;
        if (needUpdate) {
          setState(() {
            childWidth = tempWidth;
            childHeight = tempHeight;
          });
        }
      } catch (e) {}
    });
  }

  CustomPaint dashPath({double? width, double? height}) {
    return CustomPaint(
        size: Size(_isEmpty(width) ? widget.strokeWidth : width!,
            _isEmpty(height) ? widget.strokeWidth : height!),
        foregroundPainter: _DottedLinePainter()
          ..color = widget.color
          ..dottedLength = widget.dottedLength
          ..space = widget.space
          ..strokeWidth = widget.strokeWidth);
  }
}

class _DottedLinePainter extends CustomPainter {
  Color? color;
  double? dottedLength;
  double? space;
  double? strokeWidth;
  Radius topLeft = Radius.zero;
  Radius topRight = Radius.zero;
  Radius bottomRight = Radius.zero;
  Radius bottomLeft = Radius.zero;

  @override
  void paint(Canvas canvas, Size size) {
    var isHorizontal = size.width > size.height;
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high
      ..color = color!
      ..style = PaintingStyle.fill
      ..strokeWidth = strokeWidth!;

    ///
    /// line
    double length = isHorizontal ? size.width : size.height;
    double count = (length) / (dottedLength! + space!);
    if (count < 2.0) return;
    var startOffset = Offset(0, 0);
    var totalDots = count.ceil();
    for (int i = 0; i < totalDots; i++) {
      canvas.drawCircle(startOffset, dottedLength!, paint);
      startOffset = startOffset.translate(
          (isHorizontal ? (dottedLength! + space!) : 0),
          (isHorizontal ? 0 : (dottedLength! + space!)));
    }
  }

  Path buildDashPath(Path path, double dottedLength, double space) {
    final Path r = Path();
    for (PathMetric metric in path.computeMetrics()) {
      double start = 0.0;
      while (start < metric.length) {
        double end = start + dottedLength;
        r.addPath(metric.extractPath(start, end), Offset.zero);
        start = end + space;
      }
    }
    return r;
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) {
    return true;
  }
}
