import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'line_chart_painter.dart';
import 'line_chart_utils.dart';

class LineChart extends StatefulWidget {
  final LineChartController controller;

  LineChart({@required this.controller});
  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  Map<int, Offset> _ptrsMap = {};
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.controller.settings.backgroundColor,
      child: Listener(
        onPointerDown: (event) {
          _ptrsMap[event.pointer] = event.position;
        },
        onPointerMove: (event) {
          if (_ptrsMap.length == 1) {
            widget.controller.endTsNotifier.value -= event.delta.dx ~/ widget.controller.pixelsPerMs;
            widget.controller.startTsNotifier.value -= event.delta.dx ~/ widget.controller.pixelsPerMs;
          } else if (_ptrsMap.length == 2) {
            Offset otherPtr = _ptrsMap.entries.firstWhere((element) => element.key != event.pointer).value;
            Offset oldPtr = _ptrsMap.entries.firstWhere((element) => element.key == event.pointer).value;
            double distance = (event.position.dx - otherPtr.dx).abs() - (oldPtr.dx - otherPtr.dx).abs();
            double coef = (otherPtr.dx + event.position.dx) / (context.size.width);
            widget.controller.endTsNotifier.value -= (2 - coef) * distance ~/ widget.controller.pixelsPerMs;
            widget.controller.startTsNotifier.value += coef * distance ~/ widget.controller.pixelsPerMs;
            _ptrsMap[event.pointer] = event.position;
          }
        },
        onPointerUp: (event) {
          _ptrsMap.remove(event.pointer);
        },
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            double coef = event.position.dx * 2 / (context.size.width);
            widget.controller.endTsNotifier.value += 4 * (2 - coef) * event.scrollDelta.dy ~/ widget.controller.pixelsPerMs;
            widget.controller.startTsNotifier.value -= 4 * coef * event.scrollDelta.dy ~/ widget.controller.pixelsPerMs;
          }
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: LineChartPainter(
            endTimestamp: widget.controller.endTsNotifier,
            startTimestamp: widget.controller.startTsNotifier,
            controller: widget.controller,
          ),
        ),
      ),
    );
  }
}
